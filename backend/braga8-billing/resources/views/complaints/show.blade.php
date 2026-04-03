@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8 max-w-4xl">
    {{-- Header Navigation --}}
    <div class="flex items-center justify-between mb-6">
        <a href="{{ route('complaints.index') }}" class="inline-flex items-center text-sm font-bold text-indigo-600 dark:text-indigo-400 hover:opacity-75 transition-all">
            <svg class="w-5 h-5 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M15 19l-7-7 7-7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
            Back to Overview
        </a>
        <div class="flex gap-2">
            <a href="{{ route('complaints.edit', $complaint) }}" class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-xl text-sm font-bold">Edit Info</a>
            <a href="{{ route('complaints.action', $complaint) }}" class="px-4 py-2 bg-indigo-600 text-white rounded-xl text-sm font-bold shadow-lg shadow-indigo-500/30">Update Action</a>
        </div>
    </div>

    <div class="bg-white dark:bg-gray-800 shadow-2xl rounded-3xl overflow-hidden border border-gray-100 dark:border-gray-700">
        {{-- Top Status Bar --}}
        @php
            $statusColors = [
                'pending'     => 'bg-amber-500',
                'in_progress' => 'bg-blue-500',
                'resolved'    => 'bg-emerald-500',
                'rejected'    => 'bg-rose-500',
            ];
            $currentColor = $statusColors[$complaint->status] ?? 'bg-gray-500';
        @endphp
        <div class="{{ $currentColor }} h-2 w-full"></div>

        <div class="p-8">
            <div class="flex flex-col md:flex-row justify-between items-start gap-6">
                {{-- Left Side: Details --}}
                <div class="flex-1 space-y-8">
                    <div>
                        <span class="px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest text-white {{ $currentColor }}">
                            {{ str_replace('_', ' ', $complaint->status) }}
                        </span>
                        <h1 class="text-4xl font-black text-gray-900 dark:text-white mt-3 tracking-tight">
                            Complaint #{{ str_pad($complaint->id, 4, '0', STR_PAD_LEFT) }}
                        </h1>
                        <p class="text-gray-500 dark:text-gray-400 font-medium mt-1">
                            Reported by <span class="text-indigo-600 dark:text-indigo-400">{{ $complaint->reported_by }}</span> ({{ $complaint->role }})
                        </p>
                    </div>

                    {{-- Description Section --}}
                    <div class="bg-gray-50 dark:bg-gray-900/40 p-6 rounded-2xl border border-gray-100 dark:border-gray-700">
                        <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-3">Problem Description</h3>
                        <p class="text-gray-700 dark:text-gray-200 leading-relaxed text-lg">
                            {{ $complaint->description }}
                        </p>
                    </div>

                    {{-- Action/Solution Section --}}
                    <div class="border-l-4 border-indigo-500 pl-6 py-2">
                        <h3 class="text-xs font-bold text-indigo-500 uppercase tracking-widest mb-3">Resolution & Action Taken</h3>
                        @if($complaint->solution)
                            <p class="text-gray-700 dark:text-gray-300 leading-relaxed font-medium">
                                {{ $complaint->solution }}
                            </p>
                        @else
                            <p class="text-gray-400 italic">No action has been recorded for this report yet.</p>
                        @endif
                    </div>
                </div>

                {{-- Right Side: Photo Evidence --}}
                <div class="w-full md:w-72">
                    <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4">Evidence Attachment</h3>
                    @if($complaint->image)
                        <div class="group relative rounded-2xl overflow-hidden shadow-xl">
                            <img src="{{ asset('storage/' . $complaint->image) }}" 
                                 alt="Complaint Evidence" 
                                 class="w-full h-auto object-cover transform group-hover:scale-105 transition-transform duration-500">
                            <a href="{{ asset('storage/' . $complaint->image) }}" target="_blank" 
                               class="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                                <span class="text-white text-xs font-bold bg-white/20 backdrop-blur-md px-3 py-2 rounded-lg">View Full Size</span>
                            </a>
                        </div>
                    @else
                        <div class="aspect-square flex flex-col items-center justify-center bg-gray-100 dark:bg-gray-700/50 rounded-2xl border-2 border-dashed border-gray-200 dark:border-gray-600">
                            <svg class="w-10 h-10 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                            <span class="text-[10px] text-gray-400 font-bold mt-2">NO PHOTO ATTACHED</span>
                        </div>
                    @endif

                    <div class="mt-6 pt-6 border-t border-gray-100 dark:border-gray-700">
                        <div class="flex justify-between text-[11px] font-bold">
                            <span class="text-gray-400 uppercase">Filed On:</span>
                            <span class="text-gray-600 dark:text-gray-300">{{ $complaint->report_date->format('d F Y') }}</span>
                        </div>
                        <div class="flex justify-between text-[11px] font-bold mt-2">
                            <span class="text-gray-400 uppercase">Last Update:</span>
                            <span class="text-gray-600 dark:text-gray-300">{{ $complaint->updated_at->diffForHumans() }}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection