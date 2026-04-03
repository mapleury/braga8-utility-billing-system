<?php

namespace App\Http\Controllers;

use App\Models\Reminder;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;

class ReminderController extends Controller
{
    /**
     * Display a listing of the reminders.
     */
public function index(Request $request)
{
    $query = Reminder::query();

    if ($request->filled('search')) {
        $search = $request->search;

        $query->where('title', 'like', "%{$search}%")
              ->orWhere('role_target', 'like', "%{$search}%")
              ->orWhere('status', 'like', "%{$search}%");
    }

    $reminders = $query->latest()->get();

    return view('reminders.index', compact('reminders'));
}

    /**
     * Show the form for creating a new reminder.
     */
    public function create(): View
    {
        return view('reminders.create');
    }

    /**
     * Store a newly created reminder in storage.
     */
    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title'         => 'required|string|max:255',
            'reminder_date' => 'required|date',
            'due_date'      => 'required|date|after_or_equal:reminder_date',
            'role_target'   => 'required|in:supervisor,admin,tenant,petugas',
        ]);

        Reminder::create($validated);

        return redirect()->route('reminders.index')
            ->with('success', 'Reminder created successfully!');
    }

    /**
     * Show the form for editing the specified reminder.
     */
    public function edit(Reminder $reminder): View
    {
        return view('reminders.edit', compact('reminder'));
    }

    /**
     * Update the specified reminder in storage.
     */
    public function update(Request $request, Reminder $reminder): RedirectResponse
    {
        $validated = $request->validate([
            'title'         => 'sometimes|string|max:255',
            'reminder_date' => 'sometimes|date',
            'due_date'      => 'sometimes|date|after_or_equal:reminder_date',
            'role_target'   => 'sometimes|in:supervisor,admin,tenant,petugas',
            'status'        => 'sometimes|in:pending,sent,completed'
        ]);

        $reminder->update($validated);

        return redirect()->route('reminders.index')
            ->with('success', 'Reminder updated successfully!');
    }

    /**
     * Remove the specified reminder from storage.
     */
    public function destroy(Reminder $reminder): RedirectResponse
    {
        $reminder->delete();

        return redirect()->route('reminders.index')
            ->with('success', 'Reminder deleted successfully!');
    }
}