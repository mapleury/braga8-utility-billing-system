<?php
namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Reminder;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class SendReminders extends Command
{
    protected $signature = 'reminders:send';
    protected $description = 'Send reminders based on reminder_date';

    public function handle()
    {
        $now = Carbon::now();

        $reminders = Reminder::where('status', 'pending')
            ->where('reminder_date', '<=', $now)
            ->get();

        foreach ($reminders as $reminder) {

            Log::info("Reminder sent: " . $reminder->title);

            $reminder->update([
                'status' => 'sent'
            ]);
        }

        $this->info('Reminders processed.');
    }
}