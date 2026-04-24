@extends('layouts.app')

@section('page-title', 'Dashboard')

@section('content')
{{-- Clean Light-Gray Background --}}
<div class="min-h-screen p-6 lg:p-10 bg-zinc-50 text-zinc-600">
    
    <div class="mb-10 flex flex-col md:flex-row md:items-end justify-between gap-4 border-b border-zinc-200 pb-8">
        <div>
            <h1 class="text-4xl font-extrabold text-zinc-900 tracking-tight">Dashboard Overview</h1>
            <p class="text-zinc-400 font-medium mt-1 text-sm uppercase tracking-widest">System Operational Summary • Braga 8</p>
        </div>
        <div class="flex gap-3">
            <span class="px-4 py-2 bg-white border border-zinc-200 rounded-xl text-xs font-bold text-zinc-500 shadow-sm">
                {{ now()->format('D, d M Y') }}
            </span>
        </div>
    </div>

    {{-- Card Style: White, Blurry, with light borders --}}
    @php 
        $cardStyle = "bg-white/70 backdrop-blur-md border border-zinc-200 p-6 rounded-3xl shadow-sm transition-all duration-300 hover:shadow-md hover:border-zinc-300";
    @endphp

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        
        <div class="{{ $cardStyle }}">
            <p class="text-[11px] font-bold text-zinc-400 uppercase tracking-widest mb-4">Total Tenants</p>
            <div class="flex items-end justify-between">
                <h3 class="text-4xl font-bold text-zinc-900">{{ $totalTenants }}</h3>
                <span class="text-[11px] px-2.5 py-1 bg-emerald-50 text-emerald-600 rounded-lg font-bold border border-emerald-100">
                    +{{ $newTenantsThisMonth }}
                </span>
            </div>
        </div>

        <div class="{{ $cardStyle }}">
            <p class="text-[11px] font-bold text-zinc-400 uppercase tracking-widest mb-4">Total Collected</p>
            <h3 class="text-2xl font-bold text-zinc-900 leading-tight">
                <span class="text-zinc-300 font-medium">Rp</span> {{ number_format($totalPaidAmount, 0, ',', '.') }}
            </h3>
            <div class="mt-2 flex items-center gap-1.5">
                <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                <p class="text-[10px] text-zinc-400 font-bold uppercase">{{ $paidCount }} Payments</p>
            </div>
        </div>

        <div class="{{ $cardStyle }}">
            <p class="text-[11px] font-bold text-zinc-400 uppercase tracking-widest mb-4">Pending Balance</p>
            <h3 class="text-2xl font-bold text-zinc-900 leading-tight">
                <span class="text-zinc-300 font-medium">Rp</span> {{ number_format($totalUnpaidAmount, 0, ',', '.') }}
            </h3>
            <div class="mt-2 flex items-center gap-1.5">
                <span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
                <p class="text-[10px] text-zinc-400 font-bold uppercase">{{ $unpaidCount }} Outstanding</p>
            </div>
        </div>

        <div class="{{ $cardStyle }}">
            <p class="text-[11px] font-bold text-zinc-400 uppercase tracking-widest mb-4">Complaints</p>
            <div class="flex items-center justify-between">
                <h3 class="text-4xl font-bold text-zinc-900">{{ $totalComplaints }}</h3>
                <svg class="w-6 h-6 text-zinc-300" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path></svg>
            </div>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        <div class="lg:col-span-2 {{ $cardStyle }}">
            <h4 class="text-xs font-bold text-zinc-800 uppercase tracking-widest mb-10">Collection Performance</h4>
            
            <div class="space-y-8">
                @php
                    $metrics = [
                        ['label' => 'Paid Revenue', 'val' => $percentPaid, 'color' => 'bg-emerald-500'],
                        ['label' => 'Pending Bills', 'val' => $percentUnpaid, 'color' => 'bg-blue-500'],
                        ['label' => 'Overdue Debt', 'val' => $percentOverdue, 'color' => 'bg-rose-400'],
                    ];
                @endphp

                @foreach($metrics as $m)
                <div>
                    <div class="flex justify-between text-[11px] font-bold mb-2 uppercase">
                        <span class="text-zinc-400">{{ $m['label'] }}</span>
                        <span class="text-zinc-900">{{ $m['val'] }}%</span>
                    </div>
                    <div class="w-full bg-zinc-100 h-2 rounded-full overflow-hidden border border-zinc-200/50">
                        <div class="{{ $m['color'] }} h-full rounded-full" style="width: {{ $m['val'] }}%"></div>
                    </div>
                </div>
                @endforeach
            </div>
        </div>

        <div class="bg-zinc-900 p-8 rounded-[2rem] shadow-xl text-white flex flex-col justify-between relative overflow-hidden">
            <div class="relative z-10">
                <p class="text-[10px] font-bold text-zinc-500 uppercase tracking-widest">Input Meter Hari Ini</p>
                <div class="mt-8">
                    <h3 class="text-7xl font-black tracking-tighter">
                        {{ $metersDone }}<span class="text-2xl text-zinc-600 font-bold ml-1">/{{ $metersRemaining }}</span>
                    </h3>
                    <p class="text-sm font-medium text-zinc-400 mt-4">
                        {{ $unitsCompleted }} Units Fully Checked
                    </p>
                </div>
            </div>

            <div class="relative z-10 mt-12">
                <div class="w-full bg-white/10 h-1.5 rounded-full">
                    <div class="bg-white h-full rounded-full transition-all duration-1000" style="width: {{ ($metersDone / max($totalMeters, 1)) * 100 }}%"></div>
                </div>
            </div>

            <div class="absolute -right-10 -bottom-10 w-40 h-40 bg-white/5 rounded-full blur-3xl"></div>
        </div>

    </div>
</div>
@endsection