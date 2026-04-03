@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8">
    {{-- Header Section --}}
    <div class="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
            <h1 class="text-3xl font-extrabold text-gray-900 dark:text-white tracking-tight">
                Monthly Usage Reports
            </h1>
            <p class="text-gray-500 dark:text-gray-400 mt-1">Consumption and Revenue Analytics for Braga 8.</p>
        </div>
        
        {{-- Generate Report Form --}}
        <form action="{{ route('reports.generate') }}" method="POST" class="flex items-center gap-2">
            @csrf
            <input type="month" name="month" required 
                   class="rounded-xl border-gray-300 dark:border-gray-700 dark:bg-gray-800 dark:text-white focus:ring-indigo-500 focus:border-indigo-500">
            <button type="submit" 
                    class="inline-flex items-center px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold rounded-xl shadow-lg shadow-indigo-500/30 transition-all transform hover:-translate-y-1">
                <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/></svg>
                Generate Report
            </button>
        </form>
    </div>

    {{-- Stats Overview (Latest Report Summary) --}}
    @if($reports->count() > 0)
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        @php $latest = $reports->first(); @endphp
        <div class="bg-white dark:bg-gray-800 p-6 rounded-2xl border border-gray-100 dark:border-gray-700 shadow-xl">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Total Expected Revenue ({{ $latest->month_year }})</p>
            <p class="text-2xl font-bold text-indigo-600 dark:text-indigo-400 mt-1">Rp {{ number_format($latest->total_revenue_expected) }}</p>
        </div>
        <div class="bg-white dark:bg-gray-800 p-6 rounded-2xl border border-gray-100 dark:border-gray-700 shadow-xl">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Total Electricity Usage</p>
            <p class="text-2xl font-bold text-amber-500 mt-1">{{ number_format($latest->total_electric_usage) }} kWh</p>
        </div>
        <div class="bg-white dark:bg-gray-800 p-6 rounded-2xl border border-gray-100 dark:border-gray-700 shadow-xl">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Total Water Usage</p>
            <p class="text-2xl font-bold text-blue-500 mt-1">{{ number_format($latest->total_water_usage) }} m³</p>
        </div>
    </div>
    @endif

    {{-- Reports Table --}}
    <div class="bg-white dark:bg-gray-800 shadow-2xl rounded-2xl border border-gray-100 dark:border-gray-700 overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead class="bg-gray-50 dark:bg-gray-900/50">
                <tr>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Month / Year</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Units Billed</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Electricity (kWh)</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Water (m³)</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Total Revenue</th>
                    <th class="px-6 py-4 text-right text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Action</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100 dark:divide-gray-700">
                @forelse($reports as $report)
                <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                    <td class="px-6 py-4 whitespace-nowrap font-bold text-gray-900 dark:text-white">
                        {{ \Carbon\Carbon::parse($report->month_year)->format('F Y') }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-gray-300">
                        {{ $report->total_units_billed }} Units
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-amber-600 font-medium">
                        {{ number_format($report->total_electric_usage) }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-blue-600 font-medium">
                        {{ number_format($report->total_water_usage) }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-gray-900 dark:text-white">
                        Rp {{ number_format($report->total_revenue_expected) }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-right">
                        <a href="{{ route('reports.pdf', $report->id) }}" 
                           class="inline-flex items-center px-4 py-2 bg-rose-50 text-rose-600 hover:bg-rose-600 hover:text-white rounded-lg text-sm font-bold transition-all border border-rose-200">
                            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                            Export PDF
                        </a>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="6" class="px-6 py-10 text-center text-gray-500 italic">
                        No reports generated yet. Use the selector above to start.
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection