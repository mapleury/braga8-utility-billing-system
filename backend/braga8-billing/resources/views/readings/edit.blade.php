@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-6 max-w-xl">
    <h1 class="text-3xl font-bold mb-6">Edit Meter Reading</h1>

    @if ($errors->any())
        <div class="bg-red-200 text-red-800 p-4 rounded mb-4">
            <ul class="list-disc pl-5">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('meter-readings.update', $reading->id) }}" method="POST" enctype="multipart/form-data" class="space-y-4">
        @csrf
        @method('PUT')

        <div>
            <label for="meter_id" class="block mb-1 font-semibold">Meter</label>
            <select name="meter_id" id="meter_id" class="w-full border px-3 py-2 rounded">
                @foreach($meters as $meter)
                    <option value="{{ $meter->id }}" {{ $reading->meter_id == $meter->id ? 'selected' : '' }}>
                        {{ $meter->name }} - Unit {{ $meter->unit->number ?? 'N/A' }}
                    </option>
                @endforeach
            </select>
        </div>

        <div>
            <label for="reading_value" class="block mb-1 font-semibold">Reading Value</label>
            <input type="number" step="0.01" name="reading_value" id="reading_value" value="{{ old('reading_value', $reading->reading_value) }}" class="w-full border px-3 py-2 rounded">
        </div>

        <div>
            <label class="block mb-1 font-semibold">Current Photo</label>
            <img src="{{ asset('storage/' . $reading->photo_path) }}" alt="Meter Photo" class="w-32 h-32 object-cover rounded mb-2">
        </div>

        <div>
            <label for="photo" class="block mb-1 font-semibold">Replace Photo (optional)</label>
            <input type="file" name="photo" id="photo" accept="image/*" class="w-full border px-3 py-2 rounded">
        </div>

        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">Update Reading</button>
        <a href="{{ route('meter-readings.index') }}" class="ml-2 text-gray-600 hover:underline">Cancel</a>
    </form>
</div>
@endsection