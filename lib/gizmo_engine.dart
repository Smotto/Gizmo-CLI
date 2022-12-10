import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'dart:io';
import 'dart:io' show Platform, Directory;
import 'package:path/path.dart' as path;
import 'package:gizmo_cli/modules_example.dart';
import 'package:gizmo_cli/wrappers/wrapper_user32.dart' as gizmo_user32;

void printAllModulesOfProcess(int processID)
{
  // Step 1: Grab Window's process
  final Pointer<Uint32> pointerProcessID = calloc<DWORD>(1);
  gizmo_user32.GetWindowThreadProcessId(processID, pointerProcessID);

  // Step 2: Open the process with PROCESS_QUERY_INFORMATION and PROCESS_VM_READ access rights
  final handleToProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pointerProcessID.value);

  if (handleToProcess != 0) {
    // Step 3: Grab list of all modules in the process
    final hMods = calloc<HMODULE>(1024);
    final cbNeeded = calloc<DWORD>();

    // * zeroTerminatedModuleName comes out.
    if (EnumProcessModules(handleToProcess, hMods, sizeOf<HMODULE>() * 1024, cbNeeded) == 1) {
      // Step 4: Get the module with the file name from the process.
      for (int i = 0; i < (cbNeeded.value ~/ sizeOf<HMODULE>()); i++) {
        final szModName = wsalloc(MAX_PATH);

        // Get the full path to the module's file.
        final hModule = hMods.elementAt(i).value;

        if (GetModuleFileNameEx(handleToProcess, hModule, szModName, MAX_PATH) != 0) {
          final hexModuleValue = hModule.toRadixString(16).padLeft(sizeOf<HMODULE>(), '0'.toUpperCase());
          print('\t${szModName.toDartString()} (0x$hexModuleValue)');
        }
        free(szModName);
      }
    }
    free(hMods);
    free(cbNeeded);
  }
  CloseHandle(handleToProcess);
}

// Callback for each window found
int enumWindowsProc(int hWnd, int lParam) {
  // Don't enumerate windows unless they are marked as WS_VISIBLE
  if (IsWindowVisible(hWnd) == FALSE) return TRUE;

  final length = GetWindowTextLength(hWnd);
  if (length == 0) {
    return TRUE;
  }

  final buffer = wsalloc(length + 1);
  GetWindowText(hWnd, buffer, length + 1);
  print('hWnd $hWnd: ${buffer.toDartString()}');
  free(buffer);

  return TRUE;
}

/// List the window handle and text for all top-level desktop windows
/// in the current session.
void enumerateWindows() {
  Pointer<NativeFunction<Uint32 Function(IntPtr, IntPtr)>> wndProc = Pointer.fromFunction<EnumWindowsProc>(enumWindowsProc, 0);

  EnumWindows(wndProc, 0);
}
