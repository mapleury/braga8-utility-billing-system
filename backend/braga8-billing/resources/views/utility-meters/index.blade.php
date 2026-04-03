@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-6">
    <h1 class="text-3xl font-bold mb-6">Utility Meters</h1>

    <a href="{{ route('utility-meters.create') }}" 
        class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 mb-4 inline-block">
        Add New Meter
    </a>

    @if(session('success'))
        <div class="bg-green-200 text-green-800 p-4 rounded mb-4">
            {{ session('success') }}
        </div>
    @endif

    {{-- SEARCH --}}
    <form method="GET" class="mb-4 flex gap-2">
        <input type="text" name="search" value="{{ request('search') }}"
            placeholder="Search meter / unit / tariff..."
            class="border px-3 py-2 rounded w-full">

        <button class="bg-gray-800 text-white px-4 rounded">
            Search
        </button>
    </form>

    <table class="w-full border-collapse border border-gray-300">
        <thead>
            <tr class="bg-gray-100">
                <th class="border px-4 py-2">Unit</th>
                <th class="border px-4 py-2">Type</th>
                <th class="border px-4 py-2">Meter Number</th>
                <th class="border px-4 py-2">Capacity</th>
                <th class="border px-4 py-2">Tariff</th>
                <th class="border px-4 py-2">Category</th>
                <th class="border px-4 py-2 text-center">Actions</th>
            </tr>
        </thead>

        <tbody>
            @forelse($meters as $meter)
                <tr class="hover:bg-gray-50">

                    {{-- UNIT --}}
                    <td class="border px-4 py-2 font-medium">
                        {{ $meter->unit->unit_number ?? '-' }}
                    </td>

                    {{-- TYPE --}}
                    <td class="border px-4 py-2">
                        <span class="px-2 py-1 text-xs rounded 
                            {{ $meter->meter_type == 'electricity' ? 'bg-yellow-100 text-yellow-700' : 'bg-blue-100 text-blue-700' }}">
                            {{ ucfirst($meter->meter_type) }}
                        </span>
                    </td>

                    {{-- METER NUMBER --}}
                    <td class="border px-4 py-2">
                        {{ $meter->meter_number }}
                    </td>

                    {{-- CAPACITY --}}
                    <td class="border px-4 py-2">
                        {{ $meter->power_capacity ?? '-' }}
                    </td>

                    {{-- TARIFF (NEW RELATION) --}}
                    <td class="border px-4 py-2">
                        {{ $meter->tariff->name ?? '-' }}
                    </td>

                    {{-- CATEGORY --}}
                    <td class="border px-4 py-2">
                        <span class="text-xs px-2 py-1 rounded 
                            {{ $meter->meter_category == 'postpaid' ? 'bg-green-100 text-green-700' : 'bg-purple-100 text-purple-700' }}">
                            {{ ucfirst($meter->meter_category) }}
                        </span>
                    </td>

                    {{-- ACTIONS --}}
                   <td class="border px-4 py-2 flex justify-center gap-2">
    
    {{-- VIEW --}}
    <a href="{{ route('utility-meters.show', $meter->id) }}"
        class="text-sm bg-gray-600 text-white px-3 py-1 rounded">
        View
    </a>

    {{-- EDIT --}}
    <a href="{{ route('utility-meters.edit', $meter->id) }}"
        class="text-sm bg-blue-500 text-white px-3 py-1 rounded">
        Edit
    </a>

    {{-- DELETE --}}
    <form action="{{ route('utility-meters.destroy', $meter->id) }}" method="POST">
        @csrf
        @method('DELETE')

        <button type="submit"
            class="text-sm bg-red-500 text-white px-3 py-1 rounded"
            onclick="return confirm('Are you sure?')">
            Delete
        </button>
    </form>

</td>
                </tr>
            @empty
                <tr>
                    <td colspan="7" class="text-center py-4">
                        No meters found.
                    </td>
                </tr>
            @endforelse
        </tbody>
    </table>

    <div class="mt-4">
        {{ $meters->links() }}
    </div>
</div>
@endsection