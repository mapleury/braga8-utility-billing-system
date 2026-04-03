<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        // Only create table if not exists
        if (!Schema::hasTable('tariffs')) {
            Schema::create('tariffs', function (Blueprint $table) {
                $table->id();
                $table->decimal('water_price', 12,2);
                $table->decimal('electric_price', 12,2);
                $table->decimal('electric_load_cost', 12,2)->default(0);
                $table->decimal('transformer_maintenance', 12,2)->default(0);
                $table->decimal('admin_fee', 12,2)->default(0);
                $table->decimal('stamp_fee', 12,2)->default(0);
                $table->decimal('other_fee', 12,2)->default(0);
                $table->decimal('tax_percent', 5,2)->default(0);
                $table->timestamps();
            });
        }
    }

    public function down()
    {
        if (Schema::hasTable('tariffs')) {
            Schema::dropIfExists('tariffs');
        }
    }
};