<?php

namespace App\Models;

use App\Traits\LogsActivity;
use Illuminate\Database\Eloquent\Model;

class UtilityMeter extends Model
{
    use LogsActivity;

    protected $fillable = [
        'unit_id', 
        'meter_type', 
        'meter_number', 
        'multiplier',
        'power_capacity', 
        'tariff_id',
    ];

    /**
     * Standardize behavior: Always set category to postpaid upon creation.
     */
    protected static function booted()
    {
        static::creating(function ($meter) {
            $meter->meter_category = 'postpaid';
        });
    }

    public function unit() 
    {
        return $this->belongsTo(Unit::class)->withDefault();
    }

    public function tariff() 
    {
        return $this->belongsTo(Tariff::class);
    }

    public function readings() 
    {
        return $this->hasMany(MeterReading::class, 'meter_id');
    }

    /**
     * Gets the most recent reading for this meter
     */
    public function latestReading() 
    {
        return $this->hasOne(MeterReading::class, 'meter_id')->latestOfMany('recorded_at');
    }
}