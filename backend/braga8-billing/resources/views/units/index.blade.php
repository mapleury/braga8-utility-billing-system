@extends('layouts.app')

@section('content')

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<div class="container mt-5">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3">Units</h1>
        <div>
            <a href="{{ route('units.create') }}" class="btn btn-primary me-2">
                <i class="bi bi-plus-lg"></i> Add Unit
            </a>
            <a href="{{ route('tenants.create') }}" class="btn btn-success">
                <i class="bi bi-building"></i> Create Tenant
            </a>
        </div>
    </div>

    <div class="row mb-4">
        <div class="col-md-12">
            <form action="{{ route('units.index') }}" method="GET" class="d-flex">
                <input type="text" name="search" class="form-control me-2" placeholder="Search tenant or unit..." value="{{ request('search') }}">
                <button type="submit" class="btn btn-secondary">Search</button>
            </form>
        </div>
    </div>

    @if(session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @endif

    @foreach($tenants as $tenant)
        <div class="card mb-4 shadow-sm">
            <div class="card-header d-flex justify-content-between align-items-center bg-light">
                <span><strong>Tenant:</strong> {{ $tenant->tenant_name }}</span>
                <span class="text-muted">{{ $tenant->units->count() }} Units</span>
            </div>

            <div class="card-body p-0">
                @if($tenant->units->count() > 0)
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Unit</th>
                                    <th>Floor</th>
                                    <th>Area Size (m²)</th>
                                    <th>Status</th>
                                    <th>Lease Start</th>
                                    <th>Lease End</th>
                                    <th class="text-end">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($tenant->units as $unit)
                                    <tr>
                                        <td>{{ $unit->unit_number }}</td>
                                        <td>{{ $unit->floor ?? '-' }}</td>
                                        <td>{{ $unit->area_size ?? '-' }}</td>
                                        <td>
                                            @if($unit->is_active)
                                                <span class="badge bg-success">Active</span>
                                            @else
                                                <span class="badge bg-secondary">Inactive</span>
                                            @endif
                                        </td>
                                        <td>{{ $unit->lease_start ?? '-' }}</td>
                                        <td>{{ $unit->lease_end ?? '-' }}</td>
                                        <td class="text-end">
                                            <a href="{{ route('units.show', $unit->id) }}" class="btn btn-sm btn-info me-1">
                                                <i class="bi bi-eye"></i> View
                                            </a>
                                            <a href="{{ route('units.edit', $unit->id) }}" class="btn btn-sm btn-warning me-1">
                                                <i class="bi bi-pencil"></i> Edit
                                            </a>
                                            <form action="{{ route('units.destroy', $unit->id) }}" method="POST" class="d-inline">
                                                @csrf
                                                @method('DELETE')
                                                <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('Are you sure?')">
                                                    <i class="bi bi-trash"></i> Delete
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                @else
                    <div class="p-3">
                        <p class="mb-0 text-muted">No units assigned to this tenant yet.</p>
                    </div>
                @endif
            </div>
        </div>
    @endforeach

</div>

@endsection