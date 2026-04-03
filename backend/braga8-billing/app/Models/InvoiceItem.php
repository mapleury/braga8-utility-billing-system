<?php

namespace App\Models;

use App\Traits\LogsActivity;
use Illuminate\Database\Eloquent\Model;

class InvoiceItem extends Model
{
    use LogsActivity;
    protected $fillable = [
        'invoice_id',
        'description',
        'amount',
    ];

    public function invoice()
    {
        return $this->belongsTo(Invoice::class);
    }
}
