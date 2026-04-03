<?php

namespace App\Models;

use App\Traits\LogsActivity;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable

{
    use LogsActivity;
    use HasApiTokens, HasFactory, Notifiable;
  protected $fillable = [
    'name',
    'username',
    'email',
    'password',
    'phone_number',
    'role',
];
// User.php
public function meterReadings() {
    return $this->hasMany(MeterReading::class);
}


// Unit.php
public function tenant() {
    return $this->belongsTo(Tenant::class);
}

public function meters() {
    return $this->hasMany(UtilityMeter::class);
}

// UtilityMeter.php
public function unit() {
    return $this->belongsTo(Unit::class);
}

public function readings() {
    return $this->hasMany(MeterReading::class);
}

// MeterReading.php
public function user() {
    return $this->belongsTo(User::class);
}

public function meter() {
    return $this->belongsTo(UtilityMeter::class);
}

}
