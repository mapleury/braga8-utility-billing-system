@extends('layouts.app')
@section('content')

<h1 class="text-xl font-bold mb-4">Invoice Detail</h1>

<div class="bg-white p-6 shadow rounded mb-4">
    <p><strong>Invoice No:</strong> {{ $invoice->invoice_number }}</p>
    <p><strong>Tenant:</strong> {{ $invoice->tenant->tenant_name }}</p>
    <p><strong>Unit:</strong> {{ $invoice->unit->unit_number }}</p>
    <p><strong>Period:</strong> {{ $invoice->billing_period_start }} - {{ $invoice->billing_period_end }}</p>
    <p><strong>Status:</strong> {{ ucfirst($invoice->status) }}</p>
    <p><strong>Total:</strong> {{ number_format($invoice->total_amount,2) }}</p>
</div>

<h2 class="font-bold mb-2">Invoice Items</h2>
<table class="table-auto w-full bg-white shadow rounded mb-4">
    <thead>
        <tr class="bg-gray-100">
            <th class="px-4 py-2">Description</th>
            <th class="px-4 py-2">Amount</th>
        </tr>
    </thead>
    <tbody>
        @foreach($invoice->items as $item)
            <tr>
                <td class="border px-4 py-2">{{ $item->description }}</td>
                <td class="border px-4 py-2">{{ number_format($item->amount,2) }}</td>
            </tr>
        @endforeach
    </tbody>
</table>

{{-- Add this section above your Items table --}}
<h2 class="font-bold text-lg mb-4">Meter Reading Evidence</h2>
<div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
    <div class="border rounded p-4 bg-gray-50">
        <h3 class="font-semibold text-blue-600 mb-2">Electricity Meter</h3>
        @if($invoice->unit->electricityMeter->latestReading)
            <img src="{{ asset('storage/' . $invoice->unit->electricityMeter->latestReading->photo_path) }}" 
                 class="w-full h-64 object-cover rounded shadow" alt="Electricity Photo">
            <p class="mt-2 text-sm">Value: <strong>{{ $invoice->unit->electricityMeter->latestReading->reading_value }} kWh</strong></p>
        @else
            <p class="text-red-500">No photo recorded.</p>
        @endif
    </div>

    <div class="border rounded p-4 bg-gray-50">
        <h3 class="font-semibold text-blue-600 mb-2">Water Meter</h3>
        @if($invoice->unit->waterMeter->latestReading)
            <img src="{{ asset('storage/' . $invoice->unit->waterMeter->latestReading->photo_path) }}" 
                 class="w-full h-64 object-cover rounded shadow" alt="Water Photo">
            <p class="mt-2 text-sm">Value: <strong>{{ $invoice->unit->waterMeter->latestReading->reading_value }} m³</strong></p>
        @else
            <p class="text-red-500">No photo recorded.</p>
        @endif
    </div>
</div>

<a href="{{ route('invoices.pdf', $invoice) }}" class="bg-green-500 text-white px-4 py-2 rounded">Download PDF</a>
<a href="{{ route('invoices.index') }}" class="bg-gray-500 text-white px-4 py-2 rounded">Back to List</a>

@endsection