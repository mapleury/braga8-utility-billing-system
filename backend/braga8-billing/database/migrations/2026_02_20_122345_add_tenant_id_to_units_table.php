<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('units', function (Blueprint $table) {
            // Only add if column doesn't exist
            if (!Schema::hasColumn('units', 'tenant_id')) {
                $table->unsignedBigInteger('tenant_id')->after('unit_number');
                $table->foreign('tenant_id')->references('id')->on('tenants')->onDelete('cascade');
            }
        });
    }

    public function down()
    {
        Schema::table('units', function (Blueprint $table) {
            if (Schema::hasColumn('units', 'tenant_id')) {
                $table->dropForeign(['tenant_id']);
                $table->dropColumn('tenant_id');
            }
        });
    }
};