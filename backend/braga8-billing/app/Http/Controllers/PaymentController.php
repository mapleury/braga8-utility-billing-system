<?php

namespace App\Http\Controllers;

use App\Models\Payment;
use App\Models\Invoice;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Carbon\Carbon;
use App\Models\Notification;
use App\Models\User;


class PaymentController extends Controller
{
    public function index()
    {
        $totalBill = Invoice::sum('total_amount');
        $totalCollected = Payment::where('status', 'verified')->sum('amount_paid');
        $outstandingBill = $totalBill - $totalCollected;

        $payments = Payment::with(['invoice.tenant'])->latest()->paginate(10);

        return view('payments.index', compact('payments', 'totalBill', 'totalCollected', 'outstandingBill'));
    }

    public function create()
    {
        $invoices = Invoice::with('tenant')
            ->where('status', '!=', 'paid')
            ->get();
            
        return view('payments.create', compact('invoices'));
    }

    public function store(Request $request)
    {
        $invoice = Invoice::findOrFail($request->invoice_id);

        $request->validate([
            'invoice_id'   => 'required|exists:invoices,id',
            'amount_paid'  => 'required|numeric|min:' . $invoice->total_amount,
            'payment_date' => 'required|date',
            'paid_using'   => 'required|string',
            'proof_img'    => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ], [
            'amount_paid.min' => 'Amount cannot be less than the invoice total (Rp ' . number_format($invoice->total_amount) . ')',
        ]);

        $path = $request->hasFile('proof_img') 
            ? $request->file('proof_img')->store('payments', 'public') 
            : null;

        $payment = Payment::create([
            'invoice_id'   => $request->invoice_id,
            'amount_paid'  => $request->amount_paid,
            'due_date'     => $invoice->billing_period_end,
            'paid_using'   => $request->paid_using,
            'status'       => 'pending',
            'payment_date' => $request->payment_date,
            'proof_img'    => $path,
            'reminded_at'  => null, // Ensure this is explicitly null on start
        ]);

        return redirect()->route('payments.index')->with('success', 'Payment proof submitted.');
    }

    public function edit(Payment $payment)
    {
        $payment->load('invoice.tenant');
        return view('payments.edit', compact('payment'));
    }

    public function update(Request $request, Payment $payment)
    {
        $request->validate([
            'amount_paid'  => 'required|numeric',
            'status'       => 'required|in:pending,verified,rejected',
            'payment_date' => 'required|date',
            'proof_img'    => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        $data = $request->only(['amount_paid', 'status', 'payment_date', 'paid_using']);

        if ($request->hasFile('proof_img')) {
            if ($payment->proof_img) Storage::disk('public')->delete($payment->proof_img);
            $data['proof_img'] = $request->file('proof_img')->store('payments', 'public');
        }

        $payment->update($data);

        if ($payment->status === 'verified') {
            $payment->invoice->update(['status' => 'paid']);
        }

if ($payment->status === 'verified') {
    $payment->invoice->update(['status' => 'paid']);

    $tenantName = $payment->invoice->tenant->tenant_name;

    $admins = User::where('role', 'admin')->get();

    foreach ($admins as $admin) {
        Notification::create([
            'user_id' => $admin->id,
            'title' => 'Payment Received',
            'message' => "{$tenantName} paid their invoice",
            'type' => 'payment'
        ]);
    }
}

        return redirect()->route('payments.index')->with('success', 'Payment record updated.');
    }

    public function destroy(Payment $payment)
    {
        if ($payment->proof_img) Storage::disk('public')->delete($payment->proof_img);
        $payment->delete();
        return back()->with('success', 'Payment record deleted.');
    }

    /**
     * MANUAL WHATSAPP REMINDER with 2-Day Cooldown
     */
    public function remind(Payment $payment)
    {
        // 1. Check Cooldown (Wait 2 Days)
        if ($payment->reminded_at && $payment->reminded_at->diffInDays(now()) < 2) {
            $nextAvailable = $payment->reminded_at->addDays(2)->diffForHumans();
            return back()->with('error', "Patience! You can remind them again in {$nextAvailable}.");
        }

        $tenant = $payment->invoice->tenant;
        $phone = $tenant->contact_phone;
        
        if (!$phone) {
            return back()->with('error', 'Tenant phone number not found.');
        }

        // 2. Mark as reminded NOW
        $payment->update(['reminded_at' => now()]);

        // 3. Prepare WA Message
        $cleanPhone = preg_replace('/[^0-9]/', '', $phone);
        if (str_starts_with($cleanPhone, '0')) {
            $cleanPhone = '62' . substr($cleanPhone, 1);
        }

        $statusText = strtoupper($payment->status);
        $amount = number_format($payment->amount_paid);
        $invoiceNo = $payment->invoice->invoice_number;

        $message = "*KONFIRMASI PEMBAYARAN: " . $invoiceNo . "*\n" .
                   "Gedung Braga 8\n" .
                   "--------------------------\n" .
                   "*Tenant:* " . $tenant->tenant_name . "\n" .
                   "*Status:* " . $statusText . "\n" .
                   "*Jumlah:* Rp " . $amount . "\n" .
                   "--------------------------\n\n" .
                   "Halo, ini adalah pengingat bahwa status pembayaran Anda saat ini adalah *" . $statusText . "*.\n" .
                   "Mohon tunggu proses verifikasi atau hubungi admin jika ada kendala. Terima kasih.";

        $waUrl = "https://wa.me/" . $cleanPhone . "?text=" . urlencode($message);

        return redirect()->away($waUrl);
    }
}