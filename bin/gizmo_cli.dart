import 'dart:io';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:gizmo_cli/classes/useful_process.dart';
import 'package:win32/win32.dart';
import 'package:gizmo_cli/gizmo_engine.dart' as gizmo_engine;
import 'package:gizmo_cli/wrappers/wrappers.dart' as wrapper;
import 'package:gizmo_cli/examples/examples.dart' as examples;

List<UsefulWindow> usefulWindows = [];

class UsefulWindow
{
  int hWnd;
  String name;

  UsefulWindow(this.hWnd, this.name);
}

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

void bootstrapper()
{
  // EnumWindowsProc returns child window handles.
  // It is an application defined callback.
  var cFunctionPointerEnumWindowsProc = Pointer.fromFunction<EnumWindowsProc>(enumWindowsProc, 0);
  // Returns a handle to the c function
  // Pointer<NativeFunction<Uint32 Function(IntPtr, IntPtr)>> nativeFunctionPointer =
  // gizmo_engine.getHandleToEnumerationFunction(cFunctionPointerEnumWindowsProc);
  EnumWindows(cFunctionPointerEnumWindowsProc, 0);
}

Future<void> main(List<String> arguments) async {
  bootstrapper();

  // call the actual function
  for (int i = 0; i < usefulWindows.length; i++) {
    print('${usefulWindows.elementAt(i).name} === ${usefulWindows.elementAt(i).hWnd}');
  }

  stdout.write("Enter Window Handle number: ");
  String? sWindowHandle = stdin.readLineSync();
  print("Requesting $sWindowHandle modules");
  UsefulProcess usefulProcess = gizmo_engine.grabUsefulProcess(int.parse(sWindowHandle!));
  for (int i = 0; i < usefulProcess.getModules.length; i++)
    {
      print(usefulProcess.getModules[i].name);
    }
  stdout.write("Enter Module Handle number: ");
  String? sModuleHandle = stdin.readLineSync();

  // ! Testing drawing an icon to a window through a window with a module's icon.
  // examples.ExtractAssociatedIconWExample(int.parse(sModuleHandle!), int.parse(sWindowHandle));
  // Step 2: Open the process with PROCESS_QUERY_INFORMATION and PROCESS_VM_READ access rights
  Pointer<Uint32> pointerProcessID = calloc<DWORD>(1);
  pointerProcessID = usefulProcess.pointerID;
  print('Process Handle: ${pointerProcessID.value}');
  final handleToOpenProcessObject = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pointerProcessID.value);
  print('Handle To Open Process Object: $handleToOpenProcessObject');

  // Read access example
  int byteCount = 4;
  Pointer<Uint32> memoryAddress = calloc<UINT>(1);
  int addr = 52485880;
  memoryAddress.value = addr;
  // 1 byte = 16^2 = ranges (0 - 255)
  Pointer<Uint8> data = calloc<BYTE>(byteCount);
  int handleForModule = int.parse(sModuleHandle!);

  int result = ReadProcessMemory(handleToOpenProcessObject, memoryAddress, data, byteCount, nullptr);
  print("Code: $result");
  print(GetLastError());
  for (int i = 0; i < byteCount; i++)
    {
      print(data.elementAt(i).value);
    }

  // Release
  free(pointerProcessID);
  free(memoryAddress);
  free(data);
  CloseHandle(handleToOpenProcessObject);
  // Writing access example
  // List<int> memes = [102, 111, 114, 116, 121, 45, 116, 119, 111, 0];
  // Uint8List byteList = Uint8List.fromList(memes);
}

int getVersionBlockSize(Pointer<Utf16> lpFilename) {
  int fviSize;

  // dwDummy isn't used; it's a historical vestige.
  final dwDummy = calloc<DWORD>();

  try {
    fviSize = GetFileVersionInfoSize(lpFilename, dwDummy);
    if (fviSize == 0) {
      throw Exception('GetFileVersionInfoSize failed.');
    }

    return fviSize;
  } finally {
    free(dwDummy);
  }
}
