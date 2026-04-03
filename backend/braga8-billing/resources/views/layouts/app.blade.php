<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <title>Braga8 Utility Billing</title>
    @vite('resources/css/app.css')
    
</head>

<body class="bg-gray-100 text-gray-800">

<div class="min-h-screen flex">

    <!-- SIDEBAR -->
    <aside class="w-64 bg-white border-r border-gray-200 flex flex-col">

        <!-- Logo -->
        <div class="h-20 flex items-center justify-center border-b border-gray-200">
            <h1 class="text-xl font-semibold tracking-wide">
                Braga<span class="text-blue-600">8</span>
            </h1>
        </div>

        <!-- Navigation -->
        <nav class="flex-1 p-4 space-y-8 text-sm overflow-y-auto">

            <div class="space-y-1">

                <a href="{{ route('dashboard') }}"
                   @class([
                       'block px-4 py-2 rounded-lg transition duration-150',
                       'bg-blue-600 text-white shadow-sm' => request()->routeIs('dashboard'),
                       'text-gray-600 hover:bg-blue-50 hover:text-blue-600' => !request()->routeIs('dashboard'),
                   ])>
                    Dashboard
                </a>

            </div>

            <div class="space-y-1">
                <p class="text-xs uppercase text-gray-400 mb-2 px-4 tracking-wider">
                    Master Data
                </p>

                <a href="{{ route('tenants.index') }}"
                   @class([
                       'block px-4 py-2 rounded-lg transition duration-150',
                       'bg-blue-600 text-white shadow-sm' => request()->routeIs('tenants.*'),
                       'text-gray-600 hover:bg-blue-50 hover:text-blue-600' => !request()->routeIs('tenants.*'),
                   ])>
                    Tenants
                </a>

                <a href="{{ route('units.index') }}"
                   @class([
                       'block px-4 py-2 rounded-lg transition duration-150',
                       'bg-blue-600 text-white shadow-sm' => request()->routeIs('units.*'),
                       'text-gray-600 hover:bg-blue-50 hover:text-blue-600' => !request()->routeIs('units.*'),
                   ])>
                    Units
                </a>

                <a href="{{ route('utility-meters.index') }}"
                   @class([
                       'block px-4 py-2 rounded-lg transition duration-150',
                       'bg-blue-600 text-white shadow-sm' => request()->routeIs('utility-meters.*'),
                       'text-gray-600 hover:bg-blue-50 hover:text-blue-600' => !request()->routeIs('utility-meters.*'),
                   ])>
                    Utility Meters
                </a>
            </div>

            <div class="space-y-1">
                <p class="text-xs uppercase text-gray-400 mb-2 px-4 tracking-wider">
                    Operations
                </p>

                <a href="{{ route('meter-readings.index') }}"
                   @class([
                       'block px-4 py-2 rounded-lg transition duration-150',
                       'bg-blue-600 text-white shadow-sm' => request()->routeIs('meter-readings.*'),
                       'text-gray-600 hover:bg-blue-50 hover:text-blue-600' => !request()->routeIs('meter-readings.*'),
                   ])>
                    Meter Readings
                </a>

                <a href="{{ route('tariffs.index') }}"
                   @class([
                       'block px-4 py-2 rounded-lg transition duration-150',
                       'bg-blue-600 text-white shadow-sm' => request()->routeIs('tariffs.*'),
                       'text-gray-600 hover:bg-blue-50 hover:text-blue-600' => !request()->routeIs('tariffs.*'),
                   ])>
                    Tariffs
                </a>

                <a href="{{ route('invoices.index') }}"
                   @class([
                       'block px-4 py-2 rounded-lg transition duration-150',
                       'bg-blue-600 text-white shadow-sm' => request()->routeIs('invoices.*'),
                       'text-gray-600 hover:bg-blue-50 hover:text-blue-600' => !request()->routeIs('invoices.*'),
                   ])>
                    Invoices
                </a>


                <a href="{{ route('reminders.index') }}"
                   @class([
                       'block px-4 py-2 rounded-lg transition duration-150',
                       'bg-blue-600 text-white shadow-sm' => request()->routeIs('reminders.*'),
                       'text-gray-600 hover:bg-blue-50 hover:text-blue-600' => !request()->routeIs('reminders.*'),
                   ])>
                    Reminders
                </a>
            </div>

            <div class="space-y-1">
                <p class="text-xs uppercase text-gray-400 mb-2 px-4 tracking-wider">
                    System
                </p>

            <a href="{{ route('users.index') }}"
    @class([
        'block px-4 py-2 rounded-lg transition duration-150',
        'bg-blue-600 text-white shadow-sm' => request()->routeIs('users.*'),
        'text-gray-600 hover:bg-blue-50 hover:text-blue-600' => !request()->routeIs('users.*'),
    ])>
    Users
</a>

<a href="{{ route('reports.index') }}" 
   class="{{ request()->routeIs('reports.*') ? 'bg-indigo-600 text-white' : 'text-gray-300 hover:bg-gray-700' }} group flex items-center px-2 py-2 text-sm font-medium rounded-md">
    <svg class="mr-3 h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
    </svg>
    Usage Reports
</a>

<a href="{{ route('payments.index') }}">
    Payments
</a>

<a href="{{ route('complaints.index') }}">
    Complaints
</a>

<a href="{{ route('audit_logs.index') }}" 
   class="{{ request()->routeIs('audit_logs.index') ? 'bg-indigo-600 text-white' : 'text-gray-400 hover:text-white' }} group flex items-center px-2 py-2 text-sm font-medium rounded-md">
    <svg class="mr-3 h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
    </svg>
    Audit Logs
</a>
            </div>

        </nav>

        <div class="p-4 border-t border-gray-200 text-xs text-gray-400 text-center">
            © {{ date('Y') }} PT Eight Property Indonesia
        </div>

    </aside>

    <!-- MAIN CONTENT -->
    <div class="flex-1 flex flex-col">

        <header class="h-20 bg-white border-b border-gray-200 flex items-center justify-between px-8">
            <div>
                <h2 class="text-lg font-semibold text-gray-800">
                    @yield('page-title', 'Dashboard')
                </h2>
                <p class="text-xs text-gray-400 mt-1">
                    Braga 8 Utility Billing Management
                </p>
            </div>

<div class="flex items-center gap-4 text-sm text-gray-600">

    <span>
        {{ auth()->user()->name ?? 'Guest' }}
    </span>

    <form method="POST" action="{{ route('logout') }}">
        @csrf
        <button 
            class="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded text-xs">
            Logout
        </button>
    </form>

</div>
        </header>

        <main class="flex-1 p-8">
            @yield('content')
        </main>

    </div>

</div>

</body>
</html>