@extends('layouts.app')
@section('content')

<h1 class="text-xl font-bold mb-4">Create Tenant</h1>

@if(session('success'))
    <div class="bg-green-200 text-green-800 p-2 rounded mb-4">
        {{ session('success') }}
    </div>
@endif

<form method="POST" action="{{ route('tenants.store') }}" class="bg-white p-6 shadow rounded space-y-4">
    @csrf

    <div>
        <label class="block font-medium mb-1">Tenant Name <span class="text-red-500">*</span></label>
        <input name="tenant_name" type="text" value="{{ old('tenant_name') }}" class="border p-2 w-full rounded">
        @error('tenant_name')
            <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
        @enderror
    </div>

    <div>
        <label class="block font-medium mb-1">Company Name</label>
        <input name="company_name" type="text" value="{{ old('company_name') }}" class="border p-2 w-full rounded">
        @error('company_name')
            <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
        @enderror
    </div>

    <div>
        <label class="block font-medium mb-1">Business Type</label>
        <input name="business_type" type="text" value="{{ old('business_type') }}" class="border p-2 w-full rounded">
        @error('business_type')
            <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
        @enderror
    </div>

    <div>
        <label class="block font-medium mb-1">Person in Charge (PIC) <span class="text-red-500">*</span></label>
        <input name="person_in_charge" type="text" value="{{ old('person_in_charge') }}" class="border p-2 w-full rounded">
        @error('person_in_charge')
            <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
        @enderror
    </div>

    <div>
        <label class="block font-medium mb-1">Phone</label>
        <input name="contact_phone" type="text" value="{{ old('contact_phone') }}" class="border p-2 w-full rounded">
        @error('contact_phone')
            <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
        @enderror
    </div>

    <div>
        <label class="block font-medium mb-1">Email</label>
        <input name="contact_email" type="email" value="{{ old('contact_email') }}" class="border p-2 w-full rounded">
        @error('contact_email')
            <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
        @enderror
    </div>

    <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition">
        Save Tenant
    </button>
</form>

@endsection