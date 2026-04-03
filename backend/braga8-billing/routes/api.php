<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\TenantController as ControllersTenantController;
use Illuminate\Support\Facades\Route;


Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/tenants', [ControllersTenantController::class, 'index']);
    Route::post('/logout', [AuthController::class, 'logout']);
});

