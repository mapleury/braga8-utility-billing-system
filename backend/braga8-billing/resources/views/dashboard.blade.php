@extends('layouts.app')

@section('page-title', 'Dashboard')

@section('content')
<div class="space-y-8 p-4">
    <div class="flex flex-col space-y-1">
        <h1 class="text-3xl font-black text-gray-900 dark:text-white tracking-tight">Dashboard Overview</h1>
        <p class="text-sm text-gray-500 font-medium">System operational summary for Braga 8</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        
        <div class="bg-white dark:bg-gray-800 p-6 rounded-2xl border border-gray-100 dark:border-gray-700 shadow-sm hover:shadow-md transition-shadow">
            <p class="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em]">Total Tenants</p>
            <div class="flex items-baseline justify-between mt-4">
                <h3 class="text-4xl font-black text-gray-900 dark:text-white">{{ $totalTenants }}</h3>
                <span class="text-[10px] font-bold text-emerald-600 bg-emerald-50 dark:bg-emerald-900/30 px-2.5 py-1 rounded-full border border-emerald-100 dark:border-emerald-800">
                    +{{ $newTenantsThisMonth }} This Month
                </span>
            </div>
        </div>

        <div class="bg-white dark:bg-gray-800 p-6 rounded-2xl border border-gray-100 dark:border-gray-700 shadow-sm">
            <p class="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em]">Total Collected</p>
            <div class="mt-4">
                <h3 class="text-3xl font-black text-emerald-600 tracking-tight">
                    Rp {{ number_format($totalPaidAmount, 0, ',', '.') }}
                </h3>
                <p class="text-[10px] text-gray-400 mt-2 font-bold flex items-center">
                    <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 mr-1.5"></span>
                    {{ $paidCount }} Successful Payments
                </p>
            </div>
        </div>

        <div class="bg-white dark:bg-gray-800 p-6 rounded-2xl border border-gray-100 dark:border-gray-700 shadow-sm">
            <p class="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em]">Pending Balance</p>
            <div class="mt-4">
                <h3 class="text-3xl font-black text-rose-500 tracking-tight">
                    Rp {{ number_format($totalUnpaidAmount, 0, ',', '.') }}
                </h3>
                <p class="text-[10px] text-gray-400 mt-2 font-bold flex items-center">
                    <span class="w-1.5 h-1.5 rounded-full bg-rose-500 mr-1.5"></span>
                    {{ $unpaidCount }} Outstanding Bills
                </p>
            </div>
        </div>

        <div class="bg-white dark:bg-gray-800 p-6 rounded-2xl border border-gray-100 dark:border-gray-700 shadow-sm">
            <p class="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em]">Active Complaints</p>
            <div class="flex items-center justify-between mt-4">
                <h3 class="text-4xl font-black text-gray-900 dark:text-white">{{ $totalComplaints }}</h3>
                <div class="p-2 bg-amber-50 dark:bg-amber-900/20 rounded-xl">
                    <svg class="w-6 h-6 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                    </svg>
                </div>
            </div>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        <div class="bg-white dark:bg-gray-800 p-8 rounded-3xl border border-gray-100 dark:border-gray-700 shadow-sm lg:col-span-1">
            <h4 class="text-sm font-black text-gray-900 dark:text-white uppercase tracking-widest mb-8">Billing Overview</h4>
            <div class="space-y-6">
                <div>
                    <div class="flex justify-between text-[10px] font-black mb-2">
                        <span class="text-gray-400 uppercase">Total Collected</span>
                        <span class="text-emerald-500">{{ $percentPaid }}%</span>
                    </div>
                    <div class="w-full bg-gray-100 dark:bg-gray-700 h-3 rounded-full overflow-hidden">
                        <div class="bg-emerald-500 h-full rounded-full" style="width: {{ $percentPaid }}%"></div>
                    </div>
                </div>
                <div>
                    <div class="flex justify-between text-[10px] font-black mb-2">
                        <span class="text-gray-400 uppercase">Pending Collection</span>
                        <span class="text-blue-500">{{ $percentUnpaid }}%</span>
                    </div>
                    <div class="w-full bg-gray-100 dark:bg-gray-700 h-3 rounded-full overflow-hidden">
                        <div class="bg-blue-500 h-full rounded-full" style="width: {{ $percentUnpaid }}%"></div>
                    </div>
                </div>
                <div>
                    <div class="flex justify-between text-[10px] font-black mb-2">
                        <span class="text-gray-400 uppercase">Overdue Debt</span>
                        <span class="text-rose-500">{{ $percentOverdue }}%</span>
                    </div>
                    <div class="w-full bg-gray-100 dark:bg-gray-700 h-3 rounded-full overflow-hidden">
                        <div class="bg-rose-500 h-full rounded-full" style="width: {{ $percentOverdue }}%"></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="hidden lg:flex items-center justify-center">
            </div>

        <div class="bg-indigo-600 p-8 rounded-3xl shadow-xl shadow-indigo-200 dark:shadow-none text-white relative overflow-hidden flex flex-col justify-between lg:col-span-1">
            <div class="relative z-10">
                <p class="text-[10px] font-black text-indigo-200 uppercase tracking-[0.2em]">Input Meter Hari Ini</p>
                <div class="mt-10">
                    <h3 class="text-6xl font-black tracking-tighter">{{ $metersDone }}<span class="text-2xl text-indigo-300 font-medium">/{{ $totalMeters }}</span></h3>
                    <p class="text-xs font-bold text-indigo-100 mt-4 opacity-80">
                        {{ max($totalMeters - $metersDone, 0) }} Utility meters remaining to log
                    </p>
                </div>
            </div>
            
            <div class="relative z-10 mt-10">
                <div class="w-full bg-indigo-500/50 h-4 rounded-full p-1">
                    <div class="bg-white h-full rounded-full transition-all duration-1000" style="width: {{ ($metersDone / max($totalMeters, 1)) * 100 }}%"></div>
                </div>
            </div>

            <div class="absolute -right-6 -top-6 w-32 h-32 bg-white/5 rounded-full blur-2xl"></div>
            <div class="absolute -right-12 -bottom-12 w-48 h-48 bg-indigo-400/20 rounded-full"></div>
        </div>

    </div>
</div>
@endsection