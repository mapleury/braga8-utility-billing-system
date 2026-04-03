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
    Schema::table('payments', function (Blueprint $table) {
        // We add the column after 'status' (or any existing column)
        $table->timestamp('reminded_at')->nullable()->after('status');
    });
}

public function down(): void
{
    Schema::table('payments', function (Blueprint $table) {
        $table->dropColumn('reminded_at');
    });
}
};
