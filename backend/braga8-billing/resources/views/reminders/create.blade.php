@extends('layouts.app')

@section('content')
<div class="py-12">
    <div class="max-w-3xl mx-auto sm:px-6 lg:px-8">
        <div class="bg-white p-8 overflow-hidden shadow-sm sm:rounded-lg">
            <h2 class="text-xl font-bold mb-6">Create New Reminder</h2>
            
            <form action="{{ route('reminders.store') }}" method="POST">
                @csrf
                <div class="mb-4">
                    <label class="block text-gray-700 text-sm font-bold mb-2">Title</label>
                    <input type="text" name="title" class="w-full border-gray-300 rounded-md shadow-sm" required>
                </div>

                <div class="grid grid-cols-2 gap-4 mb-4">
                    <div>
                        <label class="block text-gray-700 text-sm font-bold mb-2">Reminder Date</label>
                        <input type="date" name="reminder_date" class="w-full border-gray-300 rounded-md shadow-sm" required>
                    </div>
                    <div>
                        <label class="block text-gray-700 text-sm font-bold mb-2">Due Date</label>
                        <input type="date" name="due_date" class="w-full border-gray-300 rounded-md shadow-sm" required>
                    </div>
                </div>

                <div class="mb-6">
                    <label class="block text-gray-700 text-sm font-bold mb-2">Target Role</label>
                    <select name="role_target" class="w-full border-gray-300 rounded-md shadow-sm">
                        <option value="supervisor">Supervisor</option>
                        <option value="admin">Admin</option>
                        <option value="tenant">Tenant</option>
                        <option value="petugas">Petugas</option>
                    </select>
                </div>

                <div class="flex items-center justify-end border-t pt-4">
                    <a href="{{ route('reminders.index') }}" class="text-gray-600 mr-4">Cancel</a>
                    <button type="submit" class="bg-blue-600 text-white px-6 py-2 rounded-md font-bold hover:bg-blue-700 shadow">
                        Save Reminder
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection