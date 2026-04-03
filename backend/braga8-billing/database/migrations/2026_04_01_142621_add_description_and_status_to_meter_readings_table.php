<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddDescriptionAndStatusToMeterReadingsTable extends Migration
{
    public function up()
    {
        Schema::table('meter_readings', function (Blueprint $table) {
            $table->text('description')->nullable();
            $table->string('status')->nullable();
        });
    }

    public function down()
    {
        Schema::table('meter_readings', function (Blueprint $table) {
            $table->dropColumn(['description', 'status']);
        });
    }
}