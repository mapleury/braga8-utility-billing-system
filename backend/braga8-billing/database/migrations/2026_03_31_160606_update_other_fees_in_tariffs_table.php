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
        $table->dropColumn('other_fee');
        $table->json('other_fees')->nullable()->after('stamp_fee');
    });
}

public function down()
{
    Schema::table('tariffs', function (Blueprint $table) {
        $table->dropColumn('other_fees');
        $table->decimal('other_fee', 12, 2)->default(0);
    });
}
};
