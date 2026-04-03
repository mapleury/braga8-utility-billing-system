<?php

namespace App\Providers;

use App\Models\Complaint;
use App\Models\Invoice;
use App\Models\InvoiceItem;
use App\Models\MeterReading;
use App\Models\Reminder;
use App\Models\Tenant;
use App\Models\UsageReport;
use App\Models\User;
use App\Models\UtilityMeter;
use Illuminate\Database\Eloquent\Relations\Relation;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */public function boot(): void
    {
        // This is the bridge between your DB strings and your Laravel Classes
        Relation::enforceMorphMap([
            'tenants'        => Tenant::class,
            'meter_readings' => MeterReading::class,
            'invoices'       => Invoice::class,
            'invoice_items'  => InvoiceItem::class, // Fixed the "Class not found" for this one
            'reminders'      => Reminder::class,
            'complaints'     => Complaint::class,
            'users'          => User::class,
            'usage_reports'  => UsageReport::class,
            'utility_meters' => UtilityMeter::class,
        ]);
    
}
}
