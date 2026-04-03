@extends('layouts.app')

@section('content')
<div class="py-12">
    <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">

        <!-- Header -->
        <div class="flex justify-between items-center mb-6">
            <h2 class="text-2xl font-semibold text-gray-800">Active Reminders</h2>

            <a href="{{ route('reminders.create') }}" 
               class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded shadow">
                + Create Reminder
            </a>
        </div>

        <!-- 🔍 Search Bar -->
        <form method="GET" action="{{ route('reminders.index') }}" class="mb-4">
            <div class="flex gap-2">
                <input 
                    type="text" 
                    name="search" 
                    value="{{ request('search') }}"
                    placeholder="Search reminders..."
                    class="w-full border-gray-300 rounded shadow-sm focus:ring focus:ring-blue-200"
                >

                <button type="submit" 
                    class="bg-gray-800 text-white px-4 py-2 rounded hover:bg-gray-900">
                    Search
                </button>
            </div>
        </form>

        <!-- Table -->
        <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
            <div class="p-6 text-gray-900">

                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Title</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Target</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Reminder Date</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
                        </tr>
                    </thead>

                    <tbody class="bg-white divide-y divide-gray-200">
                        @forelse($reminders as $reminder)
                        <tr>
                            <td class="px-6 py-4 font-medium">
                                {{ $reminder->title }}
                            </td>

                            <td class="px-6 py-4">
                                <span class="px-2 text-xs font-semibold rounded-full bg-indigo-100 text-indigo-800">
                                    {{ ucfirst($reminder->role_target) }}
                                </span>
                            </td>

                            <td class="px-6 py-4 text-sm text-gray-600">
                                {{ \Carbon\Carbon::parse($reminder->reminder_date)->format('M d, Y') }}
                            </td>

                            <td class="px-6 py-4">
                                <span class="px-2 text-xs font-semibold rounded-full 
                                    {{ $reminder->status === 'pending' ? 'bg-yellow-100 text-yellow-800' : 'bg-green-100 text-green-800' }}">
                                    {{ ucfirst($reminder->status) }}
                                </span>
                            </td>

                            <td class="px-6 py-4 text-right text-sm font-medium">
                                <a href="{{ route('reminders.edit', $reminder->id) }}" 
                                   class="text-indigo-600 hover:text-indigo-900 mr-3">
                                   Edit
                                </a>

                                <form action="{{ route('reminders.destroy', $reminder->id) }}" method="POST" class="inline">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" 
                                        class="text-red-600 hover:text-red-900"
                                        onclick="return confirm('Delete this reminder?')">
                                        Delete
                                    </button>
                                </form>
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="5" class="text-center py-6 text-gray-500">
                                No reminders found.
                            </td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>

            </div>
        </div>
    </div>
</div>
@endsection