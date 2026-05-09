<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Complaint;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Auth;

class ComplaintController extends Controller
{
    public function index()
    {
        $complaints = Complaint::latest()->paginate(10);
        return response()->json($complaints);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'title'       => 'required|string|max:255',
            'description' => 'required|string',
            'photo_base64' => 'nullable|string',
        ]);

        if (!empty($data['photo_base64'])) {
            $image = $data['photo_base64'];
            preg_match('/data:(image\/\w+);base64,/', $image, $matches);
            $extension = str_replace('image/', '', $matches[1] ?? 'jpeg');
            $imageData = base64_decode(preg_replace('/^data:image\/\w+;base64,/', '', $image));
            $filename = 'complaints/' . uniqid() . '.' . $extension;
            Storage::disk('public')->put($filename, $imageData);
            $data['image'] = $filename;
        }

        unset($data['photo_base64']);

        $data['reported_by'] = Auth::user()->name ?? 'Unknown';
        $data['role']        = Auth::user()->role ?? 'tenant';
        $data['report_date'] = now()->toDateString();
        $data['status']      = 'pending';

        $complaint = Complaint::create($data);

        // Notify admins
        User::where('role', 'admin')->each(function ($admin) use ($data) {
            Notification::create([
                'user_id' => $admin->id,
                'title'   => 'New Complaint',
                'message' => ($data['reported_by']) . ' reported a complaint',
                'type'    => 'complaint',
            ]);
        });

        return response()->json($complaint, 201);
    }

    public function update(Request $request, $id)
    {
        $complaint = Complaint::findOrFail($id);

        $data = $request->validate([
            'title'       => 'sometimes|required|string|max:255',
            'description' => 'sometimes|required|string',
            'status'      => 'sometimes|required|in:pending,in_progress,resolved,rejected',
            'solution'    => 'nullable|string',
        ]);

        $complaint->update($data);

        return response()->json($complaint);
    }

    public function destroy($id)
    {
        $complaint = Complaint::findOrFail($id);
        if ($complaint->image) Storage::disk('public')->delete($complaint->image);
        $complaint->delete();

        return response()->json(['message' => 'Complaint deleted successfully']);
    }
}