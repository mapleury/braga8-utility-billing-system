@extends('layouts.app')

@section('content')
<div class="container">
    <h2>Edit User</h2>

    <form method="POST" action="{{ route('users.update', $user->id) }}">
        @csrf
        @method('PUT')

        <input name="name" value="{{ $user->name }}" class="border p-2 block mb-2">
        <input name="username" value="{{ $user->username }}" class="border p-2 block mb-2">
        <input name="email" value="{{ $user->email }}" class="border p-2 block mb-2">
        <input name="phone_number" value="{{ $user->phone_number }}" class="border p-2 block mb-2">

        <select name="role" class="border p-2 block mb-2">
            @foreach(['admin','supervisor','petugas','tenant'] as $role)
                <option value="{{ $role }}" {{ $user->role == $role ? 'selected' : '' }}>
                    {{ ucfirst($role) }}
                </option>
            @endforeach
        </select>

        <input type="password" name="password" placeholder="New Password (optional)" class="border p-2 block mb-2">

        <button class="bg-blue-500 text-white px-4 py-2">Update</button>
    </form>
</div>
@endsection