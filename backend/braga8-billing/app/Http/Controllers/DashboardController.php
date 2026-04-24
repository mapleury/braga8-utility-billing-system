<?php

namespace App\Http\Controllers;

use App\Models\Tenant;
use App\Models\Unit;
use App\Models\UtilityMeter;
use App\Models\Invoice;
use App\Models\Payment;
use App\Models\Complaint;
use App\Models\MeterReading;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
  public function index()
{
    // 1. Tenant Stats
    $totalTenants = Tenant::count();
    $newTenantsThisMonth = Tenant::whereMonth('created_at', Carbon::now()->month)->count();

    // 2. Financial Stats
    $totalInvoiceValue = Invoice::sum('total_amount');
    $totalPaidAmount = Payment::where('status', 'success')->sum('amount_paid');
    $paidCount = Payment::where('status', 'success')->count();
    $totalUnpaidAmount = max($totalInvoiceValue - $totalPaidAmount, 0);
    
    $unpaidCount = Invoice::whereDoesntHave('payments', function ($query) {
        $query->where('status', 'success');
    })->count();

    // 3. Billing Percentages & Overdue
    $baseValue = max($totalInvoiceValue, 1);
    $percentPaid = round(($totalPaidAmount / $baseValue) * 100);
    $percentUnpaid = 100 - $percentPaid;
    
    $overdueCount = Invoice::where('created_at', '<', Carbon::now()->subDays(30))
        ->whereDoesntHave('payments', function ($query) {
            $query->where('status', 'success');
        })->count();
            
    $totalInvoicesCount = max(Invoice::count(), 1);
    $percentOverdue = round(($overdueCount / $totalInvoicesCount) * 100);

    // 4. Meter Progress (Logic Baru)
    $totalMeters = UtilityMeter::count();
    // Meter yang sudah diisi hari ini
    $metersDone = MeterReading::whereDate('created_at', Carbon::today())->count();
    // Meter yang belum diisi hari ini
    $metersRemaining = max($totalMeters - $metersDone, 0);

$unitsCompleted = DB::table('meter_readings')
    // Ganti 'utility_meter_id' menjadi 'meter_id'
    ->join('utility_meters', 'meter_readings.meter_id', '=', 'utility_meters.id') 
    ->whereDate('meter_readings.created_at', Carbon::today())
    ->select('utility_meters.unit_id')
    ->groupBy('utility_meters.unit_id')
    ->having(DB::raw('count(*)'), '>=', 2)
    ->get()
    ->count();

    return view('dashboard', [
        // Top Row
        'totalTenants' => $totalTenants,
        'newTenantsThisMonth' => $newTenantsThisMonth,
        'totalPaidAmount' => $totalPaidAmount,
        'paidCount' => $paidCount,
        'totalUnpaidAmount' => $totalUnpaidAmount,
        'unpaidCount' => $unpaidCount,
        // Filter: Hanya keluhan yang belum 'resolved'
        'totalComplaints' => Complaint::where('status', '!=', 'resolved')->count(),

        // Middle Row (Meter Stats)
        'percentPaid' => $percentPaid,
        'percentUnpaid' => $percentUnpaid,
        'percentOverdue' => min($percentOverdue, 100),
        'metersDone' => $metersDone,
        'metersRemaining' => $metersRemaining, // Kirim data 'yang belum'
        'totalMeters' => $totalMeters,
        'unitsCompleted' => $unitsCompleted,
        
        // Sidebar/Misc
        'totalUnits' => Unit::count(),
    ]);
}

public function getProgressData()
{
    $currentMonth = now()->month;
    $currentYear = now()->year;

    // 1. Total semua meter yang aktif
    $totalMeters = UtilityMeter::count();

    // 2. Total meter yang sudah diinput di bulan ini
    $completedReadings = MeterReading::whereMonth('recorded_at', $currentMonth)
        ->whereYear('recorded_at', $currentYear)
        ->distinct('meter_id')
        ->count();

    return response()->json([
        'total_meters' => $totalMeters,
        'completed_meters' => $completedReadings,
        'percentage' => $totalMeters > 0 ? ($completedReadings / $totalMeters) : 0,
        'month_name' => now()->format('F')
    ]);
}
}