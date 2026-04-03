@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8 max-w-2xl">
    <div class="mb-8">
        <h1 class="text-3xl font-extrabold text-gray-900 dark:text-white">Edit Report Details</h1>
        <p class="text-gray-500">Refining the initial report for Complaint #{{ $complaint->id }}</p>
    </div>

    <div class="bg-white dark:bg-gray-800 shadow-2xl rounded-2xl p-8 border border-gray-100 dark:border-gray-700">
        <form action="{{ route('complaints.update', $complaint) }}" method="POST" class="space-y-6">
            @csrf @method('PUT')

            <div class="grid grid-cols-1 gap-6">
                <div>
                    <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Reported By</label>
                    <input type="text" name="reported_by" value="{{ $complaint->reported_by }}" required 
                           class="w-full rounded-xl border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-white focus:ring-indigo-500">
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Role</label>
                    <select name="role" class="w-full rounded-xl border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-white focus:ring-indigo-500">
                        <option value="Tenant" {{ $complaint->role == 'Tenant' ? 'selected' : '' }}>Tenant</option>
                        <option value="Staff" {{ $complaint->role == 'Staff' ? 'selected' : '' }}>Staff</option>
                        <option value="Visitor" {{ $complaint->role == 'Visitor' ? 'selected' : '' }}>Visitor</option>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Report Date</label>
                    <input type="date" name="report_date" value="{{ $complaint->report_date->format('Y-m-d') }}" required
                           class="w-full rounded-xl border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-white focus:ring-indigo-500">
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Description</label>
                    <textarea name="description" rows="4" required
                              class="w-full rounded-xl border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-white focus:ring-indigo-500">{{ $complaint->description }}</textarea>
                </div>
            </div>

            <div class="pt-4 flex gap-3">
                <button type="submit" class="flex-1 py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-xl shadow-lg transition-all active:scale-95">
                    Save Changes
                </button>
                <a href="{{ route('complaints.index') }}" class="px-6 py-3 bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 rounded-xl font-bold">Cancel</a>
            </div>
        </form>
    </div>
</div>
@endsection