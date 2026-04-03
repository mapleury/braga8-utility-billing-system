@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8 max-w-4xl">
    <div class="flex items-center justify-between mb-10">
        <div>
            <h1 class="text-3xl font-black text-gray-900 dark:text-white tracking-tight">System Audit Logs</h1>
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1 font-medium">Real-time activity tracking for Braga 8</p>
        </div>
        <div class="bg-indigo-50 dark:bg-indigo-900/30 px-4 py-2 rounded-full">
            <span class="text-xs font-bold text-indigo-600 dark:text-indigo-400 uppercase tracking-widest">
                {{ $logs->total() }} Total Events
            </span>
        </div>
    </div>

    <div class="relative border-l-2 border-gray-100 dark:border-gray-800 ml-4 space-y-8">
        @foreach($logs as $log)
        <div class="relative pl-8">
            {{-- Timeline Status Dot --}}
            <div class="absolute -left-[9px] top-2 w-4 h-4 rounded-full border-4 border-white dark:border-gray-900 
                {{ $log->action == 'deleted' ? 'bg-rose-500' : ($log->action == 'created' ? 'bg-emerald-500' : 'bg-blue-500') }}">
            </div>

            <div class="flex items-start p-5 bg-white dark:bg-gray-800/50 rounded-2xl border border-gray-100 dark:border-gray-700/50 shadow-sm hover:shadow-md transition-all duration-200">
                
                {{-- Action Icon --}}
                <div class="p-2.5 rounded-xl mr-4 
                    {{ $log->action == 'deleted' ? 'bg-rose-50 dark:bg-rose-900/20 text-rose-600' : 
                       ($log->action == 'created' ? 'bg-emerald-50 dark:bg-emerald-900/20 text-emerald-600' : 
                       'bg-blue-50 dark:bg-blue-900/20 text-blue-600') }}">
                    @if($log->action == 'created') 
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M12 6v12m6-6H6" stroke-width="2.5" stroke-linecap="round"/></svg>
                    @elseif($log->action == 'deleted') 
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" stroke-width="2" stroke-linecap="round"/></svg>
                    @else 
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" stroke-width="2" stroke-linecap="round"/></svg> 
                    @endif
                </div>

                <div class="flex-1 min-w-0">
                    <div class="flex items-baseline justify-between gap-4">
                        <div class="text-sm dark:text-gray-200 leading-relaxed">
                            <span class="font-bold text-gray-900 dark:text-white">
                                {{ $log->user->name ?? 'System' }}
                            </span> 
                            <span class="text-gray-500 font-medium lowercase mx-1">{{ $log->action }}</span> 
                            
                            {{-- Professional Category Badge --}}
                            <span class="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-black uppercase tracking-wider bg-indigo-50 dark:bg-indigo-900/30 text-indigo-600 dark:text-indigo-400 border border-indigo-100 dark:border-indigo-800/50">
                                {{ $log->table_label }}
                            </span> 

                            {{-- THE STAR: The actual Item Name/Number --}}
                            <span class="ml-1.5 font-bold text-gray-800 dark:text-gray-100 bg-gray-100 dark:bg-gray-700 px-2 py-0.5 rounded-md">
                                {{ $log->item_label }}
                            </span>
                        </div>
                    </div>
                    
                    {{-- Timestamp Section --}}
                    <div class="flex items-center gap-3 mt-3">
                        <p class="text-[10px] text-gray-400 font-bold uppercase tracking-widest flex items-center">
                            <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" stroke-width="2"/></svg>
                            {{ $log->created_at->diffForHumans() }}
                        </p>
                        <span class="text-gray-300 dark:text-gray-700 text-xs">•</span>
                        <p class="text-[10px] text-gray-400 font-bold uppercase tracking-widest">
                            {{ $log->created_at->format('M d, Y — H:i') }}
                        </p>
                    </div>
                </div>
            </div>
        </div>
        @endforeach
    </div>

    <div class="mt-12">
        {{ $logs->links() }}
    </div>
</div>
@endsection