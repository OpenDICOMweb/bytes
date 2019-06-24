// Copyright (c) 2016, 2017, 2018, 2019 Open DICOMweb Project.
// All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Author: Jim Philbin <jfphilbin@gmail.edu> -
// See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

// Issue: add alignment and length check
mixin LittleEndianGetMixin {
  Uint8List get buf;
  ByteData get bd;

  Endian get endian => Endian.little;

  /// Returns a [String] indicating the endianness of _this_.
  String get endianness => 'LE';

  int getInt16(int i) => bd.getInt16(_check(i, 2), Endian.little);
  int getInt32(int i) => bd.getInt32(_check(i, 4), Endian.little);
  int getInt64(int i) => bd.getInt64(_check(i, 8), Endian.little);

  int getUint16(int i) => bd.getUint16(_check(i, 2), Endian.little);
  int getUint32(int i) => bd.getUint32(_check(i, 4), Endian.little);
  int getUint64(int i) => bd.getUint64(_check(i, 8), Endian.little);

  double getFloat32(int i) => bd.getFloat32(_check(i, 4), Endian.little);
  double getFloat64(int i) => bd.getFloat64(_check(i, 8), Endian.little);

  Int32x4 getInt32x4(int offset) {
    var i = __check(offset, 16, bd);
    final w = bd.getInt32(i, Endian.little);
    final x = bd.getInt32(i + 4, Endian.little);
    final y = bd.getInt32(i + 8, Endian.little);
    final z = bd.getInt32(i + 12, Endian.little);
    return Int32x4(w, x, y, z);
  }

  Float32x4 getFloat32x4(int offset) {
    var i = _check(offset, 16);
    final w = bd.getFloat32(i, Endian.little);
    final x = bd.getFloat32(i + 4, Endian.little);
    final y = bd.getFloat32(i + 8, Endian.little);
    final z = bd.getFloat32(i + 12, Endian.little);
    return Float32x4(w, x, y, z);
  }


  Float64x2 getFloat64x2(int offset) {
    var i = _check(offset, 16);
    final x = bd.getFloat64(i, Endian.little);
    final y = bd.getFloat64(i + 8, Endian.little);
    return Float64x2(x, y);
  }

  int _check(int offset, int size) => __check(offset, size, bd);
}

mixin BigEndianGetMixin {
  Uint8List get buf;
  ByteData get bd;

  Endian get endian => Endian.big;

  /// Returns a [String] indicating the endianness of _this_.
  String get endianness => 'BE';

  int getInt16(int i) => bd.getInt16(_check(i, 2), Endian.big);
  int getInt32(int i) => bd.getInt32(_check(i, 4), Endian.big);
  int getInt64(int i) => bd.getInt64(_check(i, 8), Endian.big);

  Int32x4 getInt32x4(int offset) {
    var i = _check(offset, 16);
    final w = bd.getInt32(i, Endian.big);
    final x = bd.getInt32(i + 4, Endian.big);
    final y = bd.getInt32(i + 8, Endian.big);
    final z = bd.getInt32(i + 12, Endian.big);
    return Int32x4(w, x, y, z);
  }

  int getUint16(int i) => bd.getUint16(_check(i, 2), Endian.big);
  int getUint32(int i) => bd.getUint32(_check(i, 4), Endian.big);
  int getUint64(int i) => bd.getUint64(_check(i, 8), Endian.big);

  double getFloat32(int i) => bd.getFloat32(_check(i, 4), Endian.big);

  Float32x4 getFloat32x4(int offset) {
    var i = _check(offset, 16);
    final w = bd.getFloat32(i, Endian.big);
    final x = bd.getFloat32(i + 4, Endian.big);
    final y = bd.getFloat32(i + 8, Endian.big);
    final z = bd.getFloat32(i + 12, Endian.big);
    return Float32x4(w, x, y, z);
  }

  double getFloat64(int i) => bd.getFloat64(_check(i, 8), Endian.big);

  Float64x2 getFloat64x2(int offset) {
    var i = _check(offset, 16);
    final x = bd.getFloat64(i, Endian.big);
    final y = bd.getFloat64(i + 8, Endian.big);
    return Float64x2(x, y);
  }

  int _check(int offset, int size) => __check(offset, size, bd);
}

// Urgent: are this check necessary with ByteData
int __check(int offset, int size, ByteData bd) {
  var start = bd.offsetInBytes + offset;
  var remaining = bd.lengthInBytes - start;
  if (size > remaining)
    throw ArgumentError('$size is greater than $remaining remaining int $bd');
  return offset;
}
