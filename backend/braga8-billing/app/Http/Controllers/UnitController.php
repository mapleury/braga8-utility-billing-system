<?php

namespace App\Http\Controllers;

use App\Models\Unit;
use App\Models\Tenant;
use Illuminate\Http\Request;

class UnitController extends Controller
{
    


    // UnitController.php
public function index()
{
    // Load tenants and eager-load their units
    $tenants = Tenant::with('units')->get();

    return view('units.index', compact('tenants'));
}


    public function create()
{
    $tenants = Tenant::all();
    return view('units.create', compact('tenants'));
}
  public function store(Request $request)
{
$request->validate([
    'tenant_id' => 'required|exists:tenants,id',
    'unit_number' => 'required|string|max:50',
    'floor' => 'required|string|max:50',
    'area_size' => 'nullable|numeric',
    'is_active' => 'required|boolean',
    'lease_start' => 'nullable|date',
    'lease_end' => 'nullable|date',
]);

Unit::create($request->all());

    return redirect()->route('units.index')
        ->with('success', 'Unit berhasil ditambahkan.');
}
public function edit(Unit $unit)
{
    $tenants = Tenant::all();
    return view('units.edit', compact('unit', 'tenants'));
}
    public function update(Request $request, Unit $unit)
    {
        $request->validate([
            'tenant_id' => 'required|exists:tenants,id',
            'unit_number' => 'required|string|max:50',
            'floor' => 'required|string|max:50',
            'area_size' => 'nullable|numeric',
            'is_active' => 'required|boolean',
            'lease_start' => 'nullable|date',
            'lease_end' => 'nullable|date',
        ]);

        $unit->update($request->all());

        return redirect()->route('units.index')
            ->with('success', 'Unit berhasil diperbarui.');
    }

    public function destroy(Unit $unit)
    {
        $unit->delete();

        return redirect()->route('units.index')
            ->with('success', 'Unit berhasil dihapus.');
    }
    
    public function show(Unit $unit)
{
    // load the unit along with its tenant if needed
    $unit->load('tenant');

    return view('units.show', compact('unit'));
}
}
