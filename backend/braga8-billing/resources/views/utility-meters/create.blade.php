@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-6">
    <h1 class="text-3xl font-bold mb-6">Add New Utility Meter</h1>

    <form action="{{ route('utility-meters.store') }}" method="POST">
        @csrf
        <div class="mb-4">
            <label class="block mb-1 font-semibold">Unit</label>
            <select name="unit_id" class="border p-2 w-full">
                @foreach($units as $unit)
                    <option value="{{ $unit->id }}">{{ $unit->unit_number }} - {{ $unit->floor ?? '' }}</option>
                @endforeach
            </select>
            @error('unit_id') <p class="text-red-500">{{ $message }}</p> @enderror
        </div>

        <div class="mb-4">
            <label class="block mb-1 font-semibold">Meter Type</label>
            <select name="meter_type" class="border p-2 w-full">
                <option value="electricity">Electricity</option>
                <option value="water">Water</option>
            </select>
            @error('meter_type') <p class="text-red-500">{{ $message }}</p> @enderror
        </div>

        <div class="mb-4">
            <label class="block mb-1 font-semibold">Meter Number</label>
            <input type="text" name="meter_number" class="border p-2 w-full" value="{{ old('meter_number') }}">
            @error('meter_number') <p class="text-red-500">{{ $message }}</p> @enderror
        </div>

        <div class="mb-4">
            <label class="block mb-1 font-semibold">Power Capacity (optional)</label>
            <input type="text" name="power_capacity" class="border p-2 w-full" value="{{ old('power_capacity') }}">
        </div>
        <div class="form-group mt-3">
    <label for="multiplier">Faktor Kali (Multiplier)</label>
    <div class="input-group">
        <input type="number" step="0.01" name="multiplier" id="multiplier" 
               class="form-control bg-light" value="{{ $meter->multiplier ?? 1.00 }}" readonly>
        <div class="input-group-append">
            <button type="button" class="btn btn-outline-danger" onclick="unlockField()">
                <i class="fas fa-lock"></i> Unlock to Edit
            </button>
        </div>
    </div>
    <small class="text-danger">*Hanya ubah jika meteran memiliki faktor kali khusus (CT/PT).</small>
</div>

<script>
function unlockField() {
    // Simple baby-step: ask for a password
    let password = prompt("Masukkan Password Admin untuk akses Multiplier:");
    if (password === "BRAGA8ADMIN") { // Change this to your desired password
        document.getElementById('multiplier').readOnly = false;
        document.getElementById('multiplier').classList.remove('bg-light');
        alert("Akses dibuka! Silahkan edit multiplier.");
    } else {
        alert("Password salah. Akses ditolak.");
    }
}
</script>

<div class="mb-4">
    <label class="block mb-1 font-semibold">Tariff Group</label>
    <select name="tariff_id" class="border p-2 w-full">
        <option value="">-- Select Tariff --</option>
        @foreach($tariffs as $tariff)
            <option value="{{ $tariff->id }}" {{ old('tariff_id') == $tariff->id ? 'selected' : '' }}>
                {{ $tariff->name }} 
                (Elec: Rp {{ number_format($tariff->electric_price) }} | Water: Rp {{ number_format($tariff->water_price) }})
            </option>
        @endforeach
    </select>
    @error('tariff_id') 
        <p class="text-red-500">{{ $message }}</p> 
    @enderror
</div>

        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">Save Meter</button>
    </form>
</div>
@endsection