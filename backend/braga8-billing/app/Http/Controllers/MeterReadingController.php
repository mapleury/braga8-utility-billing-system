<?php

namespace App\Http\Controllers;

use App\Models\MeterReading;
use App\Models\Tenant;
use App\Models\UtilityMeter;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http; // WAJIB TAMBAHKAN INI

class MeterReadingController extends Controller
{
    public function index()
    {
        $tenants = Tenant::with([
            'units.meters.readings.user'
        ])->get();

        return view('readings.index', compact('tenants'));
    }

    public function create()
    {
        $meters = UtilityMeter::with('unit')->get();
        return view('readings.create', compact('meters'));
    }

    public function store(Request $request)
    {
        // 1. Validasi Input
        $request->validate([
            'meter_id'      => 'required|exists:utility_meters,id',
            'reading_value' => 'required|numeric',
            'photo'         => 'required|image|max:2048',
            'latitude'      => 'nullable|numeric',
            'longitude'     => 'nullable|numeric',
            'description'   => 'nullable|string', // Pastikan divalidasi
        ]);

        // 2. Cek Angka Meteran Mundur
        $lastReading = MeterReading::where('meter_id', $request->meter_id)
            ->latest('recorded_at')
            ->first();

        if ($lastReading && $request->reading_value < $lastReading->reading_value) {
            return back()->withErrors([
                'reading_value' => "Input ({$request->reading_value}) tidak boleh lebih rendah dari angka sebelumnya ({$lastReading->reading_value})."
            ])->withInput();
        }

        // 3. Simpan Foto
        $photoPath = $request->file('photo')->store('meter_photos', 'public');

        // 4. Proses Geocoding (Ubah Koordinat ke Alamat)
        $address = "-";
        if ($request->latitude && $request->longitude) {
            try {
                // Tembak API OpenStreetMap (Gratis & Tanpa API Key)
                $response = Http::withHeaders([
                    'User-Agent' => 'Braga8-App-Management'
                ])->get("https://nominatim.openstreetmap.org/reverse", [
                    'format' => 'json',
                    'lat'    => $request->latitude,
                    'lon'    => $request->longitude,
                ]);

                if ($response->successful()) {
                    $address = $response->json()['display_name'] ?? "-";
                }
            } catch (\Exception $e) {
                $address = "Gagal melacak alamat otomatis";
            }
        }

        // 5. Simpan ke Database
        MeterReading::create([
            'meter_id'         => $request->meter_id,
            'user_id'          => Auth::id(),
            'reading_value'    => $request->reading_value,
            'photo_path'       => $photoPath,
            'latitude'         => $request->latitude,
            'longitude'        => $request->longitude,
            'location_address' => $address, // Alamat hasil geocoding
            'description'      => $request->description, // Data deskripsi masuk sini
            'recorded_at'      => Carbon::now(),
            'status'           => null, // Default status
        ]);

        return redirect()->route('meter-readings.index')->with('success', 'Pencatatan meteran berhasil disimpan.');
    }

    public function updateStatus($id)
    {
        $reading = MeterReading::findOrFail($id);
        $reading->status = $reading->status === 'checked' ? null : 'checked';
        $reading->save();

        return back();
    }

    public function summary() 
    {
        $tenants = Tenant::with(['units.meters.readings' => function($query) {
            $query->latest(); 
        }])->get();

        return response()->json($tenants);
    }

    public function getMonthlyProgress()
    {
        $currentMonth = now()->month;
        $currentYear = now()->year;

        $totalMeters = UtilityMeter::count();
        
        $readingsThisMonth = MeterReading::whereYear('recorded_at', $currentYear)
            ->whereMonth('recorded_at', $currentMonth)
            ->distinct('meter_id')
            ->count();

        return response()->json([
            'total'      => $totalMeters,
            'readings'   => $readingsThisMonth,
            'percentage' => $totalMeters > 0 ? ($readingsThisMonth / $totalMeters) : 0,
        ]);
    }
}