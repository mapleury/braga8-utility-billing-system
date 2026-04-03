@extends('layouts.app')
@section('content')

<h1 class="text-xl font-bold mb-4">Tenant Detail</h1>

<div class="bg-white p-6 shadow rounded">
<p><strong>Name:</strong> {{ $tenant->tenant_name }}</p>
<p><strong>PIC:</strong> {{ $tenant->person_in_charge }}</p>
<p><strong>Phone:</strong> {{ $tenant->contact_phone }}</p>
<p><strong>Email:</strong> {{ $tenant->contact_email }}</p>
<p><strong>Company Name:</strong> {{ $tenant->company_name }}</p>
<p><strong>Business Type:</strong> {{ $tenant->business_type }}</p>
</div>

@endsection