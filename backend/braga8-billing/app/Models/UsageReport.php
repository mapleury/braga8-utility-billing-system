<?php

namespace App\Models;

use App\Traits\LogsActivity;
use Illuminate\Database\Eloquent\Model;

class UsageReport extends Model
{
    use LogsActivity;
    protected $fillable = [
        'month_year',
        'total_units_billed',
        'total_electric_usage',
        'total_water_usage',
        'total_others', // Add this to your migration if you haven't!
        'total_revenue_expected',
    ];

    public function calculateMonthlyStats($month) 
    {
        // 1. Get all invoices starting in this month (e.g., '2026-04%')
        $invoices = Invoice::where('billing_period_start', 'like', "$month%")->get();

        if ($invoices->isEmpty()) {
            return;
        }

        // 2. Calculate the Grand Total first
        $grandTotalRevenue = $invoices->sum('total_amount');

        // 3. Get all line items for these specific invoices
        $invoiceIds = $invoices->pluck('id');
        
        // Sum Electricity items
        $electricRevenue = InvoiceItem::whereIn('invoice_id', $invoiceIds)
            ->where('description', 'like', '%Listrik%')
            ->sum('amount');

        // Sum Water items
        $waterRevenue = InvoiceItem::whereIn('invoice_id', $invoiceIds)
            ->where('description', 'like', '%Air%')
            ->sum('amount');

        // 4. Calculate the "Gap" (Maintenance, Service Fees, etc.)
        // This ensures the math always balances: Total - (Utilities) = Others
        $othersRevenue = $grandTotalRevenue - ($electricRevenue + $waterRevenue);

        // 5. Save everything
        $this->month_year = $month;
        $this->total_units_billed = $invoices->count();
        $this->total_electric_usage = $electricRevenue;
        $this->total_water_usage = $waterRevenue;
        $this->total_others = $othersRevenue; 
        $this->total_revenue_expected = $grandTotalRevenue;

        $this->save();
    }
}