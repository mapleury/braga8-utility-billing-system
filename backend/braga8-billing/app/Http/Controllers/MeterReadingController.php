<?php

namespace App\Http\Controllers;

use App\Models\MeterReading;
use App\Models\Tenant;
use App\Models\UtilityMeter;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class MeterReadingController extends Controller
{
    public function index()
    {
        // Load full hierarchy properly
        $tenants = Tenant::with([
            'units.meters.readings.user'
        ])->get();

        // Stop sending useless $readings to the view
        return view('readings.index', compact('tenants'));
    }

    public function create()
    {
        $meters = UtilityMeter::with('unit')->get();
        return view('readings.create', compact('meters'));
    }

public function store(Request $request)
{
    $request->validate([
        'meter_id' => 'required|exists:utility_meters,id',
        'reading_value' => 'required|numeric',
        'photo' => 'required|image|max:2048',
    ]);

    // Check against the absolute latest reading regardless of date
    $lastReading = MeterReading::where('meter_id', $request->meter_id)
        ->latest('reading_value')
        ->first();

    if ($lastReading && $request->reading_value < $lastReading->reading_value) {
        return back()->withErrors("Input ({$request->reading_value}) cannot be lower than the previous reading ({$lastReading->reading_value}).");
    }

    $photoPath = $request->file('photo')->store('meter_photos', 'public');

    MeterReading::create([
        'meter_id' => $request->meter_id,
        'user_id' => Auth::id(),
        'reading_value' => $request->reading_value,
        'photo_path' => $photoPath,
        'recorded_at' => Carbon::now(), // Use Carbon for consistency
    ]);

    return redirect()->route('meter-readings.index')->with('success', 'Reading recorded.');
}

    public function updateStatus($id)
    {
        $reading = MeterReading::findOrFail($id);

        // toggle like a civilized human
        $reading->status = $reading->status === 'checked' ? null : 'checked';
        $reading->save();

        return back();
    }
}