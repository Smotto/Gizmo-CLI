import 'dart:ffi';
import 'module.dart';

class ActiveProcess
{
  Pointer<Uint32> pointerID;
  List<Module> modules;

  // Default Constructor
  ActiveProcess.defaultConstructor(): pointerID = nullptr, modules = [];

  // Constructor
  ActiveProcess(this.pointerID, this.modules);
}