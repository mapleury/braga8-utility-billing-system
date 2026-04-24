<?php

namespace App\Console\Commands;

use App\Models\Notification;
use App\Models\Reminder;
use App\Models\User;
use Illuminate\Console\Command;

class SendReminderNotifications extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:send-reminder-notifications';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description';
    

    public function handle()
    {
$today = now()->toDateString();

$reminders = Reminder::where('reminder_date', $today)
    ->where('status', 'pending')
    ->get();

foreach ($reminders as $reminder) {
    $users = User::where('role', $reminder->role_target)->get();

    foreach ($users as $user) {
        Notification::create([
            'user_id' => $user->id,
            'title' => 'Reminder Alert',
            'message' => $reminder->title,
            'type' => 'reminder'
        ]);
    }

    $reminder->update(['status' => 'sent']);

    
}
    }
}
