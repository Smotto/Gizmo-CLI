import 'dart:ffi';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';

/// [MEMORY_BASIC_INFORMATION]
///
/// {@category Struct}
class MEMORY_BASIC_INFORMATION extends Struct {
  // PVOID
  external Pointer BaseAddress;

  // PVOID
  external Pointer AllocationBase;

  // DWORD
  @Uint32()
  external int AllocationProtect;

  // WORD
  @Uint16()
  external int PartitionID;

  // SIZE_T
  @IntPtr()
  external int RegionSize;

  // DWORD
  @Uint32()
  external int State;

  // DWORD
  @Uint32()
  external int Protect;

  // DWORD
  @Uint32()
  external int Type;
}