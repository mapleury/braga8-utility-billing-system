@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-6">
    <h1 class="text-3xl font-bold mb-6">Add Meter Reading</h1>

    @if($errors->any())
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
            <ul>
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form id="meterForm" action="{{ route('meter-readings.store') }}" method="POST" enctype="multipart/form-data">
        @csrf

        <input type="hidden" name="latitude" id="lat">
        <input type="hidden" name="longitude" id="lng">

        <div class="mb-4">
            <label class="block mb-1 font-semibold">Meter</label>
            <select name="meter_id" class="border p-2 w-full">
                @foreach($meters as $meter)
                    <option value="{{ $meter->id }}" {{ old('meter_id') == $meter->id ? 'selected' : '' }}>
                        {{ $meter->unit->unit_number ?? '-' }} - {{ ucfirst($meter->meter_type) }} - {{ $meter->meter_number }}
                    </option>
                @endforeach
            </select>
        </div>

        <div class="mb-4">
            <label class="block mb-1 font-semibold">Reading Value</label>
            <input 
                type="number" 
                step="0.01" 
                name="reading_value" 
                class="border p-2 w-full" 
                value="{{ old('reading_value') }}"
                required
            >
        </div>

        <div class="mb-4">
            <label class="block mb-1 font-semibold">Description</label>
            <textarea 
                name="description" 
                rows="3"
                class="border p-2 w-full"
                placeholder="Optional notes..."
            >{{ old('description') }}</textarea>
        </div>

        <div class="mb-4">
            <label class="block mb-1 font-semibold">Photo of Meter</label>
            <input 
                type="file" 
                name="photo" 
                accept="image/*" 
                class="border p-2 w-full"
                required
            >
        </div>

        <button 
            type="submit" 
            id="submitBtn"
            class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 disabled:bg-gray-400"
        >
            <span id="btnText">Save Reading</span>
        </button>
    </form>
</div>
<script>
    const form = document.getElementById('meterForm');
    const btn = document.getElementById('submitBtn');
    const btnText = document.getElementById('btnText');

    form.addEventListener('submit', function(e) {
        e.preventDefault(); 
        
        btn.disabled = true;
        btnText.innerText = "Connecting to Satellite...";

        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                function(position) {
                    // Pastikan ID ini SAMA dengan ID di input hidden
                    document.getElementById('lat').value = position.coords.latitude;
                    document.getElementById('lng').value = position.coords.longitude; 
                    
                    console.log("Location Captured: ", position.coords.latitude, position.coords.longitude);
                    
                    btnText.innerText = "Uploading Data...";
                    form.submit(); // SEKARANG BARU SUBMIT
                },
                function(error) {
                    // Tampilkan error lebih spesifik biar kita tau kenapa
                    let msg = "";
                    switch(error.code) {
                        case error.PERMISSION_DENIED:
                            msg = "User denied the request for Geolocation.";
                            break;
                        case error.POSITION_UNAVAILABLE:
                            msg = "Location information is unavailable.";
                            break;
                        case error.TIMEOUT:
                            msg = "The request to get user location timed out.";
                            break;
                    }
                    alert("Gagal ambil lokasi: " + msg);
                    btn.disabled = false;
                    btnText.innerText = "Save Reading";
                },
                { 
                    enableHighAccuracy: true, // Biar lebih akurat
                    timeout: 10000,           // Kasih waktu 10 detik
                    maximumAge: 0             // Jangan pake cache lokasi lama
                }
            );
        } else {
            alert("Browser tidak mendukung Geolocation.");
            form.submit();
        }
    });
</script>
@endsection