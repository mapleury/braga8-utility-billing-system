<?php

namespace App\Http;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Http\Kernel as HttpKernel;

class Kernel extends HttpKernel
{
 protected $middlewareGroups = [
    'web' => [
        \Illuminate\Cookie\Middleware\EncryptCookies::class,
        \Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse::class,
        \Illuminate\Session\Middleware\StartSession::class,
        \Illuminate\View\Middleware\ShareErrorsFromSession::class,
        \Illuminate\Foundation\Http\Middleware\VerifyCsrfToken::class, 
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
    ],

    'api' => [
        \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
        'throttle:api',
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
    ],
];
   

protected $routeMiddleware = [
    'auth' => \App\Http\Middleware\Authenticate::class,
    'checkrole' => \App\Http\Middleware\CheckRole::class,
];

    protected function schedule(Schedule $schedule): void
    {
      $schedule->command('reminders:send')->daily();
    }


}