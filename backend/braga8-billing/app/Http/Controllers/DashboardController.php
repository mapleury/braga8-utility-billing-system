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

        // 2. Financial Stats (Using your 'amount_paid' column)
        $totalInvoiceValue = Invoice::sum('total_amount');
        
        // Total Collected: Summing the 'amount_paid' column from successful payments
        $totalPaidAmount = Payment::where('status', 'success')->sum('amount_paid');
        $paidCount = Payment::where('status', 'success')->count();

        // Outstanding: Total Invoices - Total Collected
        $totalUnpaidAmount = max($totalInvoiceValue - $totalPaidAmount, 0);
        
        // Count invoices that have NO successful payments linked to them
        $unpaidCount = Invoice::whereDoesntHave('payments', function ($query) {
            $query->where('status', 'success');
        })->count();

        // 3. Billing Percentages
        $baseValue = max($totalInvoiceValue, 1);
        $percentPaid = round(($totalPaidAmount / $baseValue) * 100);
        $percentUnpaid = 100 - $percentPaid;
        
        // Overdue Logic: Invoices past due date with no successful payment
       // Calculate overdue based on created_at + 30 days instead of a dedicated due_date
$overdueCount = Invoice::where('created_at', '<', Carbon::now()->subDays(30))
    ->whereDoesntHave('payments', function ($query) {
        $query->where('status', 'success');
    })->count();
            
        $totalInvoicesCount = max(Invoice::count(), 1);
        $percentOverdue = round(($overdueCount / $totalInvoicesCount) * 100);

        // 4. Meter Progress (Inputs for today)
        $totalMeters = UtilityMeter::count();
        $metersDone = MeterReading::whereDate('created_at', Carbon::today())->count();

        return view('dashboard', [
            // Top Row
            'totalTenants' => $totalTenants,
            'newTenantsThisMonth' => $newTenantsThisMonth,
            'totalPaidAmount' => $totalPaidAmount,
            'paidCount' => $paidCount,
            'totalUnpaidAmount' => $totalUnpaidAmount,
            'unpaidCount' => $unpaidCount,
            'totalComplaints' => Complaint::count(),

            // Middle Row
            'percentPaid' => $percentPaid,
            'percentUnpaid' => $percentUnpaid,
            'percentOverdue' => min($percentOverdue, 100),
            'metersDone' => $metersDone,
            'totalMeters' => $totalMeters,
            
            // Sidebar/Misc
            'totalUnits' => Unit::count(),
        ]);
    }
}