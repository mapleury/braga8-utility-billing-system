@extends('layouts.app')

@section('content')
<div class="py-12">
    <div class="max-w-3xl mx-auto sm:px-6 lg:px-8">
        <div class="bg-white p-8 overflow-hidden shadow-sm sm:rounded-lg">
            <h2 class="text-xl font-bold mb-6">Edit Reminder</h2>
            @if ($errors->any())
    <div class="mb-4 bg-red-50 border-l-4 border-red-500 p-4">
        <div class="flex">
            <div class="flex-shrink-0">
                <p class="text-sm text-red-700">
                    @foreach ($errors->all() as $error)
                        • {{ $error }}<br>
                    @endforeach
                </p>
            </div>
        </div>
    </div>
@endif
            
            <form action="{{ route('reminders.update', $reminder->id) }}" method="POST">
                @csrf
                @method('PUT')
                
                <div class="mb-4">
                    <label class="block text-gray-700 text-sm font-bold mb-2">Title</label>
                    <input type="text" name="title" value="{{ $reminder->title }}" class="w-full border-gray-300 rounded-md shadow-sm">
                </div>

                <div class="grid grid-cols-2 gap-4 mb-4">
                    <div>
                        <label class="block text-gray-700 text-sm font-bold mb-2">Reminder Date</label>
                        <input type="date" name="reminder_date" value="{{ $reminder->reminder_date }}" class="w-full border-gray-300 rounded-md shadow-sm">
                    </div>
                    <div>
                        <label class="block text-gray-700 text-sm font-bold mb-2">Due Date</label>
                        <input type="date" name="due_date" value="{{ $reminder->due_date }}" class="w-full border-gray-300 rounded-md shadow-sm">
                    </div>
                </div>

                {{-- Add this inside your form, maybe above the Status dropdown --}}
<div class="mb-4">
    <label class="block text-gray-700 text-sm font-bold mb-2">Target Role</label>
    <select name="role_target" class="w-full border-gray-300 rounded-md shadow-sm">
        <option value="supervisor" {{ $reminder->role_target == 'supervisor' ? 'selected' : '' }}>Supervisor</option>
        <option value="admin" {{ $reminder->role_target == 'admin' ? 'selected' : '' }}>Admin</option>
        <option value="tenant" {{ $reminder->role_target == 'tenant' ? 'selected' : '' }}>Tenant</option>
        <option value="petugas" {{ $reminder->role_target == 'petugas' ? 'selected' : '' }}>Petugas</option>
    </select>
</div>

                <div class="mb-4">
                    <label class="block text-gray-700 text-sm font-bold mb-2">Status</label>
                    <select name="status" class="w-full border-gray-300 rounded-md shadow-sm">
                        <option value="pending" {{ $reminder->status == 'pending' ? 'selected' : '' }}>Pending</option>
                        <option value="sent" {{ $reminder->status == 'sent' ? 'selected' : '' }}>Sent</option>
                        <option value="completed" {{ $reminder->status == 'completed' ? 'selected' : '' }}>Completed</option>
                    </select>
                </div>

                <div class="flex items-center justify-end border-t pt-4">
                    <a href="{{ route('reminders.index') }}" class="text-gray-600 mr-4">Back</a>
                    <button type="submit" class="bg-green-600 text-white px-6 py-2 rounded-md font-bold hover:bg-green-700 shadow">
                        Update Changes
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection