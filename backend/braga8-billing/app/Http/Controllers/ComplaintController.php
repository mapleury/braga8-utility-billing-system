<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
namespace App\Http\Controllers;

use App\Models\Complaint;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ComplaintController extends Controller
{
    public function index() {
        $complaints = Complaint::latest()->paginate(10);
        return view('complaints.index', compact('complaints'));
    }

    public function create() {
        return view('complaints.create');
    }

    public function store(Request $request) {
        $data = $request->validate([
            'reported_by' => 'required|string|max:255',
            'role' => 'required|string',
            'report_date' => 'required|date',
            'description' => 'required|string',
            'image' => 'nullable|image|mimes:jpg,jpeg,png|max:2048'
        ]);

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('complaints', 'public');
        }

        Complaint::create($data);
        return redirect()->route('complaints.index')->with('success', 'Complaint submitted.');
    }

    public function edit(Complaint $complaint) {
        return view('complaints.edit', compact('complaint'));
    }
// Add this method to show the specific action page
public function action(Complaint $complaint) {
    return view('complaints.action', compact('complaint'));
}

public function show(Complaint $complaint)
{
    return view('complaints.show', compact('complaint'));
}

public function update(Request $request, Complaint $complaint) {
    $data = $request->validate([
        'reported_by' => 'sometimes|required|string|max:255',
        'role'        => 'sometimes|required|string',
        'report_date' => 'sometimes|required|date',
        'description' => 'sometimes|required|string',
        'status'      => 'sometimes|required|in:pending,in_progress,resolved,rejected',
        'solution'    => 'nullable|string',
    ]);

    $complaint->update($data);
    
    return redirect()->route('complaints.index')
        ->with('success', 'Complaint successfully updated.');
}
    

    public function destroy(Complaint $complaint) {
        if($complaint->image) Storage::disk('public')->delete($complaint->image);
        $complaint->delete();
        return back()->with('success', 'Complaint deleted.');
    }
}