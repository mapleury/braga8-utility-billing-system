@extends('layouts.app')
@section('content')

<h1 class="text-xl font-bold mb-4">Edit Tenant</h1>

@if(session('success'))
    <div class="bg-green-200 text-green-800 p-2 rounded mb-4">
        {{ session('success') }}
    </div>
@endif

<form method="POST" action="{{ route('tenants.update',$tenant->id) }}" class="bg-white p-6 shadow rounded">
@csrf
@method('PUT')
<p><strong>Name:</strong></p>
<input name="tenant_name" value="{{ $tenant->tenant_name }}" class="border p-2 w-full mb-3">
<p><strong>PIC:</strong></p>
<input name="person_in_charge" value="{{ $tenant->person_in_charge }}" class="border p-2 w-full mb-3">
<p><strong>Phone:</strong></p>
<input name="contact_phone" value="{{ $tenant->contact_phone }}" class="border p-2 w-full mb-3">
<p><strong>Email:</strong></p>
<input name="contact_email" value="{{ $tenant->contact_email }}" class="border p-2 w-full mb-3">
<p><strong>Company Name:</strong></p>
<input name="company_name" value="{{ $tenant->company_name }}" class="border p-2 w-full mb-3">
<p><strong>Business Type:</strong></p>
<input name="business_type" value="{{ $tenant->business_type }}" class="border p-2 w-full mb-3">

<button class="bg-green-600 text-white px-4 py-2 rounded">Update</button>

</form>
@endsection