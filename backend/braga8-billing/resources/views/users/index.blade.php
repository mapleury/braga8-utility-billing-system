@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-6">
    <h1 class="text-3xl font-bold mb-6">User Profiles</h1>

    @if(session('success'))
        <div class="bg-green-200 text-green-800 p-4 rounded mb-4">{{ session('success') }}</div>
    @endif

    <a href="{{ route('users.create') }}" class="bg-blue-600 text-white px-4 py-2 mb-4 inline-block rounded">
        Add User
    </a>

    <table class="w-full border-collapse border border-gray-300">
        <thead>
            <tr class="bg-gray-100">
                <th class="border p-2">ID</th>
                <th class="border p-2">Name</th>
                <th class="border p-2">Username</th>
                <th class="border p-2">Email</th>
                @if(auth()->check() && auth()->user()->role === 'admin')
                    <th class="border p-2">Role</th>
                @endif
                <th class="border p-2">Created At</th>
                <th class="border p-2">Actions</th>
            </tr>
        </thead>
        <tbody>
            @forelse($users as $user)
                <tr class="hover:bg-gray-50">
                    <td class="border p-2">{{ $user->id }}</td>
                    <td class="border p-2">{{ $user->name }}</td>
                    <td class="border p-2">{{ $user->username }}</td>
                    <td class="border p-2">{{ $user->email }}</td>
                    @if(auth()->check() && auth()->user()->role === 'admin')
                        <td class="border p-2">{{ $user->role }}</td>
                    @endif
                    <td class="border p-2">{{ $user->created_at->format('d M Y') }}</td>
                    <td class="border p-2 flex gap-2">
                        <a href="{{ route('users.edit', $user->id) }}" class="text-blue-500">Edit</a>
                        <form action="{{ route('users.destroy', $user->id) }}" method="POST">
                            @csrf @method('DELETE')
                            <button type="submit" class="text-red-500" onclick="return confirm('Confirm?')">Delete</button>
                        </form>
                    </td>
                </tr>
            @empty
                <tr>
                   <td colspan="7" class="text-center py-4">No users found.</td>
                </tr>
            @endforelse
        </tbody>
    </table>
</div>
@endsection