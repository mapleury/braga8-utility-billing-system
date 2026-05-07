<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
public function index()
    {
        // Ambil notif hanya untuk user yang sedang login
        $notifications = Notification::where('user_id', Auth::id())
            ->latest()
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => [
                'data' => $notifications // Struktur nested 'data' sesuai permintaan Flutter lu tadi
            ]
        ]);
    }
    /**
     * Membuat notifikasi baru (Create)
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'title'   => 'required|string|max:255',
            'message' => 'required|string',
            'type'    => 'nullable|string',
        ]);

        $notification = Notification::create([
            'user_id' => $validated['user_id'],
            'title'   => $validated['title'],
            'message' => $validated['message'],
            'type'    => $validated['type'] ?? 'info',
            'read_at' => null, // Defaultnya belum dibaca
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Notification created successfully',
            'data'    => $notification
        ], 201);
    }

    public function markAsRead(Notification $notification)
    {
        if ($notification->user_id !== Auth::id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $notification->update(['read_at' => now()]);

        return response()->json(['message' => 'Marked as read']);
    }

    /**
     * Menghapus notifikasi (Delete)
     */
    public function destroy(Notification $notification)
    {
        if ($notification->user_id !== Auth::id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $notification->delete();

        return response()->json(['message' => 'Notification deleted successfully']);
    }

public function markAllAsRead()
{
    Notification::where('user_id', Auth::id())
        ->whereNull('read_at')
        ->update(['read_at' => now()]);

    return response()->json(['message' => 'Semua notifikasi ditandai dibaca']);
}

public function destroyAll()
{
    Notification::where('user_id', Auth::id())->delete();

    return response()->json(['message' => 'Semua notifikasi dihapus']);
}
}