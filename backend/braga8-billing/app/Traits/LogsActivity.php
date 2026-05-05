<?php

namespace App\Traits;

use App\Models\AuditLog;
use Illuminate\Support\Facades\Auth;

trait LogsActivity
{
    protected static function bootLogsActivity()
    {
        // Translate table names to natural Indonesian nouns
        $tableLabels = [
            'users'           => 'pengguna',
            'customers'       => 'pelanggan',
            'meters'          => 'meteran',
            'meter_readings'  => 'pencatatan meteran',
            'bills'           => 'tagihan',
            'payments'        => 'pembayaran',
            'zones'           => 'zona',
            'reports'         => 'laporan',
            // Add more mappings as your app grows
        ];

        foreach (['created', 'updated', 'deleted'] as $event) {
            static::$event(function ($model) use ($event, $tableLabels) {

                $rawTable     = $model->getTable();
                $label        = $tableLabels[$rawTable] ?? ucwords(str_replace('_', ' ', $rawTable));
                $userName     = Auth::user()?->name ?? 'Sistem';

                // Pick the most meaningful identifier for this record
                $dataName =
                    $model->meter_code
                    ?? $model->customer_number
                    ?? $model->invoice_number
                    ?? $model->title
                    ?? $model->email
                    ?? $model->name
                    ?? "#{$model->id}";

                // Build a complete, natural Indonesian sentence
                switch ($event) {
                    case 'created':
                        $description = "{$userName} menambahkan {$label} baru '{$dataName}'";
                        break;
                    case 'updated':
                        $description = "{$userName} memperbarui informasi {$label} '{$dataName}'";
                        break;
                    case 'deleted':
                        $description = "{$userName} menghapus {$label} '{$dataName}'";
                        break;
                    default:
                        $description = "{$userName} melakukan aksi pada {$label} '{$dataName}'";
                        break;
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
}