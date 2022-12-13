import 'dart:ffi';
import 'package:ffi/ffi.dart';

final _oleacc = DynamicLibrary.open('oleacc.dll');

/// [GetProcessHandleFromHwnd]
///
/// Returns the process of the window handle.
///
/// '''c
///  HANDLE WINAPI GetProcessHandleFromHwnd(
///     _In_ HWND hwnd
///   );
/// '''
/// {@category oleacc}
int GetProcessHandleFromHwnd(int hwnd) => _GetProcessHandleFromHwnd(hwnd);
final _GetProcessHandleFromHwnd = _oleacc.lookupFunction<Int32 Function(IntPtr hwnd), int Function(int hwnd)>("GetProcessHandleFromHwnd");