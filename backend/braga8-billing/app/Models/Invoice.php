<?php

namespace App\Models;

use App\Traits\LogsActivity;
use Illuminate\Database\Eloquent\Model;

class Invoice extends Model
{
    use LogsActivity;

  protected $fillable = [
    'tenant_id',
    'unit_id',
    'invoice_number',
    'billing_period_start',
    'billing_period_end',
    'total_amount',
    'notified_at', // Add this!
];

// Also, tell Laravel to treat it as a date


protected $casts = [
    'notified_at' => 'datetime',
    'billing_period_start' => 'date',
    'billing_period_end' => 'date',
];
    public function tenant()
    {
        return $this->belongsTo(Tenant::class);
    }

    public function unit()
    {
        return $this->belongsTo(Unit::class);
    }

    
    public function items()
    {
        return $this->hasMany(InvoiceItem::class);
    }
    public function payments()
{
    return $this->hasMany(Payment::class);
}

// Helper to check if it's fully paid
public function getIsPaidAttribute()
{
    return $this->payments()->where('status', 'verified')->sum('amount_paid') >= $this->total_amount;
}
}
