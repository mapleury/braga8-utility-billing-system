<?php
namespace App\Models;

use App\Traits\LogsActivity;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Unit extends Model
{
    use LogsActivity;
    use HasFactory;

    protected $fillable = [
        'tenant_id', 'unit_number', 'floor', 'area_size', 'is_active', 'lease_start', 'lease_end',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'lease_start' => 'date',
        'lease_end' => 'date',
    ];

    public function tenant() {
        return $this->belongsTo(Tenant::class);
    }

    public function meters() {
        return $this->hasMany(UtilityMeter::class, 'unit_id');
    }

    // --- SMART HELPERS ---

    /**
     * Get the specific electricity meter for this unit
     */
    public function electricityMeter() {
        return $this->hasOne(UtilityMeter::class, 'unit_id')->where('meter_type', 'electricity');
    }

    /**
     * Get the specific water meter for this unit
     */
    public function waterMeter() {
        return $this->hasOne(UtilityMeter::class, 'unit_id')->where('meter_type', 'water');
    }
}