<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class Authenticate
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next, ...$guards)
    {
        // Cek user dari Sanctum token
        if (!$request->user()) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        return $next($request);
    }
}