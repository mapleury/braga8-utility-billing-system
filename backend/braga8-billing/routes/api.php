<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\AuditLogController;
use App\Http\Controllers\MeterReadingController;
use App\Http\Controllers\TenantController;
use App\Models\Tenant;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// --- PUBLIC ROUTES ---
Route::post('/login', [AuthController::class, 'login']);

Route::get('/meter-photo/{path}', function ($path) {
    $fullPath = storage_path('app/public/meter_photos/' . $path);
    if (!file_exists($fullPath)) abort(404);

    $file = file_get_contents($fullPath);
    return response($file, 200)
        ->header('Content-Type', 'image/png')
        ->header('Access-Control-Allow-Origin', '*')
        ->header('Cross-Origin-Resource-Policy', 'cross-origin');
});


// --- PROTECTED ROUTES (Sanctum) ---
Route::middleware('auth:sanctum')->group(function () {
    
    // 1. Auth & Profile
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/profile/update', [AuthController::class, 'updateProfile']);

    // 2. Tenants & Units
    Route::get('/tenants', [TenantController::class, 'index']);
    Route::get('/units/summary', function () {
        return Tenant::with(['units.meters.readings' => function($query) {
            $query->latest(); 
        }])->get();
    });

    // 3. Meter Readings (New Features: Store & Update)
    Route::prefix('readings')->group(function () {
        // Digunakan oleh InputReadingScreen saat Submit data baru
        Route::post('/', [MeterReadingController::class, 'store']); 
        
        // Digunakan oleh InputReadingScreen saat mode Edit (Update data yang salah)
        Route::put('/{id}', [MeterReadingController::class, 'update']); 
    });

    // 4. Stats & Progress
    Route::get('/meter-progress', [MeterReadingController::class, 'getMonthlyProgress']);

    // 5. Notifications
    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index']);
        Route::patch('/{notification}/read', [NotificationController::class, 'markAsRead']);
        Route::delete('/{notification}', [NotificationController::class, 'destroy']);
    });

    // 6. Audit Logs
    Route::get('/audit-logs', [AuditLogController::class, 'apiIndex']);
});