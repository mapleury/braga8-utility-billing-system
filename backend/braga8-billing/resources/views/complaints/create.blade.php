@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8 max-w-3xl">
    <div class="mb-8">
        <a href="{{ route('complaints.index') }}" class="text-indigo-600 dark:text-indigo-400 flex items-center text-sm font-bold mb-2">
            <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M15 19l-7-7 7-7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
            Back to List
        </a>
        <h1 class="text-3xl font-extrabold text-gray-900 dark:text-white">File a Complaint</h1>
    </div>

    <div class="bg-white dark:bg-gray-800 shadow-2xl rounded-2xl p-8 border border-gray-100 dark:border-gray-700">
        <form action="{{ route('complaints.store') }}" method="POST" enctype="multipart/form-data" class="space-y-6">
            @csrf
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                {{-- Reporter Name --}}
                <div>
                    <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Who is reporting?</label>
                    <input type="text" name="reported_by" required 
                           class="w-full rounded-xl border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-white focus:ring-indigo-500 focus:border-indigo-500 shadow-sm"
                           placeholder="Enter name">
                </div>

                {{-- Role Selection --}}
                <div>
                    <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Role</label>
                    <select name="role" required class="w-full rounded-xl border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-white focus:ring-indigo-500">
                        <option value="Tenant">Tenant</option>
                        <option value="Staff">Staff</option>
                        <option value="Visitor">Visitor</option>
                        <option value="Management">Management</option>
                    </select>
                </div>

                {{-- Report Date --}}
                <div>
                    <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Incident Date</label>
                    <input type="date" name="report_date" value="{{ date('Y-m-d') }}" required
                           class="w-full rounded-xl border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-white focus:ring-indigo-500">
                </div>

                {{-- Image Upload --}}
                <div>
                    <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Upload Photo (Optional)</label>
                    <input type="file" name="image" accept="image/*"
                           class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-indigo-50 file:text-indigo-700 hover:file:bg-indigo-100">
                </div>
            </div>

            {{-- Description --}}
            <div>
                <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Description of the Problem</label>
                <textarea name="description" rows="4" required
                          class="w-full rounded-xl border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-white focus:ring-indigo-500"
                          placeholder="Describe the issue clearly..."></textarea>
            </div>

            <div class="pt-4">
                <button type="submit" 
                        class="w-full py-4 bg-gradient-to-r from-indigo-600 to-blue-600 hover:from-indigo-700 hover:to-blue-700 text-white font-bold rounded-xl shadow-lg shadow-indigo-500/40 transition-all active:scale-95">
                    Submit Report
                </button>
            </div>
        </form>
    </div>
</div>
@endsection