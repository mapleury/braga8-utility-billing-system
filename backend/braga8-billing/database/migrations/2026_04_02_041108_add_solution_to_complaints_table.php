<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */public function up(): void
{
    Schema::table('complaints', function (Blueprint $table) {
        // Adding the solution column after the description
        $table->text('solution')->nullable()->after('description');
    });
}

public function down(): void
{
    Schema::table('complaints', function (Blueprint $table) {
        $table->dropColumn('solution');
    });
}
};
