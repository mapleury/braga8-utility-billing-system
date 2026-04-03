@extends('layouts.app')
@section('content')

<h1 class="text-xl font-bold mb-4">Generate Invoice</h1>

    {{-- THIS BOX MUST SHOW UP IF THE CONTROLLER REDIRECTS --}}
    @if ($errors->any())
        <div class="mb-6 p-4 bg-rose-100 border-l-4 border-rose-500 text-rose-700">
            <p class="font-bold">Validation Error:</p>
            <ul class="list-disc list-inside">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

<div class="bg-white p-6 shadow rounded">
    <form action="{{ route('invoices.store') }}" method="POST" id="invoiceForm">
        @csrf
        
        {{-- 1. Tenant Selection --}}
        <div class="mb-4">
            <label class="block font-bold mb-1">Tenant</label>
            <select name="tenant_id" id="tenant_select" class="border rounded px-3 py-2 w-full focus:ring-2 focus:ring-blue-500" required>
                <option value="">-- Select Tenant --</option>
                @foreach($tenants as $tenant)
                    <option value="{{ $tenant->id }}">{{ $tenant->tenant_name }}</option>
                @endforeach
            </select>
        </div>

        {{-- 2. Unit Selection --}}
        <div class="mb-4">
            <label class="block font-bold mb-1">Unit</label>
            <select name="unit_id" id="unit_select" class="border rounded px-3 py-2 w-full focus:ring-2 focus:ring-blue-500" required>
                <option value="">-- Select Unit --</option>
                @foreach($units as $unit)
                    <option value="{{ $unit->id }}" data-tenant="{{ $unit->tenant_id }}">
                        {{ $unit->unit_number }} (Floor {{ $unit->floor }})
                    </option>
                @endforeach
            </select>
            <p class="text-xs text-gray-500 mt-1">Meter readings must be recorded for this unit before generating.</p>
        </div>

        <hr class="my-6 border-gray-100">

        {{-- 3. Billing Context (New) --}}
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
            <div>
                <label class="block font-bold mb-1">Billing Period</label>
                <input type="text" class="bg-gray-100 border rounded px-3 py-2 w-full" 
                       value="{{ now()->translatedFormat('F Y') }}" readonly>
                <small class="text-gray-400">Current month is selected by default.</small>
            </div>

            {{-- 4. Editable Other Fees (As requested by TOR) --}}
            <div>
                <label class="block font-bold mb-1 text-blue-600">Manual Fee (Lain-lain)</label>
                <div class="relative">
                    <span class="absolute left-3 top-2 text-gray-500">Rp</span>
                    <input type="number" name="manual_other_fee" class="border rounded pl-10 pr-3 py-2 w-full" 
                           placeholder="0" min="0">
                </div>
                <small class="text-gray-400">Optional: Overrides the default tariff 'Other Fee'.</small>
            </div>
        </div>

        <div class="mt-8">
            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-bold px-6 py-2 rounded shadow-lg transition duration-200">
                Generate & Save Invoice
            </button>
            <a href="{{ route('invoices.index') }}" class="ml-4 text-gray-600 hover:underline">Cancel</a>
        </div>
    </form>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const tenantSelect = document.getElementById('tenant_select');
    const unitSelect = document.getElementById('unit_select');
    const allUnitOptions = Array.from(unitSelect.options).filter(opt => opt.value !== "");

    // Logic: If Tenant changes -> Filter Units
    tenantSelect.addEventListener('change', function () {
        const selectedTenantId = this.value;
        unitSelect.value = "";

        allUnitOptions.forEach(option => {
            if (!selectedTenantId || option.dataset.tenant === selectedTenantId) {
                option.hidden = false;
                option.disabled = false;
            } else {
                option.hidden = true;
                option.disabled = true;
            }
        });
    });

    // Logic: If Unit changes -> Auto-select Tenant
    unitSelect.addEventListener('change', function () {
        const selectedOption = this.options[this.selectedIndex];
        const tenantId = selectedOption.dataset.tenant;

        if (tenantId) {
            tenantSelect.value = tenantId;
            // Optionally filter units list to match the newly selected tenant
            allUnitOptions.forEach(option => {
                if (option.dataset.tenant === tenantId) {
                    option.hidden = false;
                    option.disabled = false;
                } else {
                    option.hidden = true;
                    option.disabled = true;
                }
            });
        }
    });
});
</script>

@endsection