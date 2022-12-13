import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:gizmo_cli/classes/active_process.dart';
import 'package:win32/win32.dart';
import 'package:gizmo_cli/engine/wrappers/wrappers.dart' as wrapper;

import '../classes/module.dart';

ActiveProcess grabUsefulProcess(int windowID) {
  List<Module> myList = [];

  // Step 1: Grab Window's process
  final Pointer<Uint32> pointerProcessID = calloc<DWORD>(1);
  wrapper.GetWindowThreadProcessId(windowID, pointerProcessID);
  print('Handle to Process: ${pointerProcessID.value}');

  // Step 2: Open the process with PROCESS_QUERY_INFORMATION and PROCESS_VM_READ access rights
  final handleToOpenProcessObject =
      OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pointerProcessID.value);
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
          print(hModule);
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

          Module module = Module(szModName.toDartString(), lpBaseName.toDartString(), decimalModuleValue, '0x$hexModuleValue');
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

  ActiveProcess usefulProcess = ActiveProcess(pointerProcessID, myList);

  return usefulProcess;
}

/// Takes in a a process that has a pointer to its handle,
/// number of bytes to be read, and a memory address to read from.
int readMemory(
  ActiveProcess usefulProcess,
  int numberOfBytes,
  int memoryAddress,
) {
  final openProcessHandle =
      OpenProcess(PROCESS_VM_OPERATION | PROCESS_VM_READ | PROCESS_VM_WRITE, FALSE, usefulProcess.pointerID.value);
  if (openProcessHandle == 0) {
    print("Error with opening the process.");
    throw (Exception);
  }

  var pBuffer = calloc<BYTE>(numberOfBytes);
  var pNumberOfBytesRead = calloc<IntPtr>();
  int readResult = ReadProcessMemory(
      openProcessHandle, Pointer.fromAddress(memoryAddress), pBuffer, numberOfBytes, pNumberOfBytesRead);
  if (readResult == 0) {
    print("Error with reading memory from open process handle: $openProcessHandle");
    throw (Exception);
  }
  print("Successfully read ${pNumberOfBytesRead.value} bytes! Returning buffer value...");

  int result = pBuffer.value;

  // Freeing allocated bytes from heap memory.
  free(pNumberOfBytesRead);
  free(pBuffer);
  // Closing handle with access rights.
  CloseHandle(openProcessHandle);

  return result;
}

void writeMemory(
  ActiveProcess usefulProcess,
  int numberOfBytes,
  int memoryAddress,
    int value
) {
  final openProcessHandle =
      OpenProcess(PROCESS_VM_OPERATION | PROCESS_VM_READ | PROCESS_VM_WRITE, FALSE, usefulProcess.pointerID.value);
  if (openProcessHandle == 0) {
    print("Error with opening the process.");
    throw (Exception);
  }
  var pWriteData = calloc<BYTE>(numberOfBytes);
  pWriteData.value = value;
  var numberWritten = calloc<IntPtr>();
  int writeResult =
      WriteProcessMemory(openProcessHandle, Pointer.fromAddress(memoryAddress), pWriteData, numberOfBytes, numberWritten);
  if (writeResult == 0) {
    print("Error with writing memory from open process handle: $openProcessHandle");
    throw (Exception);
  }
  print('Number of bytes written: ${numberWritten.value}');
  print("Successfully wrote ${numberWritten.value} bytes!");

  // Freeing writes
  free(pWriteData);
  free(numberWritten);
  // Closing handle with access rights.
  CloseHandle(openProcessHandle);
}

/// Returns a handle to the function pointer.
Pointer<NativeFunction<Uint32 Function(IntPtr, IntPtr)>> getHandleToEnumerationFunction(
    Pointer<NativeFunction<Uint32 Function(IntPtr, IntPtr)>> pointerFunction) {
  // Pointer ---> NativeFunction represents type C ---> Function
  Pointer<NativeFunction<Uint32 Function(IntPtr, IntPtr)>> wndProc = pointerFunction;

  return wndProc;
}
