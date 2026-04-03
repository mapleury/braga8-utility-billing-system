<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
 public function up()
{
    Schema::create('payments', function (Blueprint $table) {
        $table->id();
        $table->foreignId('invoice_id')->constrained()->onDelete('cascade');
        $table->decimal('amount_paid', 15, 2);
        $table->date('due_date');
        $table->string('paid_using'); // e.g., 'Bank Transfer', 'Cash', 'E-Wallet'
        $table->string('bank_rekening')->nullable(); // Account number used
        $table->enum('status', ['pending', 'verified', 'rejected'])->default('pending');
        $table->timestamp('payment_date')->nullable();
        $table->string('proof_img')->nullable(); // Path to the uploaded receipt
        $table->text('notes')->nullable();
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
