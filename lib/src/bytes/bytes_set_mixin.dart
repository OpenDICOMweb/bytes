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

import 'package:bytes/bytes.dart';
import 'package:bytes/src/constants.dart';

/// [BytesSetMixin] is a class that provides a read-only byte array that
/// supports both [Uint8List] and [ByteData] interfaces.
mixin BytesSetMixin implements EndianSetters {
  Uint8List get buf;
  //ByteData get bd;
  //Endian get endian;

  // **** Set ByteData
  /// Copies [length] bytes from other starting at offset into _this_
  /// starting at [start]. [length] defaults [bytes].length.
  void setBytes(int start, Bytes bytes, [int offset = 0, int length]) {
    length ?? bytes.length;
    _checkRange(offset, length);
    final buf1 = bytes.buf;
    for (var i = start, j = offset; i < length; i++, j++) buf[i] = buf1[j];
  }

  /// Sets the bytes at [offset] in _this_ to the bytes in [bd] from
  /// [offset] to [length].
  int setByteData(int start, ByteData bd, [int offset = 0, int length]) {
    length ??= bd.lengthInBytes;
    _checkRange(offset, length);
    for (var i = start, j = offset; i < length; i++, j++)
      buf[i] = bd.getUint8(j);
    return length;
  }


  // **** Int set methods

  /// Sets the byte at [offset] in _this_ to [v].
  void setInt8(int offset, int v) => buf[offset] = v;

  /// Returns the number of bytes set.
  int setInt8List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkRange(offset, length);
    for (var i = start, j = offset; i < length; i++, j++) buf[i] = list[j];
    return length;
  }

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

  /// Sets the byte at [offset] in _this_ to [v].
  void setUint8(int offset, int v) => buf[offset] = v;

  /// Sets the bytes in _this_ from [start] to [start] + [length]
  /// to the elements in [list] from [offset] to [offset] + [length]
  int setUint8List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkRange(offset, length);
    for (var i = start, j = offset; j < length; i++, j++) buf[i] = list[j];
    return length;
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

  // **** String Setters

  // TODO: unit test
  // TODO: what is the use case for having offset and length?
  /// Ascii encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start].
  /// Returns the number of bytes written.
  int setAscii(int start, String s) =>
      _setStringBytes(start, cvt.ascii.encode(s));

  /// Writes the ASCII [String]s in [sList] to _this_ starting at
  /// [start]. Returns the number of bytes written.
  int setAsciiList(int start, List<String> sList, [String separator = '\\']) =>
      _setLatinList(start, sList, separator, 127);

  // TODO: unit test
  /// UTF-8 encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start].
  /// Returns the number of bytes written.
  int setLatin(int start, String s) =>
      _setStringBytes(start, cvt.latin1.encode(s));

  /// Writes the LATIN [String]s in [sList] to _this_ starting at
  /// [start]. Returns the number of bytes written.
  ///
  /// _Note_: All latin character sets are encoded as single 8-bit bytes.
  int setLatinList(int start, List<String> sList, [String separator = '\\']) =>
      _setLatinList(start, sList, separator, 255);

  /// Copy [String]s from [sList] into _this_ separated by [separator].
  // Note: this only works for single byte code points, e.g. Ascii, Latin...).
  int _setLatinList(
      int start, List<String> sList, String separator, int limit) {
    final sepChar = separator.codeUnitAt(0);
    if (sList.isEmpty) return 0;
    final last = sList.length - 1;
    var k = start;

    for (var i = 0; i < sList.length; i++) {
      final s = sList[i];
      for (var j = 0; j < s.length; j++) {
        final c = s.codeUnitAt(j);
        if (c > limit)
          throw ArgumentError('Character code $c is out of range $limit');
        setUint8(k++, s.codeUnitAt(j));
      }
      if (i != last) setUint8(k++, sepChar);
    }
    return k - start;
  }

  // TODO: unit test
  /// UTF-8 encodes [s] and then writes the code units to _this_
  /// starting at [start]. Returns the number of bytes written.
  int setUtf8(int start, String s) =>
      _setStringBytes(start, cvt.utf8.encode(s));

  /// Converts the [String]s in [sList] into a [Uint8List].
  /// Then copies the bytes into _this_ starting at
  /// [start]. Returns the number of bytes written.
  int setUtf8List(int start, List<String> sList, [String separator = '\\']) =>
      setUtf8(start, sList.join(separator));

  /// Moves bytes from [list] to _this_. Returns the number of bytes written.
  int _setStringBytes(int start, Uint8List list) {
    final length = list.length;
    for (var i = 0, j = start; i < length; i++, j++) buf[j] = list[i];
    return length;
  }

  // TODO fix to use Latin
  /// UTF-8 encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start]. Returns the offset
  /// of the last byte + 1.
  ///
  /// Note: Currently only encodes Latin1.
  void setString(int start, String s, [Encoder encoder]) =>
      _setStringBytes(start, encoder(s));


  // **** Internals

  /// Throws a [RangeError] if [offset] and [sizeInBytes] are not in range.
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
