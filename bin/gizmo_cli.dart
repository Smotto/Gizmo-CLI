import 'dart:io';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:gizmo_cli/classes/active_process.dart';
import 'package:gizmo_cli/classes/useful_window.dart';
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
  var cFunctionPointerEnumWindowsProc = Pointer.fromFunction<EnumWindowsProc>(enumWindowsProc, 0);
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
  stdout.write("Enter name of window: ");
  var input = stdin.readLineSync();
  // Initialize
  sWindowHandle = (usefulWindows.firstWhere((window) => window.name == input).hWnd).toString();
  activeProcess = gizmo_engine.grabUsefulProcess(int.parse(sWindowHandle!));
  sModuleHandle = activeProcess.modules.first.base10Handle;
}

int grabOpenProcessHandle(ActiveProcess process) {
  return OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_OPERATION | PROCESS_VM_READ | PROCESS_VM_WRITE, FALSE,
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

  //! Test drawing module icon to window
  // examples.extractIconWExample(int.parse(activeProcess.modules.first.base10Handle), int.parse(sWindowHandle!),
  //     activeProcess.modules.first.absolutePath);
  // CreateDIBitmap();

  // Getting System Page Size Info
  final systemInfo = calloc<SYSTEM_INFO>();
  GetSystemInfo(systemInfo);
  print('System Page Size: ${systemInfo.ref.dwPageSize}');
  Pointer<Uint32> pAddress = calloc<Uint32>();
  pAddress.value = activeProcess.pointerID.value;
  int dwLength = systemInfo.ref.dwPageSize;
  final lpBuffer = calloc<MEMORY_BASIC_INFORMATION>();
  free(systemInfo);
  int actualNumberOfBytesInBuffer = wrapper.VirtualQueryEx(openProcessHandle, pAddress, lpBuffer, dwLength);
  print("Number of Bytes Read: $actualNumberOfBytesInBuffer");

  //! TODO: Getting negative region sizes. Fix.
  for (int i = 0; i < actualNumberOfBytesInBuffer + 100; i++)
  {
    print('$i: ${lpBuffer.elementAt(i).ref.RegionSize}');
  }
  CloseHandle(openProcessHandle);

  // ! Testing reading from Squally
  // int numberOfBytes = 4;
  // int memoryAddress = 0x0320DEF8;
  // int bufferValue = gizmo_engine.readMemory(usefulProcess, numberOfBytes, memoryAddress);
  // print(bufferValue);

  // ! Testing drawing an icon to a window with a module's icon.
  // Module handle is needed.
  // examples.ExtractAssociatedIconWExample(int.parse(sModuleHandle!), int.parse(sWindowHandle!));
}
