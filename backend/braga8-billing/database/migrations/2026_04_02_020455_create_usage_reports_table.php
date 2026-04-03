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
    Schema::create('usage_reports', function (Blueprint $table) {
        $table->id();
        $table->string('month_year'); // Format: "2026-04"
        $table->integer('total_units_billed')->default(0);
        $table->decimal('total_electric_usage', 15, 2)->default(0);
        $table->decimal('total_water_usage', 15, 2)->default(0);
        $table->decimal('total_revenue_expected', 15, 2)->default(0);
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('usage_reports');
    }
};
