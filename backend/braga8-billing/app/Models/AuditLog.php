<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphTo;
use Illuminate\Support\Str;

class AuditLog extends Model
{
    protected $fillable = ['user_id', 'action', 'table_name', 'record_id', 'description'];

    /**
     * Simplified Polymorphic Relationship
     */
    public function relatedModel(): MorphTo
    {
        // We tell Laravel to use 'table_name' as the type and 'record_id' as the ID.
        return $this->morphTo(null, 'table_name', 'record_id')->withDefault();
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

   public function getItemLabelAttribute(): string
{
    $model = $this->relatedModel;

    if (!$model || !$model->exists) {
        return "#{$this->record_id}";
    }

    return match ($this->table_name) {
        'invoices'       => $model->invoice_number ?? "#{$this->record_id}",
        'invoice_items'  => "Item for " . ($model->invoice->invoice_number ?? 'Unknown Bill'),
        'tenants'        => $model->tenant_name ?? "#{$this->record_id}",
        'users'          => $model->name ?? "#{$this->record_id}",
        'meter_readings' => "Reading: " . ($model->reading_value ?? 'N/A'),
        default          => "#" . $this->record_id,
    };
}

    public function getTableLabelAttribute(): string
    {
        $mapping = [
            'meter_readings' => 'Meter Log',
            'invoice_items'  => 'Invoice Detail',
            'utility_meters' => 'Utility Meter',
        ];
        return $mapping[$this->table_name] ?? Str::headline($this->table_name);
    }
}