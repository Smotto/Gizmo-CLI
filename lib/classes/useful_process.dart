import 'dart:ffi';
import 'module.dart';

class UsefulProcess
{
  Pointer<Uint32> pointerID;
  List<Module> modules;

  Pointer<Uint32> get getPointerID
  {
    return pointerID;
  }

  List<Module> get getModules
  {
    return modules;
  }

  set setPointerID(Pointer<Uint32> pointerID)
  {
    this.pointerID = pointerID;
  }

  set setModules(List<Module> modules)
  {
    this.modules = modules;
  }

  // Constructor
  UsefulProcess(this.pointerID, this.modules);
}