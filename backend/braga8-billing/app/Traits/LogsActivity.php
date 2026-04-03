<?php

namespace App\Traits;

use App\Models\AuditLog;
use Illuminate\Support\Facades\Auth;

trait LogsActivity
{
    protected static function bootLogsActivity()
    {
        foreach (['created', 'updated', 'deleted'] as $event) {
            static::$event(function ($model) use ($event) {
                // Check if user is logged in (might be null during registration/seeding)
                $userName = Auth::user()?->name ?? 'System';
                $tableName = $model->getTable();

            AuditLog::create([
    'user_id'    => Auth::id(),
    'action'     => $event,
    'table_name' => $model->getTable(), // This fills 'table_name'
    'record_id'  => $model->id,         // This fills 'record_id'
    'description' => "{$userName} {$event} a record in {$model->getTable()}",
]);  
            });
        }
    }
}