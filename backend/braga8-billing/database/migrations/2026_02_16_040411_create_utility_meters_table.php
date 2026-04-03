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
Schema::create('utility_meters', function (Blueprint $table) {
    $table->engine = 'InnoDB'; // wajib InnoDB untuk FK
    $table->id();

    // pastikan FK ke units.id pakai foreignId
    $table->foreignId('unit_id')->constrained()->cascadeOnDelete();

    $table->enum('meter_type',['electricity','water']);
    $table->string('meter_number');
    $table->string('power_capacity')->nullable();
    $table->string('tariff_group')->nullable();
    $table->enum('meter_category',['postpaid','prepaid']);
    $table->timestamps();
});


    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('utility_meters');
    }
};
