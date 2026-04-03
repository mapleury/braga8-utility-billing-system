@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-6">

    {{-- HEADER --}}
    <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold">Meter Detail</h1>

        <div class="flex gap-2">
            <a href="{{ route('utility-meters.index') }}"
                class="bg-gray-500 text-white px-4 py-2 rounded">
                Back
            </a>

            <a href="{{ route('utility-meters.edit', $meter->id) }}"
                class="bg-blue-600 text-white px-4 py-2 rounded">
                Edit
            </a>
        </div>
    </div>

    {{-- CARD --}}
    <div class="bg-white shadow rounded-lg p-6">

        <div class="grid grid-cols-2 gap-6">

            {{-- UNIT --}}
            <div>
                <p class="text-sm text-gray-500">Unit</p>
                <p class="text-lg font-semibold">
                    {{ $meter->unit->unit_number ?? '-' }}
                </p>
            </div>

            {{-- TYPE --}}
            <div>
                <p class="text-sm text-gray-500">Meter Type</p>
                <span class="px-2 py-1 text-xs rounded 
                    {{ $meter->meter_type == 'electricity' ? 'bg-yellow-100 text-yellow-700' : 'bg-blue-100 text-blue-700' }}">
                    {{ ucfirst($meter->meter_type) }}
                </span>
            </div>

            {{-- METER NUMBER --}}
            <div>
                <p class="text-sm text-gray-500">Meter Number</p>
                <p class="text-lg">
                    {{ $meter->meter_number }}
                </p>
            </div>

            {{-- CAPACITY --}}
            <div>
                <p class="text-sm text-gray-500">Power Capacity</p>
                <p class="text-lg">
                    {{ $meter->power_capacity ?? '-' }}
                </p>
            </div>

            {{-- TARIFF --}}
            <div>
                <p class="text-sm text-gray-500">Tariff</p>
                <p class="text-lg font-medium">
                    {{ $meter->tariff->name ?? '-' }}
                </p>
            </div>

            {{-- CATEGORY --}}
            <div>
                <p class="text-sm text-gray-500">Meter Category</p>
                <span class="text-xs px-2 py-1 rounded 
                    {{ $meter->meter_category == 'postpaid' ? 'bg-green-100 text-green-700' : 'bg-purple-100 text-purple-700' }}">
                    {{ ucfirst($meter->meter_category) }}
                </span>
            </div>

        </div>

    </div>

</div>
@endsection