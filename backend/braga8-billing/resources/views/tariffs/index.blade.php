@extends('layouts.app')

@section('content')
<div class="container py-4">
    <div class="row mb-4 align-items-center">
        <div class="col">
            <h2 class="fw-bold text-dark">Tariff Management</h2>
            <p class="text-muted">Configure and manage your pricing tiers.</p>
        </div>
        <div class="col-auto">
            <a href="{{ route('tariffs.create') }}" class="btn btn-success shadow-sm">
                <i class="fas fa-plus"></i> + Add New Tariff
            </a>
        </div>
    </div>

    @if(session('success'))
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            {{ session('success') }}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    @endif

    <div class="card border-0 shadow-sm mb-4">
        <div class="card-body">
            <form action="{{ route('tariffs.index') }}" method="GET" class="row g-2">
                <div class="col-md-10">
                    <div class="input-group">
                        <span class="input-group-text bg-white border-end-0">
                            <i class="fas fa-search text-muted"></i>
                        </span>
                        <input type="text" name="search" class="form-control border-start-0" 
                               placeholder="Search by tariff name..." value="{{ request('search') }}">
                    </div>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary w-100">Search</button>
                </div>
            </form>
        </div>
    </div>

    <div class="card border-0 shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-4">Tariff Name</th>
                            <th>Water Price</th>
                            <th>Electric Price</th>
                            <th>Additional Fees</th>
                            <th class="text-end pe-4">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($tariffs as $tariff)
                        <tr>
                            <td class="ps-4">
                                <span class="fw-bold text-primary">{{ $tariff->name ?? 'Unnamed Tariff' }}</span>
                            </td>
                            <td>{{ number_format($tariff->water_price, 2) }}</td>
                            <td>{{ number_format($tariff->electric_price, 2) }}</td>
                            <td>
                                <span class="badge bg-secondary rounded-pill">
                                    {{ is_array($tariff->other_fees) ? count($tariff->other_fees) : 0 }} items
                                </span>
                            </td>
                            <td class="text-end pe-4">
                                <div class="btn-group" role="group">
                                    <a href="{{ route('tariffs.show', $tariff->id) }}" class="btn btn-outline-info btn-sm">View</a>
                                    <a href="{{ route('tariffs.edit', $tariff->id) }}" class="btn btn-outline-warning btn-sm">Edit</a>
                                    
                                    <form action="{{ route('tariffs.destroy', $tariff->id) }}" method="POST" class="d-inline" 
                                          onsubmit="return confirm('Are you sure you want to delete this tariff?')">
                                        @csrf 
                                        @method('DELETE')
                                        <button type="submit" class="btn btn-outline-danger btn-sm">Delete</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="5" class="text-center py-5 text-muted">
                                No tariffs found. <a href="{{ route('tariffs.create') }}">Create your first one!</a>
                            </td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection