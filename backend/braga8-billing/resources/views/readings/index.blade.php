@extends('layouts.app')

@section('content')

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<div class="container mt-5">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3">Meter Readings by Tenant</h1>
        <a href="{{ route('meter-readings.create') }}" class="btn btn-primary">
            + Add Reading
        </a>
    </div>

    @foreach($tenants as $tenant)
        <div class="card mb-4 shadow-sm">
            <div class="card-header bg-light d-flex justify-content-between">
                <strong>{{ $tenant->tenant_name }}</strong>
                <span class="text-muted">{{ $tenant->units->count() }} Units</span>
            </div>

            <div class="card-body p-0">

                @forelse($tenant->units as $unit)
                    <div class="p-3 border-bottom">
                        <h6 class="mb-3">
                            Unit: {{ $unit->unit_number }}
                        </h6>

                        @php
                            $hasReadings = false;
                        @endphp

                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Meter</th>
                                        <th>Type</th>
                                        <th>Reading</th>
                                        <th>Description</th>
                                        <th>Photo</th>
                                        <th>Status</th>
                                        <th>Recorded At</th>
                                        <th>User</th>
                                    </tr>
                                </thead>
                                <tbody>

                                @foreach($unit->meters as $meter)
                                    @foreach($meter->readings as $reading)
                                        @php $hasReadings = true; @endphp

                                        <tr>
                                            <td>{{ $meter->meter_number }}</td>
                                            <td>{{ ucfirst($meter->meter_type) }}</td>
                                            <td>{{ number_format($reading->reading_value, 2) }}</td>

                                            <td>{{ $reading->description ?? '-' }}</td>

                                            <td>
                                             @if($reading->photo_path)
    <button 
        class="btn btn-sm btn-info"
        data-bs-toggle="modal"
        data-bs-target="#photoModal"
        onclick="showImage('{{ asset('storage/'.$reading->photo_path) }}')"
    >
        View
    </button>
@else
    <span class="text-muted">No photo</span>
@endif
                                            </td>

                                            {{-- STATUS TOGGLE --}}
                                            <td>
                                                <form action="{{ route('meter-readings.update-status', $reading->id) }}" method="POST">
                                                    @csrf
                                                    @method('PATCH')

                                                    <input 
                                                        type="checkbox"
                                                        onchange="this.form.submit()"
                                                        {{ $reading->status === 'checked' ? 'checked' : '' }}
                                                    >
                                                </form>
                                            </td>

                                            <td>
                                                {{ \Carbon\Carbon::parse($reading->recorded_at)->format('d M Y') }}
                                            </td>

                                            <td>{{ $reading->user->name }}</td>
                                        </tr>
                                    @endforeach
                                @endforeach

                                @if(!$hasReadings)
                                    <tr>
                                        <td colspan="8" class="text-center text-muted py-3">
                                            No readings for this unit.
                                        </td>
                                    </tr>
                                @endif

                                </tbody>
                            </table>
                        </div>
                    </div>
                @empty
                    <div class="p-3 text-muted">
                        No units for this tenant.
                    </div>
                @endforelse

            </div>
        </div>
        <!-- IMAGE MODAL -->
<div class="modal fade" id="photoModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">

            <div class="modal-header">
                <h5 class="modal-title">Meter Photo</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body text-center">
                <img id="modalImage" src="" class="img-fluid rounded">
            </div>

        </div>
    </div>
</div>

<script>
    function showImage(src) {
        document.getElementById('modalImage').src = src;
    }
</script>
    @endforeach

</div>

@endsection