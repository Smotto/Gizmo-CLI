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
UsefulProcess? usefulProcess;
String? sWindowHandle;
String? sModuleHandle;

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
void printUsefulWindows()
{
  for (int i = 0; i < usefulWindows.length; i++) {
    print('Window Name: ${usefulWindows.elementAt(i).name} === hWnd: ${usefulWindows.elementAt(i).hWnd}');
  }
}

void initializeWindowHandle()
{
  stdout.write("Enter Window Handle number: ");
  sWindowHandle = stdin.readLineSync();
  print("Requesting $sWindowHandle modules");
}

void initializeUsefulProcess()
{
  usefulProcess = gizmo_engine.grabUsefulProcess(int.parse(sWindowHandle!));
}

void initializeModuleHandle()
{
  for (int i = 0; i < usefulProcess!.modules.length; i++)
  {
    print(usefulProcess!.modules[i].name);
  }
  stdout.write("Enter Module Handle number: ");
  sModuleHandle = stdin.readLineSync();
}


Future<void> main(List<String> arguments) async {
  bootstrapper();
  printUsefulWindows();
  initializeWindowHandle();
  initializeUsefulProcess();
  initializeModuleHandle();
  // ! Testing drawing an icon to a window through a window with a module's icon.
  // examples.ExtractAssociatedIconWExample(int.parse(sModuleHandle!), int.parse(sWindowHandle!));

  // Step 2: Open the process with PROCESS_QUERY_INFORMATION and PROCESS_VM_READ access rights
  Pointer<Uint32> pointerProcessID = calloc<DWORD>(1);
  print(usefulProcess!.pointerID);
  pointerProcessID = usefulProcess!.pointerID;
  print('Process Handle: ${pointerProcessID.value}');
  final pHandle = OpenProcess(PROCESS_VM_READ, FALSE, pointerProcessID.value);
  if (pHandle == 0 )
    {
      print("ERROR ERROR AHHHHHH");
    }
  print('Handle To Open Process Object: $pHandle');

  int numberOfBytes = 4;
  int memoryAddress = 0x0320DEF8;
  var data = calloc<BYTE>(numberOfBytes);
  var numberRead = calloc<IntPtr>();
  int result = ReadProcessMemory(pHandle, Pointer.fromAddress(memoryAddress), data, numberOfBytes, numberRead);
  print('Result = $result');
  print('Number of bytes read: ${numberRead.value}');
  for (int i = 0; i < numberRead.value; i++)
  {
    print(data.elementAt(i).value);
  }

  // Release
  free(pointerProcessID);
  free(data);
  CloseHandle(pHandle);

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
