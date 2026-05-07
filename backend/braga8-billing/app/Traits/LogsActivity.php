<?php

namespace App\Traits;

use App\Models\AuditLog;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB; 


trait LogsActivity
{
    protected static function bootLogsActivity()
    {
        $tableLabels = [
            'users'          => 'pengguna',
            'customers'      => 'pelanggan',
            'meters'         => 'meteran',
            'meter_readings' => 'pencatatan meteran',
            'bills'          => 'tagihan',
            'payments'       => 'pembayaran',
            'zones'          => 'zona',
            'reports'        => 'laporan',
        ];

        foreach (['created', 'updated', 'deleted'] as $event) {
            static::$event(function ($model) use ($event, $tableLabels) {

                $rawTable  = $model->getTable();
                $label     = $tableLabels[$rawTable] ?? ucwords(str_replace('_', ' ', $rawTable));
                $userName  = Auth::user()?->name ?? 'Sistem';

                // ── Build specific description per table ──────────────────
                if ($rawTable === 'meter_readings') {
                    $description = self::buildMeterReadingDescription(
                        $model, $event, $userName
                    );
                } else {
                    // Generic fallback for other models
                    $dataName =
                        $model->meter_code
                        ?? $model->customer_number
                        ?? $model->invoice_number
                        ?? $model->title
                        ?? $model->email
                        ?? $model->name
                        ?? "#{$model->id}";

                    $description = match ($event) {
                        'created' => "{$userName} menambahkan {$label} baru '{$dataName}'",
                        'updated' => "{$userName} memperbarui informasi {$label} '{$dataName}'",
                        'deleted' => "{$userName} menghapus {$label} '{$dataName}'",
                        default   => "{$userName} melakukan aksi pada {$label} '{$dataName}'",
                    };
                }

                AuditLog::create([
                    'user_id'     => Auth::id(),
                    'action'      => $event,
                    'table_name'  => $rawTable,
                    'record_id'   => $model->id,
                    'description' => $description,
                ]);
            });
        }
    }

    // Use DB query directly to avoid triggering model events/observers
  private static function buildMeterReadingDescription($model, string $event, string $userName): string
    {
        $meter = DB::table('utility_meters') // ← remove the backslash, use imported facade
            ->join('units', 'units.id', '=', 'utility_meters.unit_id')
            ->join('tenants', 'tenants.id', '=', 'units.tenant_id')
            ->where('utility_meters.id', $model->meter_id)
            ->select(
                'utility_meters.meter_type',
                'units.unit_number',
                'tenants.tenant_name',
            )
            ->first();

    $meterType = match ($meter?->meter_type) {
        'electricity' => 'listrik',
        'water'       => 'air',
        default       => 'utilitas',
    };

    $unitLabel = $meter
        ? "Unit {$meter->unit_number} ({$meter->tenant_name})"
        : "Unit tidak diketahui";

    $value = $model->reading_value;
    $unit  = $meter?->meter_type === 'electricity' ? 'kWh' : 'm³';

    return match ($event) {
        'created' => "{$userName} menginput bacaan meter {$meterType} {$unitLabel} — {$value} {$unit}",
        'updated' => "{$userName} memperbarui bacaan meter {$meterType} {$unitLabel} — {$value} {$unit}",
        'deleted' => "{$userName} menghapus bacaan meter {$meterType} {$unitLabel}",
        default   => "{$userName} melakukan aksi pada meter {$meterType} {$unitLabel}",
    };
}
}