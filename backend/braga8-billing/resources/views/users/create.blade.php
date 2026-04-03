@extends('layouts.app')

@section('content')
<div class="container">
    <h2>Create User</h2>

    <form method="POST" action="{{ route('users.store') }}">
        @csrf

        <input name="name" placeholder="Name" class="border p-2 block mb-2">
        <input name="username" placeholder="Username" class="border p-2 block mb-2">
        <input name="email" placeholder="Email" class="border p-2 block mb-2">
        <input name="phone_number" placeholder="Phone Number" class="border p-2 block mb-2">

        <select name="role" class="border p-2 block mb-2">
            <option value="admin">Admin</option>
            <option value="supervisor">Supervisor</option>
            <option value="petugas">Petugas</option>
            <option value="tenant">Tenant</option>
        </select>

        <input type="password" name="password" placeholder="Password" class="border p-2 block mb-2">

        <button class="bg-blue-500 text-white px-4 py-2">Save</button>
    </form>
</div>
@endsection