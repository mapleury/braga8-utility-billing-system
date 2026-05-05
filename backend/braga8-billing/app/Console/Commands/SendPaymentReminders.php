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

    if ($dayOfMonth == 17) {
        $this->sendEscalation(1, 'Teguran Pembayaran', 'Segera lakukan pembayaran tagihan Anda.');
    }

    if ($dayOfMonth == 24) {
        $this->sendEscalation(2, 'Reminder Pembayaran ke-2', 'Pembayaran Anda belum kami terima. Mohon segera dilunasi.');
    }

    if ($dayOfMonth == 1 || ($dayOfMonth == 31 && $today->month != 12)) { 
        $this->sendEscalation(3, 'Peringatan Terakhir', 'Pembayaran belum dilakukan. Utilitas akan diputus dalam 1 hari.');
    }
}

private function sendEscalation($level, $title, $message)
{
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
