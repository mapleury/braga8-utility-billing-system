@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8">

@if(session('success'))
    <div class="mb-4 p-4 bg-emerald-500 text-white rounded-xl font-bold shadow-lg">
        {{ session('success') }}
    </div>
@endif

@if(session('error'))
    <div class="mb-4 p-4 bg-rose-500 text-white rounded-xl font-bold shadow-lg">
        {{ session('error') }}
    </div>
@endif

    {{-- Header Section --}}
    <div class="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
            <h1 class="text-3xl font-extrabold text-gray-900 dark:text-white tracking-tight">
                Invoice Management
            </h1>
            <p class="text-gray-500 dark:text-gray-400 mt-1">Manage billing and notify tenants for Braga 8.</p>
        </div>
        <a href="{{ route('invoices.create') }}" 
           class="inline-flex items-center justify-center px-5 py-3 border border-transparent text-base font-medium rounded-xl text-white bg-indigo-600 hover:bg-indigo-700 shadow-lg shadow-indigo-500/30 transition-all duration-200 ease-in-out transform hover:-translate-y-1">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/></svg>
            Create New Invoice
        </a>
    </div>

    {{-- Main Table --}}
    <div class="overflow-hidden bg-white dark:bg-gray-800 shadow-2xl rounded-2xl border border-gray-100 dark:border-gray-700">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead class="bg-gray-50 dark:bg-gray-900/50">
                <tr>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Invoice No</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Tenant</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Unit</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Total Amount</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Status</th>
                    <th class="px-6 py-4 text-center text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Notify</th>
                    <th class="px-6 py-4 text-right text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100 dark:divide-gray-700 bg-white dark:bg-gray-800">
            @foreach($invoices as $invoice)
                <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                    <td class="px-6 py-4 whitespace-nowrap font-mono text-sm font-semibold text-indigo-600 dark:text-indigo-400">
                        {{ $invoice->invoice_number }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700 dark:text-gray-200">
                        {{ $invoice->tenant->tenant_name }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                        <span class="px-2 py-1 bg-gray-100 dark:bg-gray-700 rounded-md">{{ $invoice->unit->unit_number }}</span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-gray-900 dark:text-white">
                        Rp {{ number_format($invoice->total_amount, 2) }}
                    </td>
                    
                    {{-- Updated Notification Status Logic --}}
                    <td class="px-6 py-4 whitespace-nowrap">
                        @if($invoice->notified_at)
                            <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400">
                                <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20"><path d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"/></svg>
                                Sended to Tenant
                            </span>
                        @else
                            <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-bold bg-rose-100 text-rose-700 dark:bg-rose-900/30 dark:text-rose-400">
                                <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20"><path d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"/></svg>
                                Not yet send
                            </span>
                        @endif
                    </td>

                    <td class="px-6 py-4 whitespace-nowrap text-center">
                        <div class="flex flex-col items-center justify-center">
                            <a href="{{ route('invoices.notify', $invoice->id) }}" 
                               target="_blank"
                               onclick="setTimeout(() => { window.location.reload(); }, 1000);"
                               class="inline-flex items-center p-2 {{ $invoice->notified_at ? 'bg-gray-400' : 'bg-emerald-500' }} hover:opacity-80 text-white rounded-full transition-all shadow-md active:scale-95">
                                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                                    <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.27 9.27 0 01-4.703-1.277l-.337-.201-3.497.917.937-3.41-.22-.35a9.271 9.271 0 01-1.429-4.947c0-5.113 4.158-9.27 9.273-9.27 2.476 0 4.803.965 6.556 2.719a9.213 9.213 0 012.714 6.551c0 5.115-4.158 9.27-9.273 9.27m8.163-17.432A11.029 11.029 0 0012.048 1c-6.096 0-11.056 4.96-11.056 11.056 0 1.95.51 3.855 1.478 5.54L.621 23l5.588-1.466A11.06 11.06 0 0012.043 23c6.1 0 11.059-4.96 11.059-11.056 0-2.956-1.15-5.733-3.24-7.824z"/>
                                </svg>
                            </a>
                            @if($invoice->notified_at)
                                <span class="text-[9px] uppercase font-bold text-gray-400 mt-1">{{ $invoice->notified_at->format('d M') }}</span>
                            @endif
                        </div>
                    </td>

                    <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-3">
                        <a href="{{ route('invoices.show', $invoice) }}" class="text-indigo-600 hover:text-indigo-900 dark:hover:text-indigo-400">View</a>
                        <a href="{{ route('invoices.pdf', $invoice) }}" class="text-teal-600 hover:text-teal-900 dark:hover:text-teal-400">PDF</a>
                        <form action="{{ route('invoices.destroy', $invoice) }}" method="POST" class="inline">
                            @csrf @method('DELETE')
                            <button class="text-rose-600 hover:text-rose-900 dark:hover:text-rose-400" onclick="return confirm('Archive this invoice?')">Delete</button>
                        </form>
                    </td>
                </tr>
            @endforeach
            </tbody>
        </table>
    </div>

    {{-- Pagination --}}
    <div class="mt-6">
        {{ $invoices->links() }}
    </div>
</div>
@endsection