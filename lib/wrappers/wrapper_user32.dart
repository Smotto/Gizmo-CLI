import 'dart:ffi';

final _user32 = DynamicLibrary.open('user32.dll');

/// Sets the pointer for a process id inside a window.
///
/// '''c
/// DWORD GetWindowThreadProcessId(
/// [in]            HWND    hWnd,
/// [out, optional] LPDWORD lpdwProcessId
/// );
/// '''
/// {@category user32}
int GetWindowThreadProcessId(int hwnd, Pointer<Uint32> lpdwProcessId) =>
    _GetWindowThreadProcessId(hwnd, lpdwProcessId);

final _GetWindowThreadProcessId = _user32
    .lookupFunction<
    // DLL Function has
    Uint32 Function(IntPtr hwnd, Pointer<Uint32> lpdwProcessId),
    // Dart Function becomes
    int Function(int hwnd, Pointer<Uint32> lpdwProcessId)>('GetWindowThreadProcessId');
