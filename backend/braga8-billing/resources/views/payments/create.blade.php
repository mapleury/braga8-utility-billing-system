@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto p-6 bg-white rounded-2xl shadow-xl mt-10">
    <h2 class="text-xl font-bold mb-6">New Payment Entry</h2>

    {{-- Error Alert for Validation --}}
    @if ($errors->any())
        <div class="mb-4 p-4 bg-red-100 text-red-700 rounded-lg">
            @foreach ($errors->all() as $error)
                <p class="text-sm">× {{ $error }}</p>
            @endforeach
        </div>
    @endif

    <form action="{{ route('payments.store') }}" method="POST" enctype="multipart/form-data">
        @csrf
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="col-span-2">
                <label class="block text-sm font-medium text-gray-700">Select Invoice</label>
                <select name="invoice_id" id="invoice_id" class="w-full mt-1 rounded-lg border-gray-300">
                    <option value="" disabled selected>Select an Invoice</option>
                    @foreach($invoices as $inv)
                        {{-- Added data-total here --}}
                        <option value="{{ $inv->id }}" data-total="{{ $inv->total_amount }}">
                            {{ $inv->invoice_number }} - {{ $inv->tenant->tenant_name }} (Rp {{ number_format($inv->total_amount) }})
                        </option>
                    @endforeach
                </select>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700">Amount Paid</label>
                {{-- Set min to 0 for now, JS will update the 'min' attribute --}}
                <input type="number" name="amount_paid" id="amount_paid" 
                       class="w-full mt-1 rounded-lg border-gray-300 bg-gray-50 focus:bg-white transition-colors" 
                       required step="any">
                <p class="text-[10px] text-gray-500 mt-1" id="min_amount_label">Select an invoice to see total.</p>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700">Payment Date</label>
                <input type="date" name="payment_date" class="w-full mt-1 rounded-lg border-gray-300" value="{{ date('Y-m-d') }}">
            </div>

            {{-- ... other fields (Paid Via, Status, Proof Img) ... --}}
            <div>
                <label class="block text-sm font-medium text-gray-700">Paid Via</label>
                <select name="paid_using" class="w-full mt-1 rounded-lg border-gray-300">
                    <option value="Bank Transfer">Bank Transfer</option>
                    <option value="Cash">Cash</option>
                    <option value="E-Wallet">E-Wallet</option>
                </select>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700">Status</label>
                <select name="status" class="w-full mt-1 rounded-lg border-gray-300">
                    <option value="pending">Pending</option>
                    <option value="verified">Verified</option>
                    <option value="rejected">Rejected</option>
                </select>
            </div>
            <div class="col-span-2">
                <label class="block text-sm font-medium text-gray-700">Upload Receipt (Image)</label>
                <input type="file" name="proof_img" class="w-full mt-1 text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:bg-indigo-50 file:text-indigo-700 hover:file:bg-indigo-100">
            </div>
        </div>

        <input type="hidden" name="due_date" value="{{ date('Y-m-d') }}">
        <button type="submit" class="mt-6 w-full bg-indigo-600 text-white py-3 rounded-xl font-bold shadow-lg shadow-indigo-200 hover:bg-indigo-700 transition-all">
            Save Payment
        </button>
    </form>
</div>

<script>
    document.getElementById('invoice_id').addEventListener('change', function() {
        // Get the selected option's data-total attribute
        const selectedOption = this.options[this.selectedIndex];
        const totalAmount = selectedOption.getAttribute('data-total');
        
        const amountInput = document.getElementById('amount_paid');
        const label = document.getElementById('min_amount_label');

        if (totalAmount) {
            amountInput.value = totalAmount; // Auto-fill
            amountInput.min = totalAmount;   // Browser-level validation
            label.innerText = "Minimum payment: Rp " + new Intl.NumberFormat('id-ID').format(totalAmount);
            label.classList.add('text-indigo-600');
        }
    });
</script>
@endsection