import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:gizmo_cli/engine/structs.g.dart';
import 'package:win32/win32.dart';

final _kernel32 = DynamicLibrary.open('kernel32.dll');

/// [VirtualQuery]
///
/// '''c
/// SIZE_T VirtualQuery(
///   [in, optional] LPCVOID                   lpAddress,
///   [out]          PMEMORY_BASIC_INFORMATION lpBuffer,
///   [in]           SIZE_T                    dwLength
/// );
/// '''
/// {@category kernel32}
///
int VirtualQuery(Pointer lpAddress, Pointer<MEMORY_BASIC_INFORMATION> lpBuffer, int dwLength) =>
    _VirtualQuery(lpAddress, lpBuffer, dwLength);
final _VirtualQuery = _kernel32
// DLL Function has
    .lookupFunction<
    IntPtr Function(Pointer lpAddress, Pointer lpBuffer, IntPtr dwLength),
// Dart Function becomes
    int Function(Pointer lpAddress, Pointer<MEMORY_BASIC_INFORMATION> lpBuffer, int dwLength)>("VirtualQuery");

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

/// [VirtualProtectEx]
/// Changes protection of memory regions in the virtual address spaces of a process.
///
/// '''c
/// BOOL VirtualProtectEx(
///   [in]  HANDLE hProcess,
///   [in]  LPVOID lpAddress,
///   [in]  SIZE_T dwSize,
///   [in]  DWORD  flNewProtect,
///   [out] PDWORD lpflOldProtect
/// );
/// '''
/// {@category kernel32}
int VirtualProtectEx(int hProcess, Pointer lpAddress, int dwSize, int flNewProtect, Pointer<Uint32> lpflOldProtect) =>
    _VirtualProtectEx(hProcess, lpAddress, dwSize, flNewProtect, lpflOldProtect);
final _VirtualProtectEx = _kernel32
// DLL Function has
    .lookupFunction<
    Int32 Function(IntPtr hProcess, Pointer lpAddress, IntPtr dwSize, Uint32 flNewProtect, Pointer<Uint32> lpflOldProtect),
// Dart Function becomes
    int Function(int hProcess, Pointer lpAddress, int dwSize, int flNewProtect, Pointer<Uint32> lpflOldProtect)>("VirtualProtectEx");