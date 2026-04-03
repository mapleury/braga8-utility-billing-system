@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8 max-w-2xl">
    <div class="mb-8">
        <h1 class="text-3xl font-extrabold text-indigo-600 dark:text-indigo-400">Resolve Complaint</h1>
        <p class="text-gray-500 dark:text-gray-400">Take action on report by <strong>{{ $complaint->reported_by }}</strong></p>
    </div>

    <div class="bg-white dark:bg-gray-800 shadow-2xl rounded-2xl overflow-hidden border border-gray-100 dark:border-gray-700">
        {{-- Incident Summary Header --}}
        <div class="p-6 bg-gray-50 dark:bg-gray-900/50 border-b border-gray-100 dark:border-gray-700">
            <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-2">Issue Detail</h3>
            <p class="text-sm text-gray-700 dark:text-gray-300 italic">"{{ $complaint->description }}"</p>
        </div>

        <form action="{{ route('complaints.update', $complaint) }}" method="POST" class="p-8 space-y-6">
            @csrf @method('PUT')

            <div>
                <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Update Status</label>
                <select name="status" class="w-full rounded-xl border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-white focus:ring-indigo-500">
                    <option value="pending" {{ $complaint->status == 'pending' ? 'selected' : '' }}>Pending</option>
                    <option value="in_progress" {{ $complaint->status == 'in_progress' ? 'selected' : '' }}>In Progress</option>
                    <option value="resolved" {{ $complaint->status == 'resolved' ? 'selected' : '' }}>Resolved</option>
                    <option value="rejected" {{ $complaint->status == 'rejected' ? 'selected' : '' }}>Rejected</option>
                </select>
            </div>

            <div>
                <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Action Taken / Final Solution</label>
                <textarea name="solution" rows="5" required
                          class="w-full rounded-xl border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-white focus:ring-indigo-500 shadow-inner"
                          placeholder="Provide the specific steps taken to resolve this issue...">{{ $complaint->solution }}</textarea>
            </div>

            <div class="pt-4">
                <button type="submit" class="w-full py-4 bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-700 hover:to-teal-700 text-white font-bold rounded-xl shadow-lg shadow-emerald-500/30 transition-all active:scale-95">
                    Confirm & Update Action
                </button>
            </div>
        </form>
    </div>
</div>
@endsection