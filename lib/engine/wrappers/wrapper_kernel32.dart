import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:gizmo_cli/engine/structs.g.dart';
import 'package:win32/win32.dart';

final _kernel32 = DynamicLibrary.open('kernel32.dll');

/// [VirtualQueryEx]
///
/// '''c
///  SIZE_T VirtualQueryEx(
///   [in]           HANDLE                    hProcess,
///   [in, optional] LPCVOID                   lpAddress,
///   [out]          PMEMORY_BASIC_INFORMATION lpBuffer,
///   [in]           SIZE_T                    dwLength
/// );
/// '''
/// {@category kernel32}
int VirtualQueryEx(int hProcess, Pointer lpAddress, Pointer<MEMORY_BASIC_INFORMATION> lpBuffer, int dwLength) =>
    _VirtualQueryEx(hProcess, lpAddress, lpBuffer, dwLength);
final _VirtualQueryEx = _kernel32
// DLL Function has
    .lookupFunction<
        IntPtr Function(IntPtr hProcess, Pointer lpAddress, Pointer lpBuffer, IntPtr dwLength),
// Dart Function becomes
        int Function(int hProcess, Pointer lpAddress, Pointer<MEMORY_BASIC_INFORMATION> lpBuffer, int dwLength)>("VirtualQueryEx");
