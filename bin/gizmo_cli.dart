import 'dart:convert';
import 'dart:io';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:gizmo_cli/classes/active_process.dart';
import 'package:gizmo_cli/classes/useful_window.dart';
import 'package:gizmo_cli/engine/constants.dart';
import 'package:gizmo_cli/engine/structs.g.dart';
import 'package:win32/win32.dart';
import 'package:gizmo_cli/engine/gizmo_engine.dart' as gizmo_engine;
import 'package:gizmo_cli/engine/wrappers/wrappers.dart' as wrapper;
import 'package:gizmo_cli/examples/examples.dart' as examples;

List<UsefulWindow> usefulWindows = [];
ActiveProcess activeProcess = ActiveProcess.defaultConstructor();
String? sWindowHandle;
String? sModuleHandle;

// Regular Dart Function that returns an integer.
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
  usefulWindows.add(UsefulWindow(hWnd, buffer.toDartString()));
  free(buffer);

  return TRUE;
}

void bootstrapper() {
  // EnumWindowsProc returns child window handles.
  // It is an application defined callback.
  var cFunctionPointerEnumWindowsProc =
      Pointer.fromFunction<EnumWindowsProc>(enumWindowsProc, 0);
  // Returns a handle to the c function
  // Pointer<NativeFunction<Uint32 Function(IntPtr, IntPtr)>> nativeFunctionPointer =
  // gizmo_engine.getHandleToEnumerationFunction(cFunctionPointerEnumWindowsProc);
  EnumWindows(cFunctionPointerEnumWindowsProc, 0);
}

void printUsefulWindows() {
  for (int i = 0; i < usefulWindows.length; i++) {
    print(usefulWindows.elementAt(i).name);
  }
}

void initializeActiveProcess() {
  // User input
  // stdout.write("Enter name of window: ");
  // var input = stdin.readLineSync();
  var input = "Squally";
  // Initialize
  sWindowHandle =
      (usefulWindows.firstWhere((window) => window.name == input).hWnd)
          .toString();
  activeProcess = gizmo_engine.grabUsefulProcess(int.parse(sWindowHandle!));
  sModuleHandle = activeProcess.modules.first.base10Handle;
}

int grabOpenProcessHandle(ActiveProcess process) {
  return OpenProcess(
      PROCESS_QUERY_INFORMATION |
          PROCESS_VM_OPERATION |
          PROCESS_VM_READ |
          PROCESS_VM_WRITE,
      FALSE,
      process.pointerID.value);
}

Future<void> main(List<String> arguments) async {
  // Windows List Gets Initialized
  bootstrapper();
  // Print it out for the User to go through
  printUsefulWindows();
  // Initialize our Active Process
  initializeActiveProcess();
  // Open a process with access rights
  int openProcessHandle = grabOpenProcessHandle(activeProcess);
  final pProcessMachine = calloc<USHORT>();
  final pNativeMachine = calloc<USHORT>();
  int result =
      IsWow64Process2(openProcessHandle, pProcessMachine, pNativeMachine);
  var kernelMemory = 0x00000000;
  if (result == 1) {
    kernelMemory = 0x80000000;
  } else {
    kernelMemory = 0x800000000000;
  }

  print('Process Machine: ${pProcessMachine.value}');
  print('Native Machine: ${pNativeMachine.value}');
  free(pProcessMachine);
  free(pNativeMachine);

  int begin = 0x0;

  /// Going from beginning of memory to kernel memory
  int scanReturn = ScanEx("Health", "mask", begin, kernelMemory, openProcessHandle);
  print(scanReturn);
  // show_modules(openProcessHandle);
  // examples.virtualQueryExample();

  CloseHandle(openProcessHandle);
}

int ScanEx(String pattern, String mask, int beginning, int kernelMemorySize,
    int processHandle) {
  Stopwatch s = new Stopwatch();
  s.start();
  // Getting System Page Size Info
  final systemInfo = calloc<SYSTEM_INFO>();
  GetSystemInfo(systemInfo);
  int match = 0;
  Pointer<Uint32> oldProtect = calloc<Uint32>();
  Pointer<BYTE> buffer = nullptr;
  Pointer<MEMORY_BASIC_INFORMATION> memoryBasicInformation =
      calloc<MEMORY_BASIC_INFORMATION>();
  memoryBasicInformation.ref.RegionSize = systemInfo.ref.dwPageSize;
  free(systemInfo);

  int count = 0;

  // Needs to be a pointer from address instead of creating your own,
  // since that pointer is already in the correct location.
  for (int current = beginning;
      current < beginning + kernelMemorySize;
      current += memoryBasicInformation.ref.RegionSize) {
    print('\nIteration: ${count}');
    var virtualQueryResult = wrapper.VirtualQueryEx(
        processHandle,
        Pointer.fromAddress(current),
        memoryBasicInformation,
        sizeOf<MEMORY_BASIC_INFORMATION>());
    if (virtualQueryResult != sizeOf<MEMORY_BASIC_INFORMATION>()) continue;
    if (memoryBasicInformation.ref.State != MEM_COMMIT ||
        memoryBasicInformation.ref.Protect == PAGE_NOACCESS) {
      print("Skipping NO ACCESS REGION");
      continue;
    }
    print('Ref State: ${memoryBasicInformation.ref.State}');
    print('MBI Region Size: ${memoryBasicInformation.ref.RegionSize}');
    if (wrapper.VirtualProtectEx(
            processHandle,
            memoryBasicInformation.ref.BaseAddress,
            memoryBasicInformation.ref.RegionSize,
            PAGE_EXECUTE_READWRITE,
            oldProtect) ==
        1) {
      int x = memoryBasicInformation.ref.RegionSize;
      buffer = calloc<BYTE>(x);
      var pNumberOfBytesRead = calloc<IntPtr>();
      ReadProcessMemory(processHandle, memoryBasicInformation.ref.BaseAddress,
          buffer, memoryBasicInformation.ref.RegionSize, pNumberOfBytesRead);
      print('Number of Bytes Read into Buffer: ${pNumberOfBytesRead.value}');
      wrapper.VirtualProtectEx(
          processHandle,
          memoryBasicInformation.ref.BaseAddress,
          memoryBasicInformation.ref.RegionSize,
          oldProtect.value,
          oldProtect);
      int internalAddress = Scan(pattern, mask, buffer, pNumberOfBytesRead);
      free(pNumberOfBytesRead);
      if (internalAddress != 0) {
        // calculate from internal to external
        match = current + (internalAddress - buffer.address);
        break;
      }
      free(buffer);
    }
    count++;
  }
  VirtualFree(memoryBasicInformation.ref.BaseAddress, 0, MEM_RELEASE);

  print('\nTime Elapsed: ${s.elapsedMilliseconds}ms');
  return match;
}

// Comparing pattern against buffer
int Scan(String pattern, String mask, Pointer<BYTE> buffer,
    Pointer<IntPtr> bytesRead) {
  print('Bytes Builder');
  final bytesBuilder = BytesBuilder();
  print('');
  for (int i = 0; i < bytesRead.value; i++) {
    if (i != 0 && bytesBuilder.length == 8) {
      if (utf8
          .decode(bytesBuilder.toBytes(), allowMalformed: true)
          .contains(pattern)) {

        return buffer.elementAt(i).address;
        print("you found Health!");
      }
      bytesBuilder.clear();
    }
    bytesBuilder.addByte(buffer.elementAt(i).value);
  }
  // print(bytesBuilder.toBytes());
  // print(utf8.decode(bytesBuilder.toBytes(), allowMalformed: true));
  bytesBuilder.clear();
  return 0;
}

void testVirtualQuery() {
  examples.virtualQueryExample();
}

void testReadMemory(ActiveProcess process) {
  // ! Testing reading from Squally
  int numberOfBytes = 4;
  int memoryAddress = 0x0320DEF8;
  int bufferValue =
      gizmo_engine.readMemory(process, numberOfBytes, memoryAddress);
  print(bufferValue);
}

void testDrawIcon() {
  // ! Testing drawing an icon to a window with a module's icon.
  // Module handle is needed.
  // examples.ExtractAssociatedIconWExample(int.parse(sModuleHandle!), int.parse(sWindowHandle!));
  // CreateDIBitmap();
}
