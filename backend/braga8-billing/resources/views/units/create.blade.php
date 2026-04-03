@extends('layouts.app')

@section('content')

<div class="container mt-5">
    <h1 class="h3 mb-4">Add Unit</h1>

    @if(session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @endif

    <form method="POST" action="{{ route('units.store') }}" class="bg-white p-4 shadow rounded">
        @csrf

        <div class="mb-3">
            <label>Unit Number</label>
            <input name="unit_number" class="form-control" value="{{ old('unit_number') }}">
            @error('unit_number') <span class="text-danger">{{ $message }}</span> @enderror
        </div>

        <div class="mb-3">
            <label>Tenant</label>
            <select name="tenant_id" class="form-select">
                @foreach($tenants as $tenant)
                    <option value="{{ $tenant->id }}" {{ old('tenant_id') == $tenant->id ? 'selected' : '' }}>
                        {{ $tenant->tenant_name }}
                    </option>
                @endforeach
            </select>
            @error('tenant_id') <span class="text-danger">{{ $message }}</span> @enderror
        </div>

        <div class="mb-3">
            <label>Floor</label>
            <input name="floor" class="form-control" value="{{ old('floor') }}">
            @error('floor') <span class="text-danger">{{ $message }}</span> @enderror
        </div>

        <div class="mb-3">
            <label>Area Size (m²)</label>
            <input name="area_size" type="number" class="form-control" value="{{ old('area_size') }}">
            @error('area_size') <span class="text-danger">{{ $message }}</span> @enderror
        </div>

        <div class="mb-3">
            <label>Status</label>
            <select name="is_active" class="form-select">
                <option value="1" {{ old('is_active') == 1 ? 'selected' : '' }}>Active</option>
                <option value="0" {{ old('is_active') == 0 ? 'selected' : '' }}>Inactive</option>
            </select>
            @error('is_active') <span class="text-danger">{{ $message }}</span> @enderror
        </div>

        <div class="mb-3">
            <label>Lease Start</label>
            <input name="lease_start" type="date" class="form-control" value="{{ old('lease_start') }}">
            @error('lease_start') <span class="text-danger">{{ $message }}</span> @enderror
        </div>

        <div class="mb-3">
            <label>Lease End</label>
            <input name="lease_end" type="date" class="form-control" value="{{ old('lease_end') }}">
            @error('lease_end') <span class="text-danger">{{ $message }}</span> @enderror
        </div>

        <button type="submit" class="btn btn-primary">Save Unit</button>
    </form>
</div>

@endsection