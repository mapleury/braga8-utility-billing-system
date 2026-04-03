@extends('layouts.app')
@section('content')

<h1 class="text-xl font-bold mb-4">Update Invoice Status</h1>

@if ($errors->any())
    <div class="bg-red-100 p-4 rounded mb-4">
        <ul>
            @foreach ($errors->all() as $error)
                <li class="text-red-600">{{ $error }}</li>
            @endforeach
        </ul>
    </div>
@endif

<form action="{{ route('invoices.update', $invoice) }}" method="POST">
    @csrf
    @method('PUT')

    <div class="mb-4">
        <label class="block font-bold mb-1">Status</label>
        <select name="status" class="border rounded px-2 py-1 w-full" required>
            <option value="unpaid" {{ $invoice->status=='unpaid'?'selected':'' }}>Unpaid</option>
            <option value="paid" {{ $invoice->status=='paid'?'selected':'' }}>Paid</option>
            <option value="canceled" {{ $invoice->status=='canceled'?'selected':'' }}>Canceled</option>
        </select>
    </div>

    <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded">Update Status</button>
    <a href="{{ route('invoices.show', $invoice) }}" class="bg-gray-500 text-white px-4 py-2 rounded">Cancel</a>
</form>

@endsection