import 'dart:ffi';
import 'module.dart';

class UsefulProcess
{
  Pointer<Uint32> pointerID;
  List<Module> modules;

  // Constructor
  UsefulProcess(this.pointerID, this.modules);
}