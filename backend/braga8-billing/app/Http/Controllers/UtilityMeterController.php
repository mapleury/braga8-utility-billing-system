<?php

namespace App\Http\Controllers;

use App\Models\Tariff;
use App\Models\UtilityMeter;
use App\Models\Unit;
use Illuminate\Http\Request;

class UtilityMeterController extends Controller
{
    public function index(Request $request)
    {
        $search = $request->input('search');

       $meters = UtilityMeter::with(['unit', 'tariff'])
    ->when($search, function ($query) use ($search) {
        $query->where(function ($q) use ($search) {
            $q->where('meter_number', 'LIKE', "%{$search}%")
              ->orWhereHas('unit', function ($q2) use ($search) {
                  $q2->where('unit_number', 'LIKE', "%{$search}%");
              })
              ->orWhereHas('tariff', function ($q3) use ($search) {
                  $q3->where('name', 'LIKE', "%{$search}%");
              });
        });
    })
    ->latest()
    ->paginate(10);

        return view('utility-meters.index', compact('meters'));
    }

    public function create()
    {
    
    $units = Unit::all();
    $tariffs = Tariff::all();

    return view('utility-meters.create', compact('units', 'tariffs'));
    }public function store(Request $request)
{
    $validated = $request->validate([
        'unit_id' => 'required|exists:units,id',
        'meter_type' => 'required|in:electricity,water',
        'meter_number' => 'required|string|max:100',
        'power_capacity' => 'nullable|string|max:100',
        'tariff_id' => 'nullable|exists:tariffs,id'
    ]);

    UtilityMeter::create($validated);

    return redirect()->route('utility-meters.index')
        ->with('success', 'Meter berhasil ditambahkan.');
}
 public function edit(UtilityMeter $utilityMeter)
{
    $units = Unit::all();
    $tariffs = Tariff::all();

    return view('utility-meters.edit', compact('utilityMeter', 'units', 'tariffs'));
}

    public function update(Request $request, UtilityMeter $utilityMeter)
    {
        $validated = $request->validate([
            'unit_id' => 'required|exists:units,id',
            'meter_type' => 'required|in:electricity,water',
            'meter_number' => 'required|string|max:100',
            'power_capacity' => 'nullable|string|max:100',
            'multiplier'     => 'required|numeric',
           'tariff_id' => 'nullable|exists:tariffs,id',
            'meter_category' => 'required|in:postpaid,prepaid',
        ]);

        $utilityMeter->update($validated);

        return redirect()->route('utility-meters.index')
            ->with('success', 'Meter berhasil diperbarui.');
    }

    public function destroy(UtilityMeter $utilityMeter)
    {
        $utilityMeter->delete();

        return redirect()->route('utility-meters.index')
            ->with('success', 'Meter berhasil dihapus.');
    }
    public function show(UtilityMeter $utilityMeter)
{
    $meter = $utilityMeter->load(['unit', 'tariff']);

    return view('utility-meters.show', compact('meter'));
}
}
