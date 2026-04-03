<?php

namespace App\Http\Controllers;

use App\Models\Tariff;
use Illuminate\Http\Request;

class TariffController extends Controller
{
   
public function index(Request $request)
{
    $query = Tariff::query();

    if ($request->filled('search')) {
        $search = $request->search;
        $query->where('name', 'LIKE', "%{$search}%");
    }

    $tariffs = $query->latest()->get();
    return view('tariffs.index', compact('tariffs'));
}

   public function store(Request $request)
{
    $validated = $request->validate([

    'name' => 'required|string|max:255',
        'water_price' => 'required|numeric',
        'electric_price' => 'required|numeric',
        'electric_load_cost' => 'nullable|numeric',
        'transformer_maintenance' => 'nullable|numeric',
        'admin_fee' => 'nullable|numeric',
        'stamp_fee' => 'nullable|numeric',
        'tax_percent' => 'nullable|numeric',
        
        // Dynamic "Other Fees" validation
        'other_fees' => 'nullable|array',
        'other_fees.*.label' => 'nullable|string|max:255',
        'other_fees.*.value' => 'nullable|numeric',
    ]);

    // This part is important: Clean out rows that have no label
    if ($request->has('other_fees')) {
        $validated['other_fees'] = array_values(array_filter($request->other_fees, function ($fee) {
            return !empty($fee['label']); 
        }));
    }

    // Attempt to create
    $saved = Tariff::create($validated);

    if ($saved) {
        return redirect()->route('tariffs.index')->with('success', 'Tariff saved successfully!');
    } else {
        return back()->with('error', 'Something went wrong while saving.');
    }
}
    // Add this to your TariffController
public function create()
{
    return view('tariffs.create');
}
    // Inside TariffController

public function edit(Tariff $tariff)
{
    return view('tariffs.edit', compact('tariff'));
}

public function update(Request $request, Tariff $tariff)
{
    $validated = $request->validate([

    'name' => 'required|string|max:255',
        'water_price' => 'required|numeric',
        'electric_price' => 'required|numeric',
        'other_fees' => 'nullable|array',
        'other_fees.*.label' => 'nullable|string',
        'other_fees.*.value' => 'nullable|numeric',
    ]);

    if ($request->has('other_fees')) {
        $validated['other_fees'] = array_filter($request->other_fees, function ($fee) {
            return !empty($fee['label']);
        });
    }

    $tariff->update($validated);

    return redirect()->route('tariffs.index')->with('success', 'Tariff updated successfully');
}

public function destroy(Tariff $tariff)
{
    $tariff->delete();
    return back()->with('success', 'Tariff deleted.');
}

public function show(Tariff $tariff)
{
    return view('tariffs.show', compact('tariff'));
}

}

