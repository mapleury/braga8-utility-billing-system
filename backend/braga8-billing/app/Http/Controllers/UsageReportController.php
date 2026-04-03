<?php

namespace App\Http\Controllers;

use App\Models\Invoice;
use App\Models\UsageReport;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;

class UsageReportController extends Controller
{

public function index()
{
    // Get reports ordered by latest month
    $reports = UsageReport::orderBy('month_year', 'desc')->get();
    return view('reports.index', compact('reports'));
}

public function generate(Request $request)
{
    $month = $request->input('month'); // e.g., "2026-04"

    // Logic to calculate stats (as we discussed in Step 2 of the previous reply)
    $report = UsageReport::firstOrNew(['month_year' => $month]);
    $report->calculateMonthlyStats($month);

    return redirect()->route('reports.index')->with('success', 'Report generated for ' . $month);
}
public function exportPdf($id)

{
    $report = UsageReport::findOrFail($id);
    
    // Get all invoices related to this month for the PDF table
    $invoices = Invoice::where('billing_period_start', 'like', $report->month_year . "%")
                ->with(['tenant', 'unit'])
                ->get();

    $pdf = Pdf::loadView('pdf.usage-report', compact('report', 'invoices'))
              ->setPaper('a4', 'landscape'); // Landscape is better for reports

    return $pdf->download("Usage-Report-{$report->month_year}.pdf");
}
}
