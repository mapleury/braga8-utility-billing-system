@extends('layouts.app')

@section('content')
<div class="container">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>Edit Tariff #{{ $tariff->id }}</h2>
        <a href="{{ route('tariffs.index') }}" class="btn btn-outline-secondary">Back to List</a>
    </div>

    @if ($errors->any())
        <div class="alert alert-danger">
            <strong>Check your input!</strong>
            <ul class="mb-0">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('tariffs.update', $tariff->id) }}" method="POST">
        @csrf
        @method('PUT')

        <div class="card mb-4">
            <div class="card-header bg-light"><strong>Primary Pricing</strong></div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-12">
        <label class="form-label">Tariff Name / Label</label>
        <input type="text" name="name" 
               value="{{ old('name', $tariff->name ?? '') }}" 
               class="form-control" 
               placeholder="e.g., Residential Type A" required>
    </div>
</div>
                    <div class="col-md-4 mb-3">
                        <label class="form-label">Water Price</label>
                        <input type="number" name="water_price" step="0.01" value="{{ old('water_price', $tariff->water_price) }}" class="form-control" required>
                    </div>
                    <div class="col-md-4 mb-3">
                        <label class="form-label">Electric Price</label>
                        <input type="number" name="electric_price" step="0.01" value="{{ old('electric_price', $tariff->electric_price) }}" class="form-control" required>
                    </div>
                    <div class="col-md-4 mb-3">
                        <label class="form-label">Tax (%)</label>
                        <input type="number" name="tax_percent" step="0.01" value="{{ old('tax_percent', $tariff->tax_percent) }}" class="form-control">
                    </div>
                </div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header bg-light"><strong>Standard Fees & Maintenance</strong></div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-3 mb-3">
                        <label class="form-label">Electric Load Cost</label>
                        <input type="number" name="electric_load_cost" step="0.01" value="{{ old('electric_load_cost', $tariff->electric_load_cost) }}" class="form-control">
                    </div>
                    <div class="col-md-3 mb-3">
                        <label class="form-label">Maintenance Fee</label>
                        <input type="number" name="transformer_maintenance" step="0.01" value="{{ old('transformer_maintenance', $tariff->transformer_maintenance) }}" class="form-control">
                    </div>
                    <div class="col-md-3 mb-3">
                        <label class="form-label">Admin Fee</label>
                        <input type="number" name="admin_fee" step="0.01" value="{{ old('admin_fee', $tariff->admin_fee) }}" class="form-control">
                    </div>
                    <div class="col-md-3 mb-3">
                        <label class="form-label">Stamp Fee</label>
                        <input type="number" name="stamp_fee" step="0.01" value="{{ old('stamp_fee', $tariff->stamp_fee) }}" class="form-control">
                    </div>
                </div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header bg-light d-flex justify-content-between align-items-center">
                <strong>Additional Fees (Dynamic)</strong>
                <button type="button" id="add-fee-btn" class="btn btn-sm btn-secondary">+ Add Row</button>
            </div>
            <div class="card-body">
                <div id="other-fees-container">
                    @php 
                        $otherFees = old('other_fees', $tariff->other_fees ?? []); 
                    @endphp

                    @forelse($otherFees as $index => $fee)
                        <div class="row mb-2 fee-row">
                            <div class="col-md-5">
                                <input type="text" name="other_fees[{{ $index }}][label]" value="{{ $fee['label'] ?? '' }}" class="form-control" placeholder="Fee Description">
                            </div>
                            <div class="col-md-5">
                                <input type="number" name="other_fees[{{ $index }}][value]" step="0.01" value="{{ $fee['value'] ?? '' }}" class="form-control" placeholder="Amount">
                            </div>
                            <div class="col-md-2">
                                <button type="button" class="btn btn-danger remove-fee w-100">Remove</button>
                            </div>
                        </div>
                    @empty
                        <p class="text-muted text-center no-fees-msg">No additional fees added.</p>
                    @endforelse
                </div>
            </div>
        </div>

        <div class="mt-4 mb-5">
            <button type="submit" class="btn btn-primary btn-lg">Update All Changes</button>
            <a href="{{ route('tariffs.index') }}" class="btn btn-link text-secondary">Discard Changes</a>
        </div>
    </form>
</div>

<script>
    let feeIndex = {{ count(old('other_fees', $tariff->other_fees ?? [])) }};
    
    document.getElementById('add-fee-btn').addEventListener('click', function() {
        const container = document.getElementById('other-fees-container');
        
        // Remove the "No fees" message if it exists
        const noFeesMsg = container.querySelector('.no-fees-msg');
        if (noFeesMsg) noFeesMsg.remove();

        const html = `
            <div class="row mb-2 fee-row">
                <div class="col-md-5">
                    <input type="text" name="other_fees[${feeIndex}][label]" class="form-control" placeholder="Fee Description">
                </div>
                <div class="col-md-5">
                    <input type="number" name="other_fees[${feeIndex}][value]" step="0.01" class="form-control" placeholder="Amount">
                </div>
                <div class="col-md-2">
                    <button type="button" class="btn btn-danger remove-fee w-100">Remove</button>
                </div>
            </div>`;
        container.insertAdjacentHTML('beforeend', html);
        feeIndex++;
    });

    document.addEventListener('click', function(e) {
        if (e.target && e.target.classList.contains('remove-fee')) {
            e.target.closest('.fee-row').remove();
        }
    });
</script>
@endsection