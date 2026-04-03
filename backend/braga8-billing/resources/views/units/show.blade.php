@extends('layouts.app')
@section('content')

<h1 class="text-xl font-bold mb-4">Unit Details</h1>

<p><strong>Unit Number:</strong> {{ $unit->unit_number }}</p>
<p><strong>Tenant:</strong> {{ $unit->tenant ? $unit->tenant->tenant_name : 'Unassigned' }}</p>
<p><strong>Floor:</strong> {{ $unit->floor ?? '-' }}</p>
<p><strong>Area Size:</strong> {{ $unit->area_size ?? '-' }} m²</p>
<p><strong>Active:</strong> {{ $unit->is_active ? 'Yes' : 'No' }}</p>
<p><strong>Lease Start:</strong> {{ $unit->lease_start ?? '-' }}</p>
<p><strong>Lease End:</strong> {{ $unit->lease_end ?? '-' }}</p>

<a href="{{ route('units.index') }}" class="text-blue-600">Back to Units</a>

@endsection