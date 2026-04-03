@extends('layouts.app')

@section('content')
<div class="container mt-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>Tenants</h1>
        <a href="{{ route('tenants.create') }}" class="btn btn-primary shadow-sm">Add Tenant</a>
    </div>

    <div class="card border-0 shadow-sm mb-4">
        <div class="card-body">
            <form action="{{ route('tenants.index') }}" method="GET" class="row g-2">
                <div class="col-md-10">
                    <input type="text" 
                           name="search" 
                           class="form-control" 
                           placeholder="Search by tenant name..." 
                           value="{{ request('search') }}">
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-dark w-100">Search</button>
                </div>
            </form>
        </div>
    </div>

    <table class="table table-striped table-hover shadow-sm">
        <thead class="table-light">
            <tr>
                <th>Name</th>
                <th>PIC</th>
                <th class="text-center">Actions</th>
            </tr>
        </thead>
        <tbody>
            @forelse($tenants as $tenant)
            <tr>
                <td>{{ $tenant->tenant_name }}</td>
                <td>{{ $tenant->person_in_charge }}</td>
                <td class="text-center">
                    <a href="{{ route('tenants.show', $tenant->id) }}" class="btn btn-sm btn-info me-1">View</a>
                    <a href="{{ route('tenants.edit', $tenant->id) }}" class="btn btn-sm btn-warning me-1">Edit</a>
                    <form action="{{ route('tenants.destroy', $tenant->id) }}" method="POST" class="d-inline">
                        @csrf @method('DELETE')
                        <button class="btn btn-sm btn-danger" onclick="return confirm('Are you sure?')">Delete</button>
                    </form>
                </td>
            </tr>
            @empty
            <tr>
                <td colspan="3" class="text-center py-4 text-muted">No tenants found matching your search.</td>
            </tr>
            @endforelse
        </tbody>
    </table>

    <div class="mt-3">
        {{ $tenants->appends(['search' => request('search')])->links() }}
    </div>
</div>
@endsection