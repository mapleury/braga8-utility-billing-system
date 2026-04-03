<!DOCTYPE html>
<html>
<head>
    <title>Invoice {{ $invoice->invoice_number }}</title>
    <style>
        body { font-family: DejaVu Sans, sans-serif; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 8px; border: 1px solid #000; }
    </style>
</head>
<body>
    <h2>PT Eight Property Indonesia</h2>
    <h3>Invoice {{ $invoice->invoice_number }}</h3>
    <p><strong>Tenant:</strong> {{ $invoice->tenant->tenant_name }}</p>
    <p><strong>Unit:</strong> {{ $invoice->unit->unit_number }}</p>
    <p><strong>Period:</strong> {{ $invoice->billing_period_start }} - {{ $invoice->billing_period_end }}</p>
    <hr>
    <table>
        <thead>
            <tr>
                <th>Description</th>
                <th>Amount (IDR)</th>
            </tr>
        </thead>
        <tbody>
            @foreach($invoice->items as $item)
                <tr>
                    <td>{{ $item->description }}</td>
                    <td>{{ number_format($item->amount,2) }}</td>
                </tr>
            @endforeach
            <tr>
                <td><strong>Total</strong></td>
                <td><strong>{{ number_format($invoice->total_amount,2) }}</strong></td>
            </tr>
        </tbody>
    </table>
</body>
</html>