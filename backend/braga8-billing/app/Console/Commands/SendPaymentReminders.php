<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class SendPaymentReminders extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:send-payment-reminders';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description';

    /**
     * Execute the console command.
     */
  public function handle()
{
    $today = now();
    $dayOfMonth = $today->day;

    // Logic: 7 days after the 10th = 17th
    // Stage 1: Teguran (The 17th)
    if ($dayOfMonth == 17) {
        $this->sendEscalation(1, 'Teguran Pembayaran', 'Segera lakukan pembayaran tagihan Anda.');
    }

    // Stage 2: 7 days after Stage 1 = 24th
    if ($dayOfMonth == 24) {
        $this->sendEscalation(2, 'Reminder Pembayaran ke-2', 'Pembayaran Anda belum kami terima. Mohon segera dilunasi.');
    }

    // Stage 3: 7 days after Stage 2 = 31st (or 1st depending on month)
    // For consistency with "7 calendar days", we use simple addition:
    if ($dayOfMonth == 1 || ($dayOfMonth == 31 && $today->month != 12)) { 
        $this->sendEscalation(3, 'Peringatan Terakhir', 'Pembayaran belum dilakukan. Utilitas akan diputus dalam 1 hari.');
    }
}

private function sendEscalation($level, $title, $message)
{
    // Find tenants who haven't paid (You'll need to link this to an Invoice model)
    $unpaidTenants = \App\Models\User::where('role', 'tenant')
        ->whereHas('invoices', function($q) {
            $q->where('status', 'unpaid');
        })->get();

    foreach ($unpaidTenants as $user) {
        \App\Models\Notification::create([
            'user_id' => $user->id,
            'title'   => $title,
            'message' => $message,
            'type'    => 'urgent_reminder',
        ]);
    }
}
}
