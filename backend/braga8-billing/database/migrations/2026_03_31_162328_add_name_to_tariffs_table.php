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
    Schema::table('tariffs', function (Blueprint $table) {
        // We add 'name' at the beginning of the table
        $table->string('name')->after('id')->nullable(); 
    });
}

public function down()
{
    Schema::table('tariffs', function (Blueprint $table) {
        $table->dropColumn('name');
    });
}
};
