import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:gizmo_cli/classes/useful_process.dart';
import 'package:win32/win32.dart';
import 'package:gizmo_cli/wrappers/wrapper_user32.dart' as gizmo_user32;

import 'classes/module.dart';

UsefulProcess grabUsefulProcess(int windowID) {
  List<Module> myList = [];

  // Step 1: Grab Window's process
  final Pointer<Uint32> pointerProcessID = calloc<DWORD>(1);
  gizmo_user32.GetWindowThreadProcessId(windowID, pointerProcessID);
  print('Handle to Process: ${pointerProcessID.value}');

  // Step 2: Open the process with PROCESS_QUERY_INFORMATION and PROCESS_VM_READ access rights
  final handleToOpenProcessObject = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pointerProcessID.value);
  print('Handle To Open Process Object: $handleToOpenProcessObject');

  if (handleToOpenProcessObject != 0) {
    // Step 3: Grab list of all modules in the process
    final hMods = calloc<HMODULE>(1024);
    final cbNeeded = calloc<DWORD>();

    // * zeroTerminatedModuleName comes out.
    if (EnumProcessModules(handleToOpenProcessObject, hMods, sizeOf<HMODULE>() * 1024, cbNeeded) == 1) {
      // Step 4: Get the module with the file name from the process.
      for (int i = 0; i < (cbNeeded.value ~/ sizeOf<HMODULE>()); i++) {
        final szModName = wsalloc(MAX_PATH);
        // Get the full path to the module's file.
        final hModule = hMods.elementAt(i).value;
        if (GetModuleFileNameEx(handleToOpenProcessObject, hModule, szModName, MAX_PATH) != 0) {
          final hexModuleValue = hModule.toRadixString(16).padLeft(sizeOf<HMODULE>(), '0'.toUpperCase());
          final decimalModuleValue = hModule.toRadixString(10).padLeft(sizeOf<HMODULE>(), '0'.toUpperCase());
          print('\t hModule name: ${szModName.toDartString()}');
          print('\t hModule value in base 16: (0x$hexModuleValue)');
          print('\t hModule value in base 10: ${decimalModuleValue}');

          final lpBaseName = wsalloc(MAX_PATH);

          // Base name
          GetModuleBaseName(handleToOpenProcessObject, hModule, lpBaseName, MAX_PATH);
          print('\t lpBaseName: ${lpBaseName.toDartString()}');
          print('');

          Module module = Module(szModName.toDartString(), lpBaseName.toDartString(), decimalModuleValue);
          myList.add(module);

          // Free allocated memory.
          free(lpBaseName);
        }
        free(szModName);
      }
    }
    free(hMods);
    free(cbNeeded);
  }
  CloseHandle(handleToOpenProcessObject);

  UsefulProcess usefulProcess = UsefulProcess(pointerProcessID, myList);

  return usefulProcess;
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

/// Returns a handle to the function pointer.
Pointer<NativeFunction<Uint32 Function(IntPtr, IntPtr)>> getHandleToEnumerationFunction(
  Pointer<NativeFunction<Uint32 Function(IntPtr, IntPtr)>> pointerFunction) {

  // Pointer ---> NativeFunction represents type C ---> Function
  Pointer<NativeFunction<Uint32 Function(IntPtr, IntPtr)>> wndProc = pointerFunction;

  return wndProc;
}
