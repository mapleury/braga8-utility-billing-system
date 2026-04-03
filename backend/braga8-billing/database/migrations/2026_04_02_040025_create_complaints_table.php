<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    
      public function up(): void
{
    Schema::create('complaints', function (Blueprint $table) {
        $table->id();
        $table->string('reported_by'); // Name of person complaining
        $table->string('role');        // e.g., Tenant, Staff, Visitor
        $table->date('report_date');
        $table->enum('status', ['pending', 'in_progress', 'resolved', 'rejected'])->default('pending');
        $table->text('description');
        $table->string('image')->nullable();
        $table->timestamps();
    });

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('complaints');
    }
};
