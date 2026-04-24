<?php

namespace App\Models;

use App\Traits\LogsActivity;
use Illuminate\Database\Eloquent\Model;
class Tenant extends Model

{
    use LogsActivity;
    protected $fillable = [
        'tenant_name',
        'company_name',
        'business_type',
        'person_in_charge',
        'contact_phone',
        'contact_email',
        'user_id',
    ];
// Tenant model
public function user() {
    return $this->belongsTo(User::class);
}

    public function units()
{
    return $this->hasMany(Unit::class);
}

public function meters()
{
    return $this->hasMany(UtilityMeter::class);
}
    public function invoices()
    {
        return $this->hasMany(Invoice::class);
    }

public function readings() {
    return $this->hasMany(MeterReading::class); // Harus hasMany!
}
}
