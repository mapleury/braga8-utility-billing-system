<?php

use App\Http\Controllers\AuditLogController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\RegisteredUserController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\TenantController;
use App\Http\Controllers\UnitController;
use App\Http\Controllers\MeterReadingController;
use App\Http\Controllers\TariffController;
use App\Http\Controllers\InvoiceController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\UtilityMeterController;

use App\Http\Controllers\ReminderController;
use App\Http\Controllers\UsageReportController;
use App\Http\Controllers\ComplaintController;

// 1. Homepage
Route::get('/', function () {
    return view('welcome');
});

// 2. Auth Routes (Guest)
Route::middleware('guest')->group(function () {
    Route::get('register', [RegisteredUserController::class, 'create'])->name('register');
    Route::post('register', [RegisteredUserController::class, 'store']);
});

// 3. Authenticated Routes
Route::middleware(['auth', 'verified'])->group(function () {
    
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

    // Profile
    Route::prefix('profile')->group(function () {
        Route::get('/', [ProfileController::class, 'edit'])->name('profile.edit');
        Route::patch('/', [ProfileController::class, 'update'])->name('profile.update');
        Route::delete('/', [ProfileController::class, 'destroy'])->name('profile.destroy');
    });



    // Audit Logs Routes
    Route::get('/audit-logs', [AuditLogController::class, 'index'])->name('audit_logs.index');
    
    // Optional: Route to clear logs (Careful with this one!)
    Route::delete('/audit-logs/clear', [AuditLogController::class, 'clear'])->name('audit_logs.clear');

    // Resources (Standard CRUD)
    Route::resource('users', UserController::class);
    Route::resource('tenants', TenantController::class);
    Route::resource('units', UnitController::class);
    Route::resource('utility-meters', UtilityMeterController::class);
    Route::resource('meter-readings', MeterReadingController::class);
    Route::resource('tariffs', TariffController::class);
    Route::resource('invoices', InvoiceController::class);

    Route::resource('reminders', ReminderController::class);

    // Custom Extra Routes
    Route::get('invoices/{invoice}/pdf', [InvoiceController::class, 'pdf'])->name('invoices.pdf');
});

// 4. Include Laravel Breeze/Fortify Auth Routes
require __DIR__.'/auth.php';

Route::patch('/meter-readings/{id}/status', [MeterReadingController::class, 'updateStatus'])
    ->name('meter-readings.update-status');

Route::get('/invoices/{invoice}/notify', [InvoiceController::class, 'notifyTenant'])->name('invoices.notify');

// Usage & Analytics Reports
Route::prefix('reports')->group(function () {
    // 1. The Main Dashboard (Index)
    Route::get('/', [UsageReportController::class, 'index'])->name('reports.index');

    // 2. The Logic Trigger (Generate/Recalculate)
    Route::post('/generate', [UsageReportController::class, 'generate'])->name('reports.generate');

    // 3. The Export (PDF Download)
    Route::get('/{id}/pdf', [UsageReportController::class, 'exportPdf'])->name('reports.pdf');
});
Route::resource('payments', PaymentController::class);

Route::post('/payments/{payment}/remind', [PaymentController::class, 'remind'])->name('payments.remind');


Route::resource('complaints', ComplaintController::class);
Route::get('complaints/{complaint}/action', [App\Http\Controllers\ComplaintController::class, 'action'])->name('complaints.action');
Route::resource('complaints', App\Http\Controllers\ComplaintController::class);
