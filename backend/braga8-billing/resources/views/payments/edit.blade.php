@extends('layouts.app')

@section('content')
<div class="max-w-2xl mx-auto p-6 bg-white rounded-2xl shadow-xl mt-10">
    <div class="flex justify-between items-center mb-6">
        <h2 class="text-xl font-bold text-gray-800">Edit Payment Entry</h2>
        <span class="px-3 py-1 text-xs font-bold rounded-full bg-gray-100 text-gray-600">
            ID: #{{ $payment->id }}
        </span>
    </div>

    {{-- Error Alert --}}
    @if ($errors->any())
        <div class="mb-4 p-4 bg-red-50 text-red-700 rounded-lg border border-red-200">
            @foreach ($errors->all() as $error)
                <p class="text-sm font-medium">× {{ $error }}</p>
            @endforeach
        </div>
    @endif

    <form action="{{ route('payments.update', $payment->id) }}" method="POST" enctype="multipart/form-data">
        @csrf
        @method('PUT')

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            {{-- Invoice Selection (Locked in Edit) --}}
            <div class="col-span-2">
                <label class="block text-sm font-semibold text-gray-700">Invoice Reference</label>
                <div class="mt-1 p-3 bg-gray-50 border border-gray-200 rounded-lg text-gray-600 font-medium">
                    {{ $payment->invoice->invoice_number }} - {{ $payment->invoice->tenant->tenant_name }}
                    <input type="hidden" name="invoice_id" value="{{ $payment->invoice_id }}">
                </div>
            </div>

            {{-- Amount Paid --}}
            <div>
                <label class="block text-sm font-semibold text-gray-700">Amount Paid (Rp)</label>
                <input type="number" name="amount_paid" 
                       value="{{ old('amount_paid', $payment->amount_paid) }}"
                       class="w-full mt-1 rounded-lg border-gray-300 focus:ring-indigo-500 focus:border-indigo-500" 
                       required>
                <p class="text-[10px] text-gray-400 mt-1 italic">Total Tagihan: Rp {{ number_format($payment->invoice->total_amount) }}</p>
            </div>

            {{-- Payment Date --}}
            <div>
                <label class="block text-sm font-semibold text-gray-700">Payment Date</label>
                <input type="date" name="payment_date" 
                       value="{{ old('payment_date', $payment->payment_date->format('Y-m-d')) }}"
                       class="w-full mt-1 rounded-lg border-gray-300">
            </div>

            {{-- Method --}}
            <div>
                <label class="block text-sm font-semibold text-gray-700">Paid Via</label>
                <select name="paid_using" class="w-full mt-1 rounded-lg border-gray-300">
                    @foreach(['Bank Transfer', 'Cash', 'E-Wallet'] as $method)
                        <option value="{{ $method }}" {{ $payment->paid_using == $method ? 'selected' : '' }}>{{ $method }}</option>
                    @endforeach
                </select>
            </div>

            {{-- Status --}}
            <div>
                <label class="block text-sm font-semibold text-gray-700">Status</label>
                <select name="status" class="w-full mt-1 rounded-lg border-gray-300 font-bold {{ $payment->status == 'verified' ? 'text-green-600' : 'text-amber-600' }}">
                    <option value="pending" {{ $payment->status == 'pending' ? 'selected' : '' }}>PENDING</option>
                    <option value="verified" {{ $payment->status == 'verified' ? 'selected' : '' }}>VERIFIED</option>
                    <option value="rejected" {{ $payment->status == 'rejected' ? 'selected' : '' }}>REJECTED</option>
                </select>
            </div>

            {{-- Image Section --}}
            <div class="col-span-2">
                <label class="block text-sm font-semibold text-gray-700 mb-2">Payment Proof</label>
                
                @if($payment->proof_img)
                    <div class="mb-3">
                        <p class="text-xs text-gray-500 mb-1">Current Image:</p>
                        <img src="{{ asset('storage/' . $payment->proof_img) }}" 
                             class="w-32 h-32 object-cover rounded-lg border-2 border-gray-100 shadow-sm">
                    </div>
                @endif

                <div class="relative group">
                    <input type="file" name="proof_img" 
                           class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:bg-indigo-50 file:text-indigo-700 hover:file:bg-indigo-100">
                    <p class="mt-1 text-[11px] text-gray-400">Leave empty to keep current image. Max 2MB (JPG, PNG).</p>
                </div>
            </div>
        </div>

        <div class="mt-8 flex gap-3">
            <a href="{{ route('payments.index') }}" class="flex-1 text-center py-3 px-4 border border-gray-300 text-gray-700 font-semibold rounded-xl hover:bg-gray-50 transition-all">
                Cancel
            </a>
            <button type="submit" class="flex-[2] bg-indigo-600 text-white py-3 px-4 rounded-xl font-bold shadow-lg shadow-indigo-200 hover:bg-indigo-700 transition-all transform hover:-translate-y-0.5">
                Update Payment
            </button>
        </div>
    </form>
</div>
@endsection