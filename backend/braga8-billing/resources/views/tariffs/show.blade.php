@extends('layouts.app')

@section('content')
<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-dark">{{ $tariff->name ?? 'Unnamed Tariff' }}</h2>
            <p class="text-muted">Detailed breakdown of tariff configurations.</p>
        </div>
        <div class="btn-group">
            <a href="{{ route('tariffs.index') }}" class="btn btn-outline-secondary">
                <i class="fas fa-arrow-left"></i> Back
            </a>
            <a href="{{ route('tariffs.edit', $tariff->id) }}" class="btn btn-warning">
                <i class="fas fa-edit"></i> Edit Tariff
            </a>
        </div>
    </div>

    <div class="row">
        <div class="col-md-8">
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-white py-3">
                    <h5 class="mb-0 fw-bold"><i class="fas fa-tint text-primary me-2"></i> Primary Consumption Rates</h5>
                </div>
                <div class="card-body">
                    <div class="row text-center">
                        <div class="col-md-4 border-end">
                            <label class="text-uppercase small fw-bold text-muted d-block">Water Price</label>
                            <span class="fs-4 fw-bold">Rp {{ number_format($tariff->water_price, 2) }}</span>
                        </div>
                        <div class="col-md-4 border-end">
                            <label class="text-uppercase small fw-bold text-muted d-block">Electric Price</label>
                            <span class="fs-4 fw-bold">Rp {{ number_format($tariff->electric_price, 2) }}</span>
                        </div>
                        <div class="col-md-4">
                            <label class="text-uppercase small fw-bold text-muted d-block">Tax Rate</label>
                            <span class="fs-4 fw-bold text-danger">{{ $tariff->tax_percent }}%</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white py-3">
                    <h5 class="mb-0 fw-bold"><i class="fas fa-file-invoice-dollar text-success me-2"></i> Standard Fixed Fees</h5>
                </div>
                <ul class="list-group list-group-flush">
                    <li class="list-group-item d-flex justify-content-between align-items-center py-3">
                        <span>Electric Load Cost</span>
                        <span class="fw-bold">Rp {{ number_format($tariff->electric_load_cost, 2) }}</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center py-3">
                        <span>Transformer Maintenance</span>
                        <span class="fw-bold">Rp {{ number_format($tariff->transformer_maintenance, 2) }}</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center py-3">
                        <span>Administrative Fee</span>
                        <span class="fw-bold">Rp {{ number_format($tariff->admin_fee, 2) }}</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center py-3">
                        <span>Stamp Duty (Materai)</span>
                        <span class="fw-bold">Rp {{ number_format($tariff->stamp_fee, 2) }}</span>
                    </li>
                </ul>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card border-0 shadow-sm bg-light">
                <div class="card-header bg-dark text-white py-3">
                    <h5 class="mb-0 fw-bold small text-uppercase">Other Custom Fees</h5>
                </div>
                <div class="card-body p-0">
                    @if(!empty($tariff->other_fees) && count($tariff->other_fees) > 0)
                        <table class="table table-sm mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th class="ps-3">Context</th>
                                    <th class="text-end pe-3">Value</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($tariff->other_fees as $fee)
                                <tr>
                                    <td class="ps-3 py-2 text-muted">{{ $fee['label'] }}</td>
                                    <td class="text-end pe-3 py-2 fw-bold">Rp {{ number_format($fee['value'], 2) }}</td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    @else
                        <div class="p-4 text-center">
                            <i class="fas fa-info-circle text-muted mb-2"></i>
                            <p class="text-muted small mb-0">No additional fees configured for this tariff.</p>
                        </div>
                    @endif
                </div>
                <div class="card-footer bg-white border-0 py-3 text-center">
                    <small class="text-muted">Last updated: {{ $tariff->updated_at->format('d M Y, H:i') }}</small>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection