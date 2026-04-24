<!DOCTYPE html>
<html lang="en">
<head>
   <meta charset="UTF-8">
   <meta name="viewport" content="width=device-width, initial-scale=1.0">
   <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
   <title>Braga8 Utility Billing</title>
   @vite('resources/css/app.css')


   <link rel="preconnect" href="https://fonts.googleapis.com">
   <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
   <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">


   <style>
       body {
           font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
       }
   </style>
</head>


<body class="bg-gray-800 text-white antialiased">


<div class="min-h-screen flex">


  <!-- SIDEBAR -->
<!-- SIDEBAR -->
<aside
   class="flex-none w-[240px] h-screen sticky top-0"
   style="
       background-image: url('{{ asset('sidebar-bg.png') }}');
       background-size: cover;
       background-repeat: no-repeat;
       background-position: center;
   ">


   <div class="flex flex-col h-full text-white px-5 py-6">


       <!-- LOGO -->
       <div class="flex justify-center mb-10">
           <img src="{{ asset('logo.png') }}" alt="Logo" class="h-16 w-auto">
       </div>


       <!-- NAV -->
       <nav class="flex-1 overflow-y-auto space-y-6 pr-1 custom-scrollbar">


           <!-- Dashboard -->
           <a href="{{ route('dashboard') }}"
              @class([
                  'block px-4 py-2.5 rounded-lg text-sm font-medium transition',
                  'bg-white/20 text-white shadow-sm text-white' => request()->routeIs('dashboard'),
                  'text-white/80 hover:bg-white/5 hover:text-white'
              ])>
               Dashboard
           </a>


           <!-- SECTION -->
           <div class="space-y-5">


               <!-- Tenant & Unit -->
               <div>
                   <div class="flex items-center gap-2 text-white/80 text-sm font-semibold px-3 mb-2">
                       <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                           <path stroke-linecap="round" stroke-linejoin="round" d="M3 12l2-2 7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2v10a1 1 0 01-1 1h-3"/>
                       </svg>
                       Tenant & Unit
                   </div>


                   <div class="space-y-1">
                       <a href="{{ route('tenants.index') }}"
                          @class([
                              'block px-4 py-2 rounded-lg text-sm transition',
                              'bg-white/20 text-white shadow-sm text-white font-medium' => request()->routeIs('tenants.*'),
                              'text-white/70 hover:bg-white/5 hover:text-white'
                          ])>
                           Tenant List
                       </a>


                       <a href="{{ route('units.index') }}"
                          @class([
                              'block px-4 py-2 rounded-lg text-sm transition',
                              'bg-white/20 text-white shadow-sm text-white font-medium' => request()->routeIs('units.*'),
                              'text-white/70 hover:bg-white/5 hover:text-white'
                          ])>
                           Unit List
                       </a>
                   </div>
               </div>


               <!-- Utilities -->
               <div>
                   <div class="flex items-center gap-2 text-white/80 text-sm font-semibold px-3 mb-2">
                       <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                           <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6l4 2"/>
                       </svg>
                       Utilities
                   </div>


                   <div class="space-y-1">
                       <a href="{{ route('utility-meters.index') }}"
                          @class([
                              'block px-4 py-2 rounded-lg text-sm transition',
                              'bg-white/20 text-white shadow-sm text-white font-medium' => request()->routeIs('utility-meters.*'),
                              'text-white/70 hover:bg-white/5 hover:text-white'
                          ])>
                           Meter Data
                       </a>


                       <a href="{{ route('meter-readings.index') }}"
                          @class([
                              'block px-4 py-2 rounded-lg text-sm transition',
                              'bg-white/20 text-white shadow-sm text-white font-medium' => request()->routeIs('meter-readings.*'),
                              'text-white/70 hover:bg-white/5 hover:text-white'
                          ])>
                           Meter Readings
                       </a>
                   </div>
               </div>


               <!-- Billing -->
               <div>
                   <div class="flex items-center gap-2 text-white/80 text-sm font-semibold px-3 mb-2">
                       <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                           <path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4 8 4 8-4z"/>
                       </svg>
                       Tarif & Billing
                   </div>


                   <div class="space-y-1">
                       <a href="{{ route('tariffs.index') }}" class="block px-4 py-2 rounded-lg text-sm text-white/70 hover:bg-white/5 hover:text-white transition">Tarif Setup</a>
                       <a href="{{ route('invoices.index') }}" class="block px-4 py-2 rounded-lg text-sm text-white/70 hover:bg-white/5 hover:text-white transition">Generate Tagihan</a>
                       <a href="{{ route('invoices.index') }}" class="block px-4 py-2 rounded-lg text-sm text-white/70 hover:bg-white/5 hover:text-white transition">Invoice</a>
                   </div>
               </div>


               <!-- Payment -->
               <div>
                   <div class="flex items-center gap-2 text-white/80 text-sm font-semibold px-3 mb-2">
                       <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                           <path stroke-linecap="round" stroke-linejoin="round" d="M17 9V7H5v10h14V9z"/>
                       </svg>
                       Payment
                   </div>


                   <div class="space-y-1">
                       <a href="{{ route('payments.index') }}" class="block px-4 py-2 rounded-lg text-sm text-white/70 hover:bg-white/5 hover:text-white transition">Payment Status</a>
                       <a href="{{ route('payments.index') }}" class="block px-4 py-2 rounded-lg text-sm text-white/70 hover:bg-white/5 hover:text-white transition">Payment Logs</a>
                   </div>
               </div>


           </div>


           <!-- Bottom -->
           <div class="pt-6 border-t border-white/10 space-y-1">


               <a href="{{ route('users.index') }}"
                  class="block px-4 py-2 rounded-lg text-sm font-medium text-white/80 hover:bg-white/5 hover:text-white transition">
                   User Management
               </a>


               <a href="{{ route('audit_logs.index') }}"
                  class="block px-4 py-2 rounded-lg text-sm font-medium text-white/80 hover:bg-white/5 hover:text-white transition">
                   Audit Log
               </a>


               <a href="#"
                  class="block px-4 py-2 rounded-lg text-sm font-medium text-white/80 hover:bg-white/5 hover:text-white transition">
                   Settings
               </a>

               <a href="{{ route('reminders.index') }}"
                  class="block px-4 py-2 rounded-lg text-sm font-medium text-white/80 hover:bg-white/5 hover:text-white transition">
                   Reminders
               </a>

                <a href="{{ route('reports.index') }}"
                  class="block px-4 py-2 rounded-lg text-sm font-medium text-white/80 hover:bg-white/5 hover:text-white transition">
                   Usage Reports
               </a>
               
                <a href="{{ route('notifications.index') }}"
                  class="block px-4 py-2 rounded-lg text-sm font-medium text-white/80 hover:bg-white/5 hover:text-white transition">
                   Notifications
               </a>


           </div>


       </nav>
   </div>
</aside>
   <!-- MAIN -->
<div
   class="flex-1 flex flex-col bg-gray-900"
   style="
       background-image: url('{{ asset('content-bg.svg') }}');
       background-size: cover;
       background-position: center;
       background-repeat: no-repeat;
   "
>


       <!-- HEADER -->
       <header class="h-20 border-b border-gray-100 flex items-center justify-between px-8">


           <div>
               <h2 class="text-lg font-semibold text-gray-800">
                   @yield('page-title', 'Dashboard')
               </h2>
               <p class="text-sm text-gray-500 mt-1">
                   Braga 8 Utility Billing Management
               </p>
           </div>


           <div class="flex items-center gap-4 text-sm text-gray-700">


               <span class="font-medium">
                   {{ auth()->user()->name ?? 'Guest' }}
               </span>


               <form method="POST" action="{{ route('logout') }}">
                   @csrf
                   <button class="bg-gray-100 hover:bg-gray-200 px-4 py-2 rounded-md text-sm font-medium transition">
                       Logout
                   </button>
               </form>


           </div>


       </header>


       <!-- CONTENT -->
       <main class="flex-1 p-8">
           @yield('content')
       </main>


   </div>


</div>


</body>
</html>

