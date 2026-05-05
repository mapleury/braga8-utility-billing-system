<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\AuditLogController;
use App\Http\Controllers\MeterReadingController;
use App\Http\Controllers\TenantController;
use App\Models\Tenant;
use Illuminate\Support\Facades\Storage;

/*
|--------------------------------------------------------------------------
| API Routes - Braga8 Utility Billing System
|--------------------------------------------------------------------------
*/

// --- 1. PUBLIC ROUTES (Tanpa Login) ---
Route::post('/login', [AuthController::class, 'login']);

// Route Akses Foto Meteran (Dibuat public agar Image.network Flutter lancar)
// Handle OPTIONS preflight for meter-photo
Route::options('/meter-photo/{path}', function () {
    return response('', 200)
        ->header('Access-Control-Allow-Origin', '*')
        ->header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, ngrok-skip-browser-warning');
})->where('path', '.*');

// Actual image serving
Route::get('/meter-photo/{path}', function ($path) {
    $cleanPath = str_replace('readings/', '', $path);
    $fullPath = storage_path('app/public/readings/' . $cleanPath);

    if (!file_exists($fullPath)) {
        return response()->json(['message' => 'File tidak ditemukan'], 404)
            ->header('Access-Control-Allow-Origin', '*');
    }

    $extension = strtolower(pathinfo($fullPath, PATHINFO_EXTENSION));
    $mimeType = match ($extension) {
        'jpg', 'jpeg' => 'image/jpeg',
        'png'         => 'image/png',
        'gif'         => 'image/gif',
        default       => 'application/octet-stream',
    };

    return response()->file($fullPath, [
        'Content-Type'                 => $mimeType,
        'Access-Control-Allow-Origin'  => '*',
        'Access-Control-Allow-Headers' => 'Content-Type, Authorization, ngrok-skip-browser-warning',
        'Cache-Control'                => 'public, max-age=3600',
    ]);
})->where('path', '.*');


// --- 2. PROTECTED ROUTES (Wajib Login via Sanctum) ---
Route::middleware('auth:sanctum')->group(function () {
    
    // --- Auth Section ---
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/profile/update', [AuthController::class, 'updateProfile']);

    // --- Tenant & Unit Management ---
    Route::get('/tenants', [TenantController::class, 'index']);
    // Summary Unit untuk Dashboard/Daftar Unit petugas
   // Route di api.php kamu sebelumnya:
Route::get('/units/summary', function () {
    // Kita panggil relasi units, lalu di dalam units kita panggil meters
    return Tenant::with(['units' => function($q) {
        $q->with('meters'); // <--- PASTIKAN INI ADA
    }, 'units.meters.readings'])->get();
});

    // --- Meter Reading Logic (The Core) ---
    // Pastikan Flutter menembak POST ke /api/readings
    Route::prefix('readings')->group(function () {
        Route::post('/', [MeterReadingController::class, 'store']); // Tambah Data Baru
        Route::put('/{id}', [MeterReadingController::class, 'update']); // Edit Data
        Route::patch('/{id}/status', [MeterReadingController::class, 'updateStatus']); // Validasi Admin
    });

Route::get('/units/{unitId}/readings', function ($unitId) {
    $unit = \App\Models\Unit::with(['meters.readings' => function ($q) {
        $q->orderBy('recorded_at', 'desc');
    }])->findOrFail($unitId);

    $history = [];
    foreach ($unit->meters as $meter) {
        foreach ($meter->readings as $reading) {
            $history[] = [
                'id'               => $reading->id,
                'meter_id'         => $meter->id,
                'meter_number'     => $meter->meter_number,
                'meter_type'       => $meter->meter_type,
                'reading_value'    => $reading->reading_value,
                'photo_path'       => $reading->photo_path,
                'recorded_at'      => $reading->recorded_at,
                'location_address' => $reading->location_address,
                'description'      => $reading->description,
                'status'           => $reading->status,
            ];
        }
    }
    Route::get('/units/{unitId}/readings', function ($unitId) {
    $unit = \App\Models\Unit::with(['meters.readings' => function ($q) {
        $q->orderBy('recorded_at', 'desc');
    }])->findOrFail($unitId);

    $history = [];
    foreach ($unit->meters as $meter) {
        foreach ($meter->readings as $reading) {
            $history[] = [
                'id'               => $reading->id,
                'meter_id'         => $meter->id,
                'meter_number'     => $meter->meter_number,
                'meter_type'       => $meter->meter_type, // 'electricity' atau 'water'
                'reading_value'    => $reading->reading_value,
                'photo_path'       => $reading->photo_path,
                'recorded_at'      => $reading->recorded_at,
                'location_address' => $reading->location_address,
                'description'      => $reading->description,
                'status'           => $reading->status,
            ];
        }
    }

    usort($history, fn($a, $b) => strcmp($b['recorded_at'], $a['recorded_at']));

    return response()->json($history);
});

    // Sort all readings newest first
    usort($history, fn($a, $b) => $b['recorded_at'] <=> $a['recorded_at']);

    return response()->json($history);
});

    // Statistik Progress Bulanan
    Route::get('/meter-progress', [MeterReadingController::class, 'getMonthlyProgress']);

    // --- Notifications Section ---
    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index']);
        Route::patch('/{notification}/read', [NotificationController::class, 'markAsRead']);
        Route::delete('/{notification}', [NotificationController::class, 'destroy']);
    });

    // --- Monitoring & Audit ---
    Route::get('/audit-logs', [AuditLogController::class, 'apiIndex']);

});