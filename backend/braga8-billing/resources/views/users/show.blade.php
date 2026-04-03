@extends('layouts.app')

@section('content')
<div class="container">
    <h2>User Detail</h2>

    <p>Name: {{ $user->name }}</p>
    <p>Username: {{ $user->username }}</p>
    <p>Email: {{ $user->email }}</p>
    <p>Phone: {{ $user->phone_number }}</p>
    <p>Role: {{ $user->role }}</p>

    <a href="{{ route('users.index') }}">Back</a>
</div>
@endsection