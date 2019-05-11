//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:convert' as cvt;
import 'dart:typed_data';

import 'package:bytes/src/bytes.dart';
import 'package:bytes/src/constants.dart';
import 'package:bytes/src/charset/ascii.dart';

/// [BytesSetMixin] is a class that provides a read-only byte array that
/// supports both [Uint8List] and [ByteData] interfaces.
mixin BytesSetMixin {
  Uint8List get buf;
  ByteData get bd;
  Endian get endian;

  // **** End of Interface

  // ********************** Setters ********************************

  // Internal setters take an absolute index [i] into the underlying
  // [ByteBuffer] ([buf].buffer).  The external interface of this package
  // uses [offset]s relative to the current [buf.offsetInBytes].

  // **** Int8 set methods

  void setInt8(int i, int v) => buf[i] = v;

  /// Returns the number of bytes set.
  int setInt8List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kInt8Size);
    for (var i = offset, j = start; i < length; i++, j++) buf[j] = list[i];
    return length;
  }

// Urgent Int List and Uint List methods should be the same
  void setInt16(int i, int v) => bd.setInt16(i, v, endian);

  int setInt16List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kInt16Size);
    for (var i = offset, j = start; i < length; i++, j += 2)
      setInt16(j, list[i]);
    return length * 2;
  }

  void setInt32(int i, int v) => bd.setInt32(i, v, endian);

  int setInt32List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kInt32Size);
    for (var i = offset, j = start; i < length; i++, j += 4)
      setInt32(j, list[i]);
    return length * 4;
  }

  void setInt32x4(int offset, Int32x4 value) {
    var i = offset;
    setInt32(i, value.w);
    setInt32(i += 4, value.x);
    setInt32(i += 4, value.y);
    setInt32(i += 4, value.z);
  }

  void setInt64(int i, int v) => bd.setInt64(i, v, endian);

  int setInt64List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kInt64Size);
    for (var i = offset, j = start; i < length; i++, j += 8)
      setInt64(j, list[i]);
    return length * 6;
  }

  int setInt32x4List(int start, Int32x4List list,
      [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kInt32Size * 4);
    for (var i = offset, j = start; i < length; i++, j += 16)
      setInt32x4(j, list[i]);
    return length * 16;
  }

  // **** Uint set methods

  void setUint8(int i, int v) => buf[i] = v;

  int setUint8List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkRange(offset, length);
    for (var i = start, j = offset; i < length; i++, j++) buf[i] = list[j];
    return length;
  }

  void setUint16(int i, int v) => bd.setUint16(i, v, endian);

  int setUint16List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kUint16Size);
    for (var i = offset, j = start; i < length; i++, j += 2)
      setUint16(j, list[i]);
    return length * 2;
  }

  void setUint32(int i, int v) => bd.setUint32(i, v, endian);

  int setUint32List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kUint32Size);
    for (var i = offset, j = start; i < length; i++, j += 4)
      setUint32(j, list[i]);
    return length * 4;
  }

  void setUint64(int i, int v) => bd.setUint64(i, v, endian);

  int setUint64List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kUint64Size);
    for (var i = offset, j = start; i < length; i++, j += 8)
      setUint64(j, list[i]);
    return length * 8;
  }

  // Float32 set methods

  void setFloat32(int i, double v) => bd.setFloat32(i, v, endian);

  int setFloat32List(int start, List<double> list,
      [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kFloat32Size);
    for (var i = offset, j = start; i < length; i++, j += 4)
      setFloat32(j, list[i]);
    return length * 4;
  }

  void setFloat32x4(int index, Float32x4 v) {
    var i = index;
    setFloat32(i, v.w);
    setFloat32(i += 4, v.x);
    setFloat32(i += 4, v.y);
    setFloat32(i += 4, v.z);
  }

  int setFloat32x4List(int start, Float32x4List list,
      [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, list.length * 16);
    for (var i = offset, j = start; i < length; i++, j += 16)
      setFloat32x4(j, list[i]);
    return length * 16;
  }

  void setFloat64(int i, double v) => bd.setFloat64(i, v, endian);

  int setFloat64List(int start, List<double> list,
      [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kFloat64Size);
    for (var i = offset, j = start; i < length; i++, j += 8)
      setFloat64(j, list[i]);
    return length * 8;
  }

  void setFloat64x2(int index, Float64x2 v) {
    var i = index;
    setFloat64(i, v.x);
    setFloat64(i += 4, v.y);
  }

  int setFloat64x2List(int start, Float64x2List list,
      [int offset = 0, int length]) {
    length ??= list.length;
    _checkLength(offset, length, kFloat64Size);
    for (var i = offset, j = start; i < length; i++, j += 16)
      setFloat64x2(j, list[i]);
    return length * 16;
  }

  // **** String Setters

  void setString(int start, String s, [int offset = 0, int length]) =>
      setUtf8(start, s);

  // **** List Setters

  /// Copies [length] bytes from other starting at offset into _this_
  /// starting at [start]. [length] defaults [bytes].length.
  void setBytes(int start, Bytes bytes, [int offset = 0, int length]) {
    length ?? bytes.length;
    _checkRange(offset, length);
    for (var i = start, j = offset; i < length; i++, j++) buf[i] = bytes[j];
  }

  void setByteData(int start, ByteData bd, [int offset = 0, int length]) =>
      setUint8List(start, bd.buffer.asUint8List(), offset, length);

  // **** String List Setters

  // TODO: unit test
  /// UTF-8 encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start]. Returns the offset
  /// of the last byte + 1.
  int setAscii(int start, String s, [int padChar = kSpace]) =>
      setUint8List(start, cvt.ascii.encode(s));

  /// Writes the ASCII [String]s in [sList] to _this_ starting at
  /// [start]. If [padChar] is not _null_ and the final offset is odd,
  /// then [padChar] is written after the other elements have been written.
  /// Returns the number of bytes written.
  int setAsciiList(int start, List<String> sList, [int padChar = kSpace]) =>
      setAscii(start, sList.join('\\'), padChar);

  // TODO: unit test
  /// UTF-8 encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start]. Returns the offset
  /// of the last byte + 1.
  int setLatin(int start, String s, [int padChar = kSpace]) =>
      setUint8List(start, cvt.latin1.encode(s));

  /// Writes the LATIN [String]s in [sList] to _this_ starting at
  /// [start]. If [padChar] is not _null_ and the final offset is odd,
  /// then [padChar] is written after the other elements have been written.
  /// Returns the number of bytes written.
  /// _Note_: All latin character sets are encoded as single 8-bit bytes.
  int setLatinList(int start, List<String> sList, [int padChar = kSpace]) =>
      setAscii(start, sList.join('\\'), padChar);

  // TODO: unit test
  /// UTF-8 encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start]. Returns the offset
  /// of the last byte + 1.
  int setUtf8(int start, String s, [int padChar = kSpace]) =>
      setUint8List(start, cvt.utf8.encode(s));

  /// Converts the [String]s in [sList] into a [Uint8List].
  /// Then copies the bytes into _this_ starting at
  /// [start]. If [padChar] is not _null_ and the offset of the last
  /// byte written is odd, then [padChar] is written to _this_.
  /// Returns the number of bytes written.
  int setUtf8List(int start, List<String> sList, [int padChar]) =>
      setUtf8(start, sList.join('\\'));

  // **** Internals

  void _checkRange(int offset, int sizeInBytes) {
    final length = offset + sizeInBytes;
    if (length > buf.length)
      throw RangeError('$length is larger then bytes remaining $buf.length');
  }

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
