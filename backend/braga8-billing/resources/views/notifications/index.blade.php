@extends('layouts.app')

@section('content')
<div class="py-12">
    <div class="max-w-4xl mx-auto sm:px-6 lg:px-8">

        <h2 class="text-2xl font-semibold text-gray-800 mb-6">
            Notifications
        </h2>

        <div class="space-y-4">
            @forelse($notifications as $notif)

                <div class="p-5 bg-white shadow rounded-lg border 
                    {{ $notif->read_at ? 'opacity-70' : 'border-l-4 border-blue-500' }}">

                    <div class="flex justify-between items-start">

                        <div>
                            <h3 class="font-semibold text-lg text-gray-800">
                                {{ $notif->title }}
                            </h3>

                            <p class="text-gray-600 mt-1">
                                {{ $notif->message }}
                            </p>

                            <p class="text-xs text-gray-400 mt-2">
                                {{ $notif->created_at->diffForHumans() }}
                            </p>
                        </div>

                        <div class="flex gap-2">

                            @if(!$notif->read_at)
                                <form method="POST" action="{{ route('notifications.read', $notif->id) }}">
                                    @csrf
                                    <button class="text-sm text-blue-600 hover:underline">
                                        Mark as read
                                    </button>
                                </form>
                            @endif

                            <form method="POST" action="{{ route('notifications.destroy', $notif->id) }}">
                                @csrf
                                @method('DELETE')
                                <button class="text-sm text-red-600 hover:underline">
                                    Delete
                                </button>
                            </form>

                        </div>
                    </div>

                </div>

            @empty
                <div class="text-center text-gray-500 py-10">
                    No notifications yet. Peaceful. Suspiciously peaceful.
                </div>
            @endforelse
        </div>

    </div>
</div>
@endsection