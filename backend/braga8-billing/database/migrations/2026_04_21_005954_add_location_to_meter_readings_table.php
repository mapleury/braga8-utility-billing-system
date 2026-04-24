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
    Schema::table('meter_readings', function (Blueprint $table) {
        // Kita pakai double untuk presisi koordinat GPS
        $table->double('latitude')->nullable()->after('photo_path');
        $table->double('longitude')->nullable()->after('latitude');
        // Opsional: simpan alamat mentah hasil reverse geocoding
        $table->text('location_address')->nullable()->after('longitude');
    });
}

public function down(): void
{
    Schema::table('meter_readings', function (Blueprint $table) {
        $table->dropColumn(['latitude', 'longitude', 'location_address']);
    });
}
};
