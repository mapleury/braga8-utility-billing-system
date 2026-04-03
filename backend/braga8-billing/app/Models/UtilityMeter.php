<?php
namespace App\Models;

use App\Traits\LogsActivity;
use Illuminate\Database\Eloquent\Model;

class UtilityMeter extends Model
{
    use LogsActivity;
    protected $fillable = [
        'unit_id', 'meter_type', 'meter_number', 'power_capacity', 'tariff_id', 'meter_category',
    ];

    public function unit() {
        return $this->belongsTo(Unit::class)->withDefault();
    }

    public function tariff() {
        return $this->belongsTo(Tariff::class);
    }

    public function readings() {
        return $this->hasMany(MeterReading::class, 'meter_id');
    }

    // --- SMART HELPERS ---

    /**
     * Automatically gets the most recent reading for this meter
     */
    public function latestReading() {
        return $this->hasOne(MeterReading::class, 'meter_id')->latestOfMany('recorded_at');
    }
}