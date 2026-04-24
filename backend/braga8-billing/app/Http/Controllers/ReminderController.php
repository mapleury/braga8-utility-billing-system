<?php

namespace App\Http\Controllers;

use App\Models\Reminder;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;

use App\Models\User;
use App\Models\Notification;

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

    // Jika Checkbox Eskalasi DICENTANG
    if ($request->has('auto_escalate')) {
        $baseDate = \Carbon\Carbon::parse($validated['reminder_date']);
        
        $escalations = [
            ['title' => ' (Teguran 1)', 'days' => 7, 'msg' => 'Teguran 1: Pembayaran melewati batas.'],
            ['title' => ' (Teguran 2)', 'days' => 14, 'msg' => 'Teguran 2: Segera lunasi tagihan Anda.'],
            ['title' => ' (Peringatan Terakhir)', 'days' => 21, 'msg' => 'Peringatan Terakhir: Utilitas akan diputus besok.'],
        ];

        foreach ($escalations as $index => $step) {
            $remindAt = $baseDate->copy()->addDays($step['days']);
            
            $reminder = Reminder::create([
                'title'         => $validated['title'] . $step['title'],
                'reminder_date' => $remindAt,
                'due_date'      => $remindAt->copy()->addDay(),
                'role_target'   => 'tenant',
                'status'        => 'pending'
            ]);

            // Kirim notifikasi impulsive
            $this->sendImpulsiveNotification($reminder, $step['msg'], $index);
        }

        return redirect()->route('reminders.index')->with('success', '3 Tahap eskalasi berhasil dibuat.');

    } else {
        // JIKA TIDAK DICENTANG (Manual Biasa)
        $reminder = Reminder::create([...$validated, 'status' => 'pending']);

        // Kirim notifikasi manual ke target yang dipilih
        $users = User::where('role', $reminder->role_target)->get();
        foreach ($users as $user) {
            Notification::create([
                'user_id' => $user->id,
                'title'   => $reminder->title,
                'message' => 'Pemberitahuan: ' . $reminder->title,
                'type'    => 'reminder',
            ]);
        }

        return redirect()->route('reminders.index')->with('success', 'Reminder manual berhasil dibuat.');
    }
}

// Helper function agar kode lebih rapi
private function sendImpulsiveNotification($reminder, $message, $index)
{
    $targetRoles = ['tenant'];
    
    // Logika ini hanya mengirim ke petugas di tahap Peringatan Terakhir
    if ($index === 2) { 
        $targetRoles[] = 'petugas'; 
    }

    $users = User::whereIn('role', $targetRoles)->get();
    
    // DEBUG: Jika petugas tidak muncul, mungkin role di DB bukan 'petugas'
    // dd($users->toArray()); 

    foreach ($users as $user) {
        Notification::create([
            'user_id' => $user->id,
            'title'   => $reminder->title,
            'message' => $message,
            'type'    => 'reminder',
        ]);
    }
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