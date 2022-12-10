import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'dart:io';
import 'dart:io' show Platform, Directory;
import 'package:path/path.dart' as path;
import 'package:gizmo_cli/modules_example.dart';

void startConversation()
{
  print("Enter a process you want to look at: ");
  String? name = stdin.readLineSync();
  print("Looking at ${name}...");
}

void main() {
  final Pointer<Uint32> arrayProcesses = calloc<DWORD>(1024);
  final Pointer<Uint32> countOfBytesNeeded = calloc<DWORD>();

  //  aProcesses comes out, cbNeeded comes out
  if (EnumProcesses(arrayProcesses, sizeOf<DWORD>() * 1024, countOfBytesNeeded) == 0) {
    print('EnumProcesses failed.');
    exit(1);
  }
  print("arrayProcesses Address of Pointer in Decimal Form                      --->  ${arrayProcesses.address}");
  print("Pointer Structure with address in Hexadecimal Form                     --->  ${arrayProcesses}");
  print("Number of bytes                                                        --->  ${countOfBytesNeeded.value}");
  print("countOfBytesNeeded Pointer Structure with address in Hexadecimal Form  --->  ${countOfBytesNeeded}");

  // Calculate how many process identifiers were returned.
  // * To determine how many processes were enumerated, divide the lpcbNeeded value by sizeof(DWORD).
  // ! We have to do this because arrayProcesses doesn't have a length property (it's not an structure, it's a pointer).
  final int countProcesses = countOfBytesNeeded.value ~/ sizeOf<DWORD>();
  final List<String> strings = [];
  // Print the names of the modules for each process.
  for (var i = 0; i < countProcesses; i++) {
    String name = printModules(arrayProcesses[i]);
    if (name.isNotEmpty)
    {
      strings.add(name);
    }
  }

  print("\nHandles found with name...\n");
  for (var i = 0; i < strings.length; i++)
  {
    print("Squally handle: ${strings[i]}");
  }
}
