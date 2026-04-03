<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use App\Models\UtilityMeter;
use App\Models\Tariff;
use Illuminate\Support\Facades\Log;

return new class extends Migration
{
    public function up()
    {
        // 1. Add tariff_id column
        Schema::table('utility_meters', function (Blueprint $table) {
            $table->foreignId('tariff_id')
                ->nullable()
                ->after('power_capacity')
                ->constrained()
                ->nullOnDelete();
        });

        // 2. Migrate existing data from tariff_group → tariff_id
        UtilityMeter::all()->each(function ($meter) {
            if ($meter->tariff_group) {
                $tariff = Tariff::where('name', $meter->tariff_group)->first();

                if ($tariff) {
                    $meter->tariff_id = $tariff->id;
                    $meter->save();
                } else {
                    // Log missing mapping (very important for debugging)
                    Log::warning("Tariff not found for group: " . $meter->tariff_group);
                }
            }
        });

        // 3. Drop old column
        Schema::table('utility_meters', function (Blueprint $table) {
            $table->dropColumn('tariff_group');
        });
    }

    public function down()
    {
        // Rollback: bring back tariff_group (but data will be lost)
        Schema::table('utility_meters', function (Blueprint $table) {
            $table->string('tariff_group')->nullable();
        });

        Schema::table('utility_meters', function (Blueprint $table) {
            $table->dropForeign(['tariff_id']);
            $table->dropColumn('tariff_id');
        });
    }
};