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
     
        $latestIds = AuditLog::latest()
            ->limit(10)
            ->pluck('id');

        AuditLog::whereNotIn('id', $latestIds)
            ->update(['is_archived' => true]);

        $logs = AuditLog::with(['user', 'relatedModel'])
            ->where('is_archived', false)
            ->latest()
            ->paginate(10);

        return view('audit_logs.index', compact('logs'));
    }
public function apiIndex()
{
    // Filter hanya log milik user yang sedang login
    $logs = AuditLog::with('user')
        ->where('user_id', FacadesAuth::id()) // <--- Tambahkan baris ini
        ->where('is_archived', false)
        ->latest()
        ->paginate(10);

    return response()->json($logs);
}
}