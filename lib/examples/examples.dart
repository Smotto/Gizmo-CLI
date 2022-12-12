import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'package:win32/win32.dart';
import 'package:gizmo_cli/gizmo_engine.dart' as gizmo_engine;
import 'package:gizmo_cli/wrappers/wrappers.dart' as wrapper;

void ExtractAssociatedIconExWExample(int hInst, int hWnd)
{
  String name = "F:/SteamLibrary/steamapps/common/Squally/Squally.exe";
  Pointer<Utf16> pointerToName = name.toNativeUtf16();
  Pointer<Uint16> iconID = calloc<WORD>();
  Pointer<Uint16> someNumber = calloc<WORD>();
  int iconHandle = wrapper.ExtractAssociatedIconExW(hInst, pointerToName, someNumber, iconID);
  print("Icon address: $iconHandle");
  print(pointerToName.toDartString());
  print('Icon ID: ${iconID.value}');
  Pointer<ICONINFO> pIconInfo = calloc<ICONINFO>();
  GetIconInfo(iconHandle, pIconInfo);
  print('pIconInfo.ref.fIcon: ${pIconInfo.ref.fIcon}');
  print(pIconInfo.ref.hbmColor);
  print(pIconInfo.ref.hbmMask);
  print('pIconInfo.ref.xHotspot: ${pIconInfo.ref.xHotspot}');
  print('pIconInfo.ref.yHotspot: ${pIconInfo.ref.yHotspot}');
  int hDC = GetDC(hWnd);
  while (true)
  {
    DrawIcon(hDC, 25, 25, iconHandle);
  }
}

void ExtractAssociatedIconWExample(int hInst, int hWnd)
{
  String name = "F:/SteamLibrary/steamapps/common/Squally/Squally.exe";
  Pointer<Utf16> pointerToName = name.toNativeUtf16();
  print(name.toNativeUtf16());
  Pointer<Uint16> icon = calloc<WORD>();
  int iconHandle = ExtractAssociatedIcon(hInst, pointerToName, icon);
  print(iconHandle);
  print(pointerToName);
  print(icon.value);
  Pointer<ICONINFO> pIconInfo = calloc<ICONINFO>();
  GetIconInfo(iconHandle, pIconInfo);
  print(pIconInfo.ref.fIcon);
  print(pIconInfo.ref.hbmColor);
  print(pIconInfo.ref.hbmMask);
  print(pIconInfo.ref.xHotspot);
  print(pIconInfo.ref.yHotspot);
  int hDC = GetDC(hWnd);
  while (true)
  {
    DrawIcon(hDC, 500, 500, iconHandle);
  }
}

/* This works. */
void extractIconAExample(int hInst, int hWnd)
{
  String name = "F:/SteamLibrary/steamapps/common/Squally/Squally.exe";
  Pointer<Utf8> pointerToName8 = name.toNativeUtf8();
  int iconHandle = wrapper.ExtractIconA(hInst, pointerToName8, 0);
  print(iconHandle);
  Pointer<ICONINFO> pIconInfo = calloc<ICONINFO>();
  GetIconInfo(iconHandle, pIconInfo);
  print(pIconInfo.ref.fIcon);
  print(pIconInfo.ref.hbmColor);
  print(pIconInfo.ref.hbmMask);
  print(pIconInfo.ref.xHotspot);
  print(pIconInfo.ref.yHotspot);
  int hDC = GetDC(hWnd);

  while (true)
  {
    DrawIcon(hDC, 500, 500, iconHandle);
  }
}

/* This works. */
void extractIconWExample(int hInst, int hWnd)
{
  String name = "F:/SteamLibrary/steamapps/common/Squally/Squally.exe";
  Pointer<Utf16> pointerToName16 = name.toNativeUtf16();
  int iconHandle = wrapper.ExtractIconW(hInst, pointerToName16, 0);
  print(iconHandle);
  Pointer<ICONINFO> pIconInfo = calloc<ICONINFO>();
  GetIconInfo(iconHandle, pIconInfo);
  print(pIconInfo.ref.fIcon);
  print(pIconInfo.ref.hbmColor);
  print(pIconInfo.ref.hbmMask);
  print(pIconInfo.ref.xHotspot);
  print(pIconInfo.ref.yHotspot);
  int hDC = GetDC(hWnd);

  while (true)
  {
    DrawIcon(hDC, 500, 500, iconHandle);
  }
}