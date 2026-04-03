@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8">
    <div class="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
            <h1 class="text-3xl font-extrabold text-gray-900 dark:text-white tracking-tight">
                Complaints & Reports
            </h1>
            <p class="text-gray-500 dark:text-gray-400 mt-1">Manage and track issues reported by tenants or staff.</p>
        </div>
        <a href="{{ route('complaints.create') }}" 
           class="inline-flex items-center justify-center px-5 py-3 border border-transparent text-base font-medium rounded-xl text-white bg-indigo-600 hover:bg-indigo-700 shadow-lg shadow-indigo-500/30 transition-all duration-200 transform hover:-translate-y-1">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/></svg>
            File New Complaint
        </a>
    </div>

    <div class="overflow-hidden bg-white dark:bg-gray-800 shadow-2xl rounded-2xl border border-gray-100 dark:border-gray-700">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead class="bg-gray-50 dark:bg-gray-900/50">
                <tr>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Reported By</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Description</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Date</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Status</th>
                    <th class="px-6 py-4 text-right text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100 dark:divide-gray-700 bg-white dark:bg-gray-800">
            @foreach($complaints as $complaint)
                <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                    <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm font-bold text-gray-900 dark:text-white">{{ $complaint->reported_by }}</div>
                        <div class="text-xs text-indigo-500 font-medium">{{ $complaint->role }}</div>
                    </td>
                    <td class="px-6 py-4">
                        <p class="text-sm text-gray-600 dark:text-gray-300 line-clamp-1 max-w-xs">
                            {{ $complaint->description }}
                        </p>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                        {{ $complaint->report_date->format('d M Y') }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                        @php
                            $colors = [
                                'pending'     => 'bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400',
                                'in_progress' => 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400',
                                'resolved'    => 'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400',
                                'rejected'    => 'bg-rose-100 text-rose-700 dark:bg-rose-900/30 dark:text-rose-400',
                            ];
                        @endphp
                        <span class="px-3 py-1 rounded-full text-xs font-bold {{ $colors[$complaint->status] ?? 'bg-gray-100 text-gray-600' }}">
                            {{ ucfirst(str_replace('_', ' ', $complaint->status)) }}
                        </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-3">
<td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-3">
    {{-- Add View Button here --}}
    <a href="{{ route('complaints.show', $complaint) }}" class="text-gray-600 dark:text-gray-400 hover:text-gray-900 font-bold">View</a>
    
    <a href="{{ route('complaints.action', $complaint) }}" class="text-emerald-600 dark:text-emerald-400 font-bold">Action</a>
    <a href="{{ route('complaints.edit', $complaint) }}" class="text-indigo-600">Edit</a>
</td>
                    <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-3">
                        <form action="{{ route('complaints.destroy', $complaint) }}" method="POST" class="inline">
                            @csrf @method('DELETE')
                            <button type="submit" class="text-rose-600 hover:text-rose-900" onclick="return confirm('Delete this report?')">Delete</button>
                        </form>
                    </td>
                </tr>
            @endforeach
            </tbody>
        </table>
    </div>
    <div class="mt-6">{{ $complaints->links() }}</div>
</div>
@endsection