@extends('layouts.app')

@section('content')
<div class="container">
    <h2>Add New Tariff</h2>
    <hr>

    <form action="{{ route('tariffs.store') }}" method="POST">
        @csrf

        <div class="row mb-3">

    <div class="col-md-12">
        <label class="form-label">Tariff Name / Label</label>
        <input type="text" name="name" 
               value="{{ old('name', $tariff->name ?? '') }}" 
               class="form-control" 
               placeholder="e.g., Residential Type A" required>
    </div>
</div>
            <div class="col-md-4">
                <label class="form-label">Water Price</label>
                <input type="number" name="water_price" step="0.01" class="form-control" required>
            </div>
            <div class="col-md-4">
                <label class="form-label">Electric Price</label>
                <input type="number" name="electric_price" step="0.01" class="form-control" required>
            </div>
            <div class="col-md-4">
                <label class="form-label">Tax (%)</label>
                <input type="number" name="tax_percent" step="0.01" class="form-control" value="0">
            </div>
        </div>

        <div class="row mb-3">
            <div class="col-md-3">
                <label class="form-label">Electric Load Cost</label>
                <input type="number" name="electric_load_cost" class="form-control" value="0">
            </div>
            <div class="col-md-3">
                <label class="form-label">Maintenance</label>
                <input type="number" name="transformer_maintenance" class="form-control" value="0">
            </div>
            <div class="col-md-3">
                <label class="form-label">Admin Fee</label>
                <input type="number" name="admin_fee" class="form-control" value="0">
            </div>
            <div class="col-md-3">
                <label class="form-label">Stamp Fee</label>
                <input type="number" name="stamp_fee" class="form-control" value="0">
            </div>
        </div>

        <hr>
        <h4>Other Fees (Optional)</h4>
        <p class="text-muted">You can add multiple custom fees below. These are not required.</p>
        
        <div id="other-fees-container">
            </div>

        <button type="button" id="add-fee-btn" class="btn btn-outline-secondary mb-4">
            + Add Other Fee
        </button>

        <div class="mt-3">
            <button type="submit" class="btn btn-success btn-lg">Save Tariff</button>
            <a href="{{ route('tariffs.index') }}" class="btn btn-light btn-lg">Cancel</a>
        </div>
    </form>
</div>

<script>
    let feeIndex = 0;

    document.getElementById('add-fee-btn').addEventListener('click', function() {
        const container = document.getElementById('other-fees-container');
        
        // Create a wrapper div for the new row
        const row = document.createElement('div');
        row.className = 'row mb-2 fee-row';
        row.innerHTML = `
            <div class="col-md-5">
                <input type="text" name="other_fees[${feeIndex}][label]" 
                       class="form-control" placeholder="Context (e.g. Cleaning Fee)">
            </div>
            <div class="col-md-5">
                <input type="number" name="other_fees[${feeIndex}][value]" 
                       step="0.01" class="form-control" placeholder="Amount">
            </div>
            <div class="col-md-2">
                <button type="button" class="btn btn-danger remove-fee w-100">Remove</button>
            </div>
        `;
        
        container.appendChild(row);
        feeIndex++;
    });

    // Handle Removing rows
    document.addEventListener('click', function(e) {
        if (e.target && e.target.classList.contains('remove-fee')) {
            e.target.closest('.fee-row').remove();
        }
    });
</script>
@endsection