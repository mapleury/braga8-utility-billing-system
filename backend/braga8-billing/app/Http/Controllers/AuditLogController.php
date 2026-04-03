<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use Illuminate\Http\Request;

class AuditLogController extends Controller
{
    public function index()
    {
        /** * Eager Loading 'user' and 'relatedModel' is critical here.
         * 'relatedModel' uses the polymorphic logic we added to the AuditLog model
         * to fetch the actual Invoice Number or Tenant Name in one go.
         */
        $logs = AuditLog::with(['user', 'relatedModel'])
            ->latest()
            ->paginate(20);

        return view('audit_logs.index', compact('logs'));
    }}