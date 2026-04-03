@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-6">
    <div class="flex items-center justify-between mb-6">
        <h1 class="text-3xl font-bold">Edit Utility Meter</h1>
        <a href="{{ route('utility-meters.index') }}" class="text-blue-600 hover:underline">&larr; Back to List</a>
    </div>

    <form action="{{ route('utility-meters.update', $utilityMeter->id) }}" method="POST" class="bg-white p-6 rounded shadow-md">
        @csrf
        @method('PUT')

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            {{-- Unit Selection --}}
            <div class="mb-4">
                <label class="block mb-1 font-semibold">Unit</label>
                <select name="unit_id" class="border p-2 w-full rounded @error('unit_id') border-red-500 @enderror">
                    @foreach($units as $unit)
                        <option value="{{ $unit->id }}" 
                            {{ (old('unit_id', $utilityMeter->unit_id) == $unit->id) ? 'selected' : '' }}>
                            {{ $unit->unit_number }} - {{ $unit->floor ?? 'No Floor' }}
                        </option>
                    @endforeach
                </select>
                @error('unit_id') <p class="text-red-500 text-sm mt-1">{{ $message }}</p> @enderror
            </div>

            {{-- Meter Type --}}
            <div class="mb-4">
                <label class="block mb-1 font-semibold">Meter Type</label>
                <select name="meter_type" class="border p-2 w-full rounded @error('meter_type') border-red-500 @enderror">
                    <option value="electricity" {{ old('meter_type', $utilityMeter->meter_type) == 'electricity' ? 'selected' : '' }}>Electricity</option>
                    <option value="water" {{ old('meter_type', $utilityMeter->meter_type) == 'water' ? 'selected' : '' }}>Water</option>
                </select>
                @error('meter_type') <p class="text-red-500 text-sm mt-1">{{ $message }}</p> @enderror
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            {{-- Meter Number --}}
            <div class="mb-4">
                <label class="block mb-1 font-semibold">Meter Number</label>
                <input type="text" name="meter_number" class="border p-2 w-full rounded" value="{{ old('meter_number', $utilityMeter->meter_number) }}">
                @error('meter_number') <p class="text-red-500 text-sm mt-1">{{ $message }}</p> @enderror
            </div>

            {{-- Power Capacity --}}
            <div class="mb-4">
                <label class="block mb-1 font-semibold">Power Capacity (Optional)</label>
                <input type="text" name="power_capacity" class="border p-2 w-full rounded" value="{{ old('power_capacity', $utilityMeter->power_capacity) }}">
            </div>
        </div>

        {{-- Tariff Group - THE FIX IS HERE --}}
        <div class="mb-4">
            <label class="block mb-1 font-semibold text-blue-700">Tariff Group (Required for Auto-Billing)</label>
            <select name="tariff_id" class="border-2 border-blue-200 p-2 w-full rounded focus:border-blue-500">
                <option value="">-- Select Tariff --</option>
                @foreach($tariffs as $tariff)
                    <option value="{{ $tariff->id }}"
                        {{ (old('tariff_id', $utilityMeter->tariff_id) == $tariff->id) ? 'selected' : '' }}>
                        
                        {{ $tariff->name }} 
                        (Elec: Rp {{ number_format($tariff->electric_price) }} | Water: Rp {{ number_format($tariff->water_price) }})
                    
                    </option>
                @endforeach
            </select>
            @error('tariff_id') 
                <p class="text-red-500 text-sm mt-1">{{ $message }}</p> 
            @enderror
        </div>

        {{-- Meter Category --}}
        <div class="mb-6">
            <label class="block mb-1 font-semibold">Meter Category</label>
            <select name="meter_category" class="border p-2 w-full rounded">
                <option value="postpaid" {{ old('meter_category', $utilityMeter->meter_category) == 'postpaid' ? 'selected' : '' }}>Postpaid</option>
                <option value="prepaid" {{ old('meter_category', $utilityMeter->meter_category) == 'prepaid' ? 'selected' : '' }}>Prepaid</option>
            </select>
        </div>

        <div class="flex gap-2">
            <button type="submit" class="bg-blue-600 text-white px-6 py-2 rounded font-bold hover:bg-blue-700 transition">
                Update Meter Settings
            </button>
            <a href="{{ route('utility-meters.index') }}" class="bg-gray-200 text-gray-700 px-6 py-2 rounded hover:bg-gray-300 transition">
                Cancel
            </a>
        </div>
    </form>
</div>
@endsection