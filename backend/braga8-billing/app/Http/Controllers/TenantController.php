<?php

namespace App\Http\Controllers;

use App\Models\Tenant;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class TenantController extends Controller
{
    public function index(Request $request)
    {
        $query = Tenant::query();

        if ($request->filled('search')) {
            $query->where('tenant_name', 'LIKE', "%{$request->search}%");
        }

        $tenants = $query->latest()->paginate(10);
        return view('tenants.index', compact('tenants'));
    }

    public function create()
    {
        return view('tenants.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'tenant_name'      => 'required|string|max:255',
            'person_in_charge' => 'required|string|max:255',
            'contact_phone'    => 'required|string|max:20',
            'contact_email'    => 'required|email|max:255|unique:users,email',
        ]);

        return DB::transaction(function () use ($request) {
            // 1. Create the User Account
            $user = User::create([
                'name'         => $request->person_in_charge,
                'email'        => $request->contact_email,
                'username'     => Str::slug($request->person_in_charge) . rand(10, 99),
                'password'     => Hash::make('password123'),
                'role'         => 'tenant',
                'phone_number' => $request->contact_phone, // Mapped to your actual column
            ]);

            // 2. Create the Tenant
            Tenant::create([
                'user_id'          => $user->id, 
                'tenant_name'      => $request->tenant_name,
                'company_name'     => $request->company_name,
                'business_type'    => $request->business_type,
                'person_in_charge' => $request->person_in_charge,
                'contact_phone'    => $request->contact_phone,
                'contact_email'    => $request->contact_email,
            ]);

            return redirect()->route('tenants.index')
                ->with('success', "Tenant and User Account created successfully.");
        });
    }

    public function update(Request $request, Tenant $tenant)
    {
        $request->validate([
            'tenant_name'      => 'required|string|max:255',
            'person_in_charge' => 'required|string|max:255',
            'contact_email'    => 'required|email|max:255|unique:users,email,' . $tenant->user_id,
        ]);

        return DB::transaction(function () use ($request, $tenant) {
            // Update Tenant record
            $tenant->update($request->only([
                'tenant_name', 'company_name', 'business_type', 
                'person_in_charge', 'contact_phone', 'contact_email'
            ]));

            // Update User record (mapping contact_phone to phone_number)
            if ($tenant->user_id) {
                User::where('id', $tenant->user_id)->update([
                    'name'         => $request->person_in_charge,
                    'email'        => $request->contact_email,
                    'phone_number' => $request->contact_phone, 
                ]);
            }

            return redirect()->route('tenants.index')->with('success', 'Tenant and account updated.');
        });
    }

    public function show(Tenant $tenant)
    {
        return view('tenants.show', compact('tenant'));
    }

    public function edit(Tenant $tenant)
    {
        return view('tenants.edit', compact('tenant'));
    }

    public function destroy(Tenant $tenant)
    {
        return DB::transaction(function () use ($tenant) {
            if ($tenant->user_id) {
                User::where('id', $tenant->user_id)->delete();
            }
            $tenant->delete();
            return redirect()->route('tenants.index')->with('success', 'Tenant deleted.');
        });
    }
}