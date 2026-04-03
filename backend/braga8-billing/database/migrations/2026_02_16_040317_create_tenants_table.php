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
      Schema::create('tenants', function (Blueprint $table) {
    $table->id();
$table->string('tenant_name');
$table->string('company_name')->nullable();
$table->string('business_type')->nullable();
$table->string('person_in_charge');
$table->string('contact_phone')->nullable();
$table->string('contact_email')->nullable();
$table->timestamps();

});

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tenants');
    }
};
