<?php

namespace App\Http\Controllers;

use App\Models\Invoice;
use App\Models\Tenant;
use App\Models\Unit;
use App\Models\MeterReading;
use App\Models\Tariff;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;

class InvoiceController extends Controller
{
    public function index() {
        $invoices = Invoice::with(['tenant', 'unit'])->latest()->paginate(10);
        return view('invoices.index', compact('invoices'));
    }

    public function create() {
        $tenants = Tenant::all();
        $units = Unit::all(); 
        return view('invoices.create', compact('tenants', 'units'));
    }

  public function store(Request $request) {
    $request->validate([
        'tenant_id' => 'required|exists:tenants,id',
        'unit_id'   => 'required|exists:units,id',
    ]);

    // 1. Force load meters and their SPECIFIC tariffs
    $unit = Unit::with(['meters.tariff'])->findOrFail($request->unit_id);
    $tenant = Tenant::findOrFail($request->tenant_id);

    // 2. Define Billing Period
    $startDate = Carbon::now()->startOfMonth();
    $endDate   = Carbon::now()->endOfMonth();

    // 3. Get Usage (Calculates Current minus Previous)
    $readings = $this->calculateUsage($unit, $startDate, $endDate);
    
    if (isset($readings['error'])) {
        return back()->withErrors($readings['error']);
    }

    // 4. Find the correct Tariff
    // We try to find the tariff from the electricity meter specifically
    $elecMeter = $unit->meters->where('meter_type', 'electricity')->first();
    $tariff = $elecMeter->tariff ?? Tariff::latest()->first();

    if (!$tariff) {
        return back()->withErrors('No tariff settings found.');
    }

    // 5. THE CALCULATION FIX: Multiply by usage, not reading_value
    $waterUsage    = $readings['water_usage'];
    $electricUsage = $readings['electric_usage'];

    $waterCost    = $waterUsage * ($tariff->water_price ?? 0);
    $electricCost = $electricUsage * ($tariff->electric_price ?? 0);
    
    $otherFee = $request->filled('manual_other_fee') ? $request->manual_other_fee : ($tariff->other_fee ?? 0);

    $subtotal = $waterCost + $electricCost +
                ($tariff->electric_load_cost ?? 0) +
                ($tariff->transformer_maintenance ?? 0) +
                ($tariff->admin_fee ?? 0) +
                ($tariff->stamp_fee ?? 0) +
                $otherFee;

    $tax   = ($subtotal * ($tariff->tax_percent ?? 0)) / 100;
    $total = $subtotal + $tax;

    return DB::transaction(function () use ($tenant, $unit, $startDate, $endDate, $total, $waterCost, $electricCost, $tariff, $otherFee, $tax, $waterUsage, $electricUsage) {
        
        $invoice = Invoice::create([
            'tenant_id'            => $tenant->id,
            'unit_id'              => $unit->id,
            'invoice_number'       => 'INV-' . strtoupper(bin2hex(random_bytes(4))),
            'billing_period_start' => $startDate,
            'billing_period_end'   => $endDate,
            'total_amount'         => $total,
            'status'               => 'unpaid'
        ]);

        $items = [
            ['description' => "Pemakaian Air ($waterUsage m3)", 'amount' => $waterCost],
            ['description' => "Pemakaian Listrik ($electricUsage kWh)", 'amount' => $electricCost],
            ['description' => 'Biaya Beban Listrik', 'amount' => $tariff->electric_load_cost ?? 0],
            ['description' => 'Pemeliharaan Trafo',  'amount' => $tariff->transformer_maintenance ?? 0],
            ['description' => 'Administrasi',        'amount' => $tariff->admin_fee ?? 0],
            ['description' => 'Materai',             'amount' => $tariff->stamp_fee ?? 0],
            ['description' => 'Lain-lain',           'amount' => $otherFee],
            ['description' => 'PPN ('.($tariff->tax_percent ?? 0).'%)', 'amount' => $tax],
        ];

        foreach ($items as $item) {
            $invoice->items()->create($item);
        }

        return redirect()->route('invoices.index')->with('success', 'Invoice generated successfully.');
    });
}

    /**
     * CORE CALCULATION LOGIC
     */
    
   private function calculateUsage($unit) 
{
    $elecMeter = $unit->meters->where('meter_type', 'electricity')->first();
    $waterMeter = $unit->meters->where('meter_type', 'water')->first();

    // 1. Get current verified readings for April 2026
    $currElec = MeterReading::where('meter_id', $elecMeter->id)
                ->where('status', 'checked')
                ->whereMonth('recorded_at', 4)
                ->whereYear('recorded_at', 2026)
                ->first();

    $currWater = MeterReading::where('meter_id', $waterMeter->id)
                ->where('status', 'checked')
                ->whereMonth('recorded_at', 4)
                ->whereYear('recorded_at', 2026)
                ->first();

    // 2. Gatekeeper: Stop if April readings aren't verified yet
    if (!$currElec || !$currWater) {
        return ['error' => "Batal: Data meteran unit {$unit->unit_number} belum divalidasi (verified) untuk bulan ini."];
    }

    // 3. Look for Previous Reading (Before current ID)
    $prevElec = MeterReading::where('meter_id', $elecMeter->id)
                ->where('id', '<', $currElec->id)
                ->latest('id')
                ->first();

    $prevWater = MeterReading::where('meter_id', $waterMeter->id)
                ->where('id', '<', $currWater->id)
                ->latest('id')
                ->first();

    // 4. THE FIRST MONTH FIX:
    // If $prevElec is null (System Start), use 0.
    $pEVal = $prevElec ? $prevElec->reading_value : 0;
    $pWVal = $prevWater ? $prevWater->reading_value : 0;

    return [
        'electric_usage' => max(0, $currElec->reading_value - $pEVal),
        'water_usage'    => max(0, $currWater->reading_value - $pWVal),
    ];
}

    public function show(Invoice $invoice) {
        $invoice->load(['tenant', 'unit', 'items']);
        return view('invoices.show', compact('invoice'));
    }

    public function pdf(Invoice $invoice) {
        $invoice->load(['tenant', 'unit', 'items']);
        $pdf = Pdf::loadView('invoices.pdf', compact('invoice'));
        return $pdf->download($invoice->invoice_number . '.pdf');
    }

    public function update(Request $request, Invoice $invoice) {
        $request->validate(['status' => 'required|in:unpaid,paid,canceled']);
        $invoice->update(['status' => $request->status]);
        return redirect()->back()->with('success', 'Status updated.');
    }

    public function destroy(Invoice $invoice) {
        $invoice->delete();
        return redirect()->route('invoices.index')->with('success', 'Invoice deleted.');
    }
    public function notifyTenant(Invoice $invoice)
{
    $tenant = $invoice->tenant;
    
    // Using 'contact_phone' and 'person_in_charge' from your Tenant model
    $phone = $tenant->contact_phone;
    $picName = $tenant->person_in_charge;

    if (!$phone) {
        return back()->with('error', 'No PIC phone number found for this tenant.');
    }

    // 1. Clean the phone number for WhatsApp
    $cleanPhone = preg_replace('/[^0-9]/', '', $phone);
    if (str_starts_with($cleanPhone, '0')) {
        $cleanPhone = '62' . substr($cleanPhone, 1);
    }

    // 2. Build the message with the items table
    $itemsList = "";
    foreach ($invoice->items as $item) {
        $itemsList .= "• " . $item->description . ": Rp " . number_format($item->amount) . "\n";
    }

    $message = "*TAGIHAN INVOICE: " . $invoice->invoice_number . "*\n" .
               "Gedung Braga 8\n" .
               "--------------------------\n" .
               "*PIC:* " . $picName . "\n" .
               "*Unit:* " . $invoice->unit->unit_number . "\n" .
               "--------------------------\n" .
               "*Detail Pemakaian:*\n" . 
               $itemsList .
               "--------------------------\n" .
               "*TOTAL TAGIHAN: Rp " . number_format($invoice->total_amount) . "*\n" .
               "--------------------------\n\n" .
               "Silahkan cek detail lengkap di aplikasi. Terima kasih.";

    // 3. Update the System (mark as notified)
    // Note: Make sure you ran the migration for 'notified_at'
    $invoice->update(['notified_at' => now()]);

    // 4. Redirect to WhatsApp
    $waUrl = "https://wa.me/" . $cleanPhone . "?text=" . urlencode($message);

    return redirect()->away($waUrl);
}

}