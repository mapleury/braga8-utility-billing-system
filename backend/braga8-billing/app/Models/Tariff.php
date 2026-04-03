<?php

namespace App\Models;

use App\Traits\LogsActivity;
use Illuminate\Database\Eloquent\Model;
class Tariff extends Model
{
    use LogsActivity;
protected $fillable = [
    'name', 
    'water_price',
    'electric_price',
    'electric_load_cost',
    'transformer_maintenance',
    'admin_fee',
    'stamp_fee',
    'other_fees',
    'tax_percent',
];

protected $casts = [
    'other_fees' => 'array', // This is vital for the JSON to save correctly
];

}