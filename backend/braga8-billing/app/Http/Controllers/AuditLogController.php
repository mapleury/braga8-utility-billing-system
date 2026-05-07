<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use Illuminate\Container\Attributes\Auth;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth as FacadesAuth;

class AuditLogController extends Controller
{
    public function index()
{
    // Archive semua kecuali 50 terbaru
    $latestIds = AuditLog::latest()->limit(50)->pluck('id');

    AuditLog::whereNotIn('id', $latestIds)
        ->update(['is_archived' => true]);

    $logs = AuditLog::with('user')
        ->where('is_archived', false)
        ->latest()
        ->paginate(10);

    return view('audit_logs.index', compact('logs'));
}
public function apiIndex()
{
    $logs = AuditLog::with('user')
        ->where('user_id', FacadesAuth::id())
        ->latest()
        ->paginate(10);

    return response()->json($logs);
}
}