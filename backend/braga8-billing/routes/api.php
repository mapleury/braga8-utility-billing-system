<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\AuditLogController;
use App\Http\Controllers\MeterReadingController;
use App\Http\Controllers\TenantController;
use App\Models\Tenant;
use App\Models\Unit;
use App\Models\MeterReading;
use Illuminate\Support\Facades\Storage;

/*
|--------------------------------------------------------------------------
| API Routes - Braga 8 Utility Billing System
|--------------------------------------------------------------------------
*/

Route::get('/app/splash', function () {
    return response()->json([
        'app_name' => 'Braga 8 Utility Billing',
        'version' => '1.0.0',
        'status' => 'active'
    ]);
});

Route::get('/app/onboarding', function () {
    return response()->json([
        'slides' => [
            [
                'title' => 'Digital Meter Recording',
                'description' => 'Record utility meters easily with photo evidence and GPS tracking.',
                'image' => 'onboarding_1.png'
            ],
            [
                'title' => 'Automated Invoicing',
                'description' => 'System generates postpaid invoices based on accurate meter readings.',
                'image' => 'onboarding_2.png'
            ],
            [
                'title' => 'Tenant Portal',
                'description' => 'Manage tenants and units efficiently within a single dashboard.',
                'image' => 'onboarding_3.png'
            ]
        ]
    ]);
});

/**
 * SECTION 2: PUBLIC ACCESS
 */

Route::post('/login', [AuthController::class, 'login']);

// Preflight CORS for meter photos
Route::options('/meter-photo/{path}', function () {
    return response('', 200)
        ->header('Access-Control-Allow-Origin', '*')
        ->header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, ngrok-skip-browser-warning');
})->where('path', '.*');

// Meter image serving logic
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

/**
 * SECTION 3: AUTHENTICATED ROUTES
 */

Route::middleware('auth:sanctum')->group(function () {
    
    // Auth Operations
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/profile/update', [AuthController::class, 'updateProfile']);

    // Tenant & Unit Resources
    Route::get('/tenants', [TenantController::class, 'index']);

    // Dashboard Unit Summary
    Route::get('/units/summary', function () {
        $thisMonth  = now()->month;
        $thisYear   = now()->year;
        $lastMonth  = now()->subMonth()->month;
        $lastYear   = now()->subMonth()->year;

        $tenants = Tenant::with(['units.meters'])->get();

        foreach ($tenants as $tenant) {
            foreach ($tenant->units as $unit) {
                foreach ($unit->meters as $meter) {
                    
                    $meter->latest_reading = MeterReading::where('meter_id', $meter->id)
                        ->whereMonth('recorded_at', $thisMonth)
                        ->whereYear('recorded_at', $thisYear)
                        ->orderBy('recorded_at', 'desc')
                        ->first();

                    $meter->previous_reading = MeterReading::where('meter_id', $meter->id)
                        ->whereMonth('recorded_at', $lastMonth)
                        ->whereYear('recorded_at', $lastYear)
                        ->orderBy('recorded_at', 'desc')
                        ->first();
                }
            }
        }

        return response()->json($tenants);
    });

    // Reading Operations
    Route::prefix('readings')->group(function () {
        Route::post('/', [MeterReadingController::class, 'store']);
        Route::put('/{id}', [MeterReadingController::class, 'update']);
        Route::patch('/{id}/status', [MeterReadingController::class, 'updateStatus']);
    });

    // Detailed Unit History
    Route::get('/units/{unitId}/readings', function ($unitId) {
        $unit = Unit::with(['meters.readings' => function ($q) {
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

        usort($history, function ($a, $b) {
            return strcmp($b['recorded_at'], $a['recorded_at']);
        });

        return response()->json($history);
    });

    // Analytical Routes
    Route::get('/meter-progress', [MeterReadingController::class, 'getMonthlyProgress']);

    // Communication / Tenant Portal
 Route::prefix('notifications')->group(function () {
    Route::get('/', [NotificationController::class, 'index']);
    Route::patch('/{notification}/read', [NotificationController::class, 'markAsRead']);
    Route::delete('/{notification}', [NotificationController::class, 'destroy']);
    
    // Tambahkan ini:
    Route::patch('/read-all', [NotificationController::class, 'markAllAsRead']);
    Route::delete('/', [NotificationController::class, 'destroyAll']);
});
    // Admin Logs
    Route::get('/audit-logs', [AuditLogController::class, 'apiIndex']);

});
