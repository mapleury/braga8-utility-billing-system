@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-6">
    <h1 class="text-3xl font-bold mb-6">Add Meter Reading</h1>

    <form action="{{ route('meter-readings.store') }}" method="POST" enctype="multipart/form-data">
        @csrf

        <div class="mb-4">
            <label class="block mb-1 font-semibold">Meter</label>
            <select name="meter_id" class="border p-2 w-full">
                @foreach($meters as $meter)
                    <option value="{{ $meter->id }}">
                        {{ $meter->unit->unit_number ?? '-' }} - {{ ucfirst($meter->meter_type) }} - {{ $meter->meter_number }}
                    </option>
                @endforeach
            </select>
            @error('meter_id') <p class="text-red-500">{{ $message }}</p> @enderror
        </div>

        <div class="mb-4">
            <label class="block mb-1 font-semibold">Reading Value</label>
            <input 
                type="number" 
                step="0.01" 
                name="reading_value" 
                class="border p-2 w-full" 
                value="{{ old('reading_value') }}"
            >
            @error('reading_value') <p class="text-red-500">{{ $message }}</p> @enderror
        </div>

        <div class="mb-4">
            <label class="block mb-1 font-semibold">Description</label>
            <textarea 
                name="description" 
                rows="3"
                class="border p-2 w-full"
                placeholder="Optional notes... (e.g., meter slightly foggy, estimated reading, etc.)"
            >{{ old('description') }}</textarea>
            @error('description') <p class="text-red-500">{{ $message }}</p> @enderror
        </div>

        <div class="mb-4">
            <label class="block mb-1 font-semibold">Photo of Meter</label>
            <input 
                type="file" 
                name="photo" 
                accept="image/*" 
                class="border p-2 w-full"
            >
            @error('photo') <p class="text-red-500">{{ $message }}</p> @enderror
        </div>

        <button 
            type="submit" 
            class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
        >
            Save Reading
        </button>
    </form>
</div>
@endsection