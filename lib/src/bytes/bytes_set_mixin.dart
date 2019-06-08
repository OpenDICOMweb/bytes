//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

import 'package:bytes/bytes.dart';
import 'package:bytes/src/constants.dart';

/// [BytesSetMixin] is a class that provides a read-only byte array that
/// supports both [Uint8List] and [ByteData] interfaces.
mixin BytesSetMixin implements EndianSetters {
  Uint8List get buf;
  ByteData get bd;
  Endian get endian;

  // **** Int set methods

  int setInt16List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kInt16Size);
    for (var i = offset, j = start; i < length; i++, j += 2)
      setInt16(j, list[i]);
    return length * 2;
  }

  int setInt32List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kInt32Size);
    for (var i = offset, j = start; i < length; i++, j += 4)
      setInt32(j, list[i]);
    return length * 4;
  }


  /// Creates an [Int32x4List] copy of the specified region of _this_.
  int setInt32x4List(int start, List<Int32x4> list,
      [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kInt32x4Size);
    for (var i = offset, j = start; i < length; i++, j += 16)
      setInt32x4(j, list[i]);
    return length * 16;
  }

  int setInt64List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kInt64Size);
    for (var i = offset, j = start; i < length; i++, j += 8)
      setInt64(j, list[i]);
    return length * 6;
  }

  int setUint16List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kUint16Size);
    for (var i = offset, j = start; i < length; i++, j += 2)
      setUint16(j, list[i]);
    return length * 2;
  }

  int setUint32List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kUint32Size);
    for (var i = offset, j = start; i < length; i++, j += 4)
      setUint32(j, list[i]);
    return length * 4;
  }

  int setUint64List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kUint64Size);
    for (var i = offset, j = start; i < length; i++, j += 8)
      setUint64(j, list[i]);
    return length * 8;
  }

  // Float32 set List methods

  int setFloat32List(int start, List<double> list,
      [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kFloat32Size);
    for (var i = offset, j = start; i < length; i++, j += 4)
      setFloat32(j, list[i]);
    return length * 4;
  }

  int setFloat32x4List(int start, Float32x4List list,
      [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, list.length * 16);
    for (var i = offset, j = start; i < length; i++, j += 16)
      setFloat32x4(j, list[i]);
    return length * 16;
  }

  int setFloat64List(int start, List<double> list,
      [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kFloat64Size);
    for (var i = offset, j = start; i < length; i++, j += 8)
      setFloat64(j, list[i]);
    return length * 8;
  }

  int setFloat64x2List(int start, Float64x2List list,
      [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kFloat64Size);
    for (var i = offset, j = start; i < length; i++, j += 16)
      setFloat64x2(j, list[i]);
    return length * 16;
  }

  // **** Internals

  /// Checks that buf[bufOffset, buf.length] >= vLengthInBytes.
  /// [start] is the offset in [buf]. [length] is the number of elements.
  /// Size is the number of bytes in each element.
  bool _checkLength(int start, int length, int size) {
    final vLengthInBytes = length * size;
    final limit = buf.lengthInBytes - (buf.offsetInBytes + start);
    if (vLengthInBytes > limit) {
      throw RangeError('List ($vLengthInBytes bytes) is too large for '
          'Bytes($limit bytes');
    }
    return true;
  }
}
