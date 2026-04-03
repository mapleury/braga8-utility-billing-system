@extends('layouts.app')

@section('content')
<div class="container mx-auto p-6">
    {{-- Header Section --}}
    <div class="flex justify-between items-center mb-8">
        <div>
            <h2 class="text-3xl font-extrabold text-gray-900 tracking-tight">Payment Records</h2>
            <p class="text-gray-500 text-sm">Monitor collections and outstanding balances for Braga 8.</p>
        </div>
        <a href="{{ route('payments.create') }}" 
           class="inline-flex items-center px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-xl shadow-lg shadow-indigo-200 transition-all transform hover:-translate-y-0.5">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
            Add New Payment
        </a>
    </div>

    {{-- Stats Cards Section --}}
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
        <div class="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
            <p class="text-xs font-bold text-gray-400 uppercase tracking-wider">Total Bill Issued</p>
            <p class="text-2xl font-black text-gray-900 mt-2">Rp {{ number_format($totalBill) }}</p>
            <div class="mt-2 h-1 w-12 bg-gray-200 rounded"></div>
        </div>

        <div class="bg-indigo-50 p-6 rounded-2xl border border-indigo-100 shadow-sm">
            <p class="text-xs font-bold text-indigo-400 uppercase tracking-wider">Total Collected</p>
            <p class="text-2xl font-black text-indigo-700 mt-2">Rp {{ number_format($totalCollected) }}</p>
            <div class="mt-2 h-1 w-12 bg-indigo-500 rounded"></div>
        </div>

        <div class="bg-rose-50 p-6 rounded-2xl border border-rose-100 shadow-sm">
            <p class="text-xs font-bold text-rose-400 uppercase tracking-wider">Outstanding Balance</p>
            <p class="text-2xl font-black text-rose-600 mt-2">Rp {{ number_format($outstandingBill) }}</p>
            <div class="mt-2 h-1 w-12 bg-rose-500 rounded"></div>
        </div>
    </div>

    {{-- Main Table Section --}}
    <div class="bg-white rounded-2xl shadow-xl border border-gray-100 overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50/50">
                <tr>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-widest">Tenant / Invoice</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-widest">Amount Paid</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-widest">Status</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-widest">Proof</th>
                    {{-- NEW COLUMN --}}
                    <th class="px-6 py-4 text-center text-xs font-bold text-gray-500 uppercase tracking-widest">Remind</th>
                    <th class="px-6 py-4 text-right text-xs font-bold text-gray-500 uppercase tracking-widest">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                @forelse($payments as $payment)
                <tr class="hover:bg-gray-50/50 transition-colors">
                    <td class="px-6 py-4">
                        <div class="text-sm font-extrabold text-gray-900">{{ $payment->invoice->tenant->tenant_name }}</div>
                        <div class="text-[11px] text-gray-400 font-medium">{{ $payment->invoice->invoice_number }}</div>
                    </td>
                    <td class="px-6 py-4">
                        <span class="text-sm font-bold text-gray-800">Rp {{ number_format($payment->amount_paid) }}</span>
                    </td>
                    <td class="px-6 py-4">
                        <span class="px-3 py-1 text-[10px] font-black rounded-full tracking-tighter
                            {{ $payment->status == 'verified' ? 'bg-emerald-100 text-emerald-700' : ($payment->status == 'rejected' ? 'bg-rose-100 text-rose-700' : 'bg-amber-100 text-amber-700') }}">
                            {{ strtoupper($payment->status) }}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-sm">
                        @if($payment->proof_img)
                            <a href="{{ asset('storage/' . $payment->proof_img) }}" target="_blank" 
                               class="text-indigo-600 hover:text-indigo-800 font-bold flex items-center group">
                                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                Proof
                            </a>
                        @else
                            <span class="text-gray-300 italic text-xs">None</span>
                        @endif
                    </td>
                    
               <td class="px-6 py-4 text-center">
    @if($payment->status !== 'verified')
        @php
            // Logic: 2-day cooldown (48 hours)
            $isCooldown = $payment->reminded_at && $payment->reminded_at->diffInDays(now()) < 2;
        @endphp

        @if($isCooldown)
            {{-- Cooldown State: Non-clickable --}}
            <div class="flex flex-col items-center">
                <span class="inline-flex items-center p-2 bg-gray-100 text-gray-400 rounded-full cursor-not-allowed" title="On Cooldown">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </span>
              <span class="text-[9px] text-gray-400 mt-1 font-bold">
    {{-- Use ceil to show how many full days are left --}}
    Wait {{ ceil(2 - $payment->reminded_at->diffInDays(now())) }}d
</span>
            </div>
        @else
            {{-- Active State: Opens WA in New Tab --}}
            <form action="{{ route('payments.remind', $payment->id) }}" method="POST" target="_blank">
                @csrf
                <button type="submit" 
                        onclick="setTimeout(() => { window.location.reload(); }, 500);"
                        class="inline-flex items-center p-2 bg-green-50 text-green-600 rounded-full hover:bg-green-100 transition-colors group" 
                        title="Send WhatsApp Reminder">
                    <svg class="w-5 h-5 transition-transform group-hover:scale-110" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/>
                    </svg>
                </button>
            </form>
        @endif
    @else
        <span class="text-emerald-500 font-bold text-xs flex items-center justify-center">
            <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M5 13l4 4L19 7" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/></svg>
            Verified
        </span>
    @endif
</td>

                    <td class="px-6 py-4 text-right">
                        <div class="flex justify-end items-center gap-3">
                            <a href="{{ route('payments.edit', $payment->id) }}" class="text-gray-400 hover:text-indigo-600 transition-colors">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" stroke-linecap="round" stroke-linejoin="round"/></svg>
                            </a>
                            <form action="{{ route('payments.destroy', $payment->id) }}" method="POST" onsubmit="return confirm('Archive this payment record?')">
                                @csrf @method('DELETE')
                                <button class="text-gray-400 hover:text-rose-600 transition-colors">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="6" class="px-6 py-20 text-center text-gray-400 italic">No payments recorded yet.</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    {{-- Pagination --}}
    <div class="mt-6">
        {{ $payments->links() }}
    </div>
</div>
@endsection