<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Database\Eloquent\Relations\Relation;
use Illuminate\Support\Facades\View;
use Illuminate\Support\Facades\Auth;
use App\Models\Complaint;
use App\Models\Invoice;
use App\Models\InvoiceItem;
use App\Models\MeterReading;
use App\Models\Notification;
use App\Models\Reminder;
use App\Models\Tenant;
use App\Models\UsageReport;
use App\Models\User;
use App\Models\UtilityMeter;
use App\Models\Payment;
use App\Models\Tariff;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
       Relation::enforceMorphMap([
        'tenants'        => Tenant::class,
        'meter_readings' => MeterReading::class,
        'invoices'       => Invoice::class,
        'invoice_items'  => InvoiceItem::class,
        'reminders'      => Reminder::class,
        'complaints'     => Complaint::class,
        'users'          => User::class,
        'usage_reports'  => UsageReport::class,
        'utility_meters' => UtilityMeter::class,
        'payments'       => Payment::class,
        'tariffs'        => Tariff::class, 
    ]);

        View::composer('*', function ($view) {
            if (Auth::check()) {
                $notifications = Notification::where('user_id', Auth::id())
                    ->latest()
                    ->take(10)
                    ->get();

                $view->with('notifications', $notifications);
            }
        });
    }

    
}