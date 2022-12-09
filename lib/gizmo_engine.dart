import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'dart:io';
import 'dart:io' show Platform, Directory;
import 'package:path/path.dart' as path;
import 'package:gizmo_cli/modules.dart';

// calloc stands for clear, initialize all spaces with 0
// malloc stands for memory, just allocate
// a handle is a base address of a process or module or anything really.

// ** Hungarian Notation ** //
/*
  l = long integer (32 bits)
  a = array
  c = count
  ch = char
  b = boolean || b = byte values returned
  cb = count of bytes
  db = double (Systems)
  i = integer (Systems) or index (Apps)
  n = integer (Systems) or count (Apps)
  p = pointer
  h = handle
  sz = zero-terminated string
  fp = floating-point
  dw = double word (Systems)
  fn = function name
  st = clock time structure
  rg = array || rg = range
  dec = decimal
  f = flag || f = float
  us = unsafe string
  rw = row
  str = string
  arru8 = array of unsigned 8-bit integers
  psz = pointer to zero-terminated string
  lpsz = long pointer to a zero-terminated string
  rgfp = array of floating-point values
  aul = array of unsigned long (Systems)
  hwnd = handle to window
  g_n = global namespace, integer
  m_n = member of a structure/class, integer
  m_ || _ = member of a structure/class
  s_ = static member of a class
  c_ = static member of a function
 */

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
    // Each of these numbers is a process ID
    strings.add(printModules(arrayProcesses[i]));
  }

  for (var i = 0; i < strings.length; i++)
    {
      if (strings[i].isNotEmpty)
        {
          print("Squally handle: ${strings[i]}");
        }
    }
}