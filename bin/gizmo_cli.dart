import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'dart:io';

import 'package:gizmo_cli/gizmo_engine.dart' as gizmo_engine;
import 'package:gizmo_cli/gizmo_playground.dart' as gizmo_playground;
import 'package:gizmo_cli/wrappers/wrapper_oleacc.dart' as gizmo_oleacc;
import 'package:gizmo_cli/wrappers/wrapper_user32.dart' as gizmo_user32;

Future<void> main(List<String> arguments) async {
  gizmo_engine.enumerateWindows();
  stdout.write("Enter Window Handle number: ");
  String? sWindowHandle = stdin.readLineSync();
  print("Requesting $sWindowHandle modules");
  gizmo_engine.printAllModulesOfProcess(int.parse(sWindowHandle!));
}
