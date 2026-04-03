<?php
namespace App\Models;

use App\Traits\LogsActivity;
use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    use LogsActivity;
    protected $fillable = [
        'invoice_id', 'amount_paid', 'due_date', 'paid_using', 
        'bank_rekening', 'status', 'payment_date', 'proof_img', 'reminded_at',
    ];

    protected $casts = [
        'reminded_at' => 'datetime',
        'payment_date' => 'datetime',
        'due_date' => 'date',
    ];

    public function invoice()
    {
        return $this->belongsTo(Invoice::class);
    }
}