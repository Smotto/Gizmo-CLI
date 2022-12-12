import 'dart:ffi';
import 'package:ffi/ffi.dart';

final _shell32 = DynamicLibrary.open('shell32.dll');

/// [ExtractIconA]
/// Returns array of icon handles by extracting icons from a: .dll, .exe, or icon file.
/// If [nIconIndex] is -1, and [phiconLarge] and [phiconSmall] are both null,
/// the function returns the total number of icons specified in the .dll or .exe
/// If the file is a .ico, then it returns 1
///
/// '''c
/// UINT ExtractIconExA(
///   [in]  LPCSTR lpszFile,
///   [in]  int    nIconIndex,
///   [out] HICON  *phiconLarge,
///   [out] HICON  *phiconSmall,
///         UINT   nIcons
/// '''
/// {@category shell32}
int ExtractIconExA(
        Pointer<Utf8> lpszFile, int nIconIndex, Pointer<IntPtr> phiconLarge, Pointer<IntPtr> phiconSmall, int nIcons) =>
    _ExtractIconExA(lpszFile, nIconIndex, phiconLarge, phiconSmall, nIcons);

final _ExtractIconExA = _shell32.lookupFunction<
// DLL Function has
    IntPtr Function(Pointer<Utf8> lpszFile, Uint32 nIconIndex, Pointer<IntPtr> phiconLarge, Pointer<IntPtr> phiconSmall,
        Uint32 nIcons),
// Dart Function becomes
    int Function(Pointer<Utf8> lpszFile, int nIconIndex, Pointer<IntPtr> phiconLarge, Pointer<IntPtr> phiconSmall,
        int nIcons)>('ExtractIconExA');

/// [ExtractIconA]
/// Returns a handle by extracting an icon from a: .dll, .exe, or icon file.
///
/// '''c
/// HICON ExtractIconA(
/// [in] HINSTANCE hInst,
/// [in] LPCSTR    pszExeFileName,
///      UINT      nIconIndex
/// );
/// '''
/// {@category shell32}
int ExtractIconA(int hInst, Pointer<Utf8> pszExeFileName, int nIconIndex) =>
    _ExtractIconA(hInst, pszExeFileName, nIconIndex);

final _ExtractIconA = _shell32.lookupFunction<
// DLL Function has
    IntPtr Function(IntPtr hInst, Pointer<Utf8> pszExeFileName, Uint32 nIconIndex),
// Dart Function becomes
    int Function(int hInst, Pointer<Utf8> pszExeFileName, int nIconIndex)>('ExtractIconA');

/// [ExtractAssociatedIconExW]
///
/// '''c
/// HICON ExtractAssociatedIconExW(
/// [in]      HINSTANCE hInst,
/// [in, out] LPWSTR    pszIconPath,
/// [in, out] WORD      *piIconIndex,
/// [in, out] WORD      *piIconId
/// );
/// '''
/// {@category shell32}
int ExtractAssociatedIconExW(
        int hInst, Pointer<Utf16> pszIconPath, Pointer<Uint16> piIconIndex, Pointer<Uint16> pilIconId) =>
    _ExtractAssociatedIconExW(hInst, pszIconPath, piIconIndex, pilIconId);

final _ExtractAssociatedIconExW = _shell32.lookupFunction<
// DLL function has
    IntPtr Function(IntPtr hInst, Pointer<Utf16> pszIconPath, Pointer<Uint16> piIconIndex, Pointer<Uint16> pilIconId),
// Dart Function becomes
    int Function(int hInst, Pointer<Utf16> pszIconPath, Pointer<Uint16> piIconIndex,
        Pointer<Uint16> pilIconId)>('ExtractAssociatedIconExW');

/// [ExtractIconW]
///
/// '''c
/// HICON ExtractIconW(
/// [in] HINSTANCE hInst,
/// [in] LPCWSTR   pszExeFileName,
///      UINT      nIconIndex
/// );
/// '''
/// {@category shell32}
///
int ExtractIconW(int hInst, Pointer<Utf16> pszExeFileName, int nIconIndex) =>
    _ExtractIconW(hInst, pszExeFileName, nIconIndex);

final _ExtractIconW = _shell32.lookupFunction<
// DLL Function has
    IntPtr Function(IntPtr hInst, Pointer<Utf16> pszExeFileName, Uint32 nIconIndex),
// Dart Function becomes
    int Function(int hInst, Pointer<Utf16> pszExeFileName, int nIconIndex)>('ExtractIconW');