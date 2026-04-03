<?php

namespace App\Models;

use App\Traits\LogsActivity;
use Illuminate\Database\Eloquent\Model;

class MeterReading extends Model
{
    use LogsActivity;
    protected $fillable = [
        'meter_id', 'user_id', 'reading_value', 'photo_path', 'recorded_at', 'description', 'status',
    ];

    // Use $casts instead of $dates (Laravel 10+ style)
    protected $casts = [
        'recorded_at' => 'datetime',
    ];

    public function meter() {
        return $this->belongsTo(UtilityMeter::class, 'meter_id');
    }

    public function user() {
        return $this->belongsTo(User::class);
    }
}