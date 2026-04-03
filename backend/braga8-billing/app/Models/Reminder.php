<?php

namespace App\Models;

use App\Traits\LogsActivity;
use Illuminate\Database\Eloquent\Model;

class Reminder extends Model
{
    use LogsActivity;
    protected $fillable = [
        'title',
        'reminder_date',
        'due_date',
        'role_target',
        'status'
    ];
    protected $casts = [
    'reminder_date' => 'date',
    'due_date' => 'date',
];
}