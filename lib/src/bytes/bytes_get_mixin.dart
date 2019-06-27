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

/// [BytesGetMixin] is a class that provides a read-only byte array that
/// supports both [Uint8List] and [ByteData] interfaces.
mixin BytesGetMixin {
  Uint8List get buf;
  int get length;
  ByteData get bd;
  Endian get endian;
  String get endianness;

  int getInt16(int offset);
  int getInt32(int offset);
  Int32x4 getInt32x4(int offset);
  int getInt64(int offset);

  int getUint16(int offset);
  int getUint32(int offset);
  int getUint64(int offset);

  double getFloat32(int offset);
  Float32x4 getFloat32x4(int offset);

  double getFloat64(int offset);
  Float64x2 getFloat64x2(int offset);

  /// If _true_ [Decoder] will allow invalid characters.
  static bool allowInvalid;

  // **** End of Interface

  /// Creates an [Int8List] copy of the specified region of _this_.
  ByteData getByteData([int offset = 0, int length]) =>
      getUint8List(offset, length).buffer.asByteData();

  /// Returns an [ByteData] view of the specified region of _this_.
  ByteData asByteData([int offset = 0, int length]) {
    length ??= buf.length - offset;
    return buf.buffer.asByteData(buf.offsetInBytes + offset, length);
  }

  // **** Signed Integer Lists

  /// Returns the 8-bit _signed_ integer value
  /// (between -128 and 127 inclusive) at index [i].
  int getInt8(int i) => bd.getInt8(i);

  /// Creates an [Int8List] copy of the specified region of _this_.
  Int8List getInt8List([int offset = 0, int length]) {
    length ??= buf.length;
    final list = Int8List(length);
    for (var i = 0, j = offset; i < length; i++, j++) list[i] = bd.getInt8(j);
    return list;
  }

  /// Creates an [Int8List] view of the specified region of _this_.
  Int8List asInt8List([int offset = 0, int length]) =>
      buf.buffer.asInt8List(buf.offsetInBytes + offset, length ??= buf.length);

  /// Creates an [Int16List] copy of the specified region of _this_.
  Int16List getInt16List([int offset = 0, int length]) {
    length ??= _length16(offset);
    final list = Int16List(length);
    for (var i = 0, j = offset; i < length; i++, j += 2) list[i] = getInt16(j);
    return list;
  }

  /// Creates an [Int32List] copy of the specified region of _this_.
  Int32List getInt32List([int offset = 0, int length]) {
    length ??= _length32(offset);
    final list = Int32List(length);
    for (var i = 0, j = offset; i < length; i++, j += 4) list[i] = getInt32(j);
    return list;
  }

  /// Creates an [Int32x4List] copy of the specified region of _this_.
  Int32x4List getInt32x4List([int offset = 0, int length]) {
    length ??= _length128(offset);
    final list = Int32x4List(length);
    for (var i = 0, j = offset; i < length; i++, j += 4)
      list[i] = getInt32x4(j);
    return list;
  }

  /// Creates an [Int64List] copy of the specified region of _this_.
  Int64List getInt64List([int offset = 0, int length]) {
    length ??= _length64(offset);
    final list = Int64List(length);
    for (var i = 0, j = offset; i < length; i++, j += 8) list[i] = getInt64(j);
    return list;
  }

  // **** Unsigned Integer Lists

  /// Returns an 8-bit _unsigned_ integer value
  /// (between 0 and 255 inclusive) at index [i].
  int getUint8(int i) => buf[i];

  /// Returns a [Uint8List] that is a copy of the specified region of _this_.
  Uint8List getUint8List([int offset = 0, int length]) {
    length ??= buf.length;
    final list = Uint8List(length);
    for (var i = 0, j = offset; i < length; i++, j++) list[i] = buf[j];
    return list;
  }

  /// Returns a [String] containing a _UTF-8_ decoding of the specified region.
  Uint8List asUint8List([int offset = 0, int length]) =>
      buf.buffer.asUint8List(offset, length ?? buf.length);

  /// Creates an [Uint16List] copy of the specified region of _this_.
  Uint16List getUint16List([int offset = 0, int length]) {
    length ??= _length16(offset);
    final list = Uint16List(length);
    for (var i = 0, j = offset; i < length; i++, j += 2) list[i] = getUint16(j);
    return list;
  }

  /// Creates an [Uint32List] copy of the specified region of _this_.
  Uint32List getUint32List([int offset = 0, int length]) {
    length ??= _length32(offset);
    final list = Uint32List(length);
    for (var i = 0, j = offset; i < length; i++, j += 4) list[i] = getUint32(j);
    return list;
  }

  /// Creates an [Uint64List] copy of the specified region of _this_.
  Uint64List getUint64List([int offset = 0, int length]) {
    length ??= _length64(offset);
    final list = Uint64List(length);
    for (var i = 0, j = offset; i < length; i++, j += 8) list[i] = getUint64(j);
    return list;
  }

  // **** Float Lists

  /// Creates an [Float32List] copy of the specified region of _this_.
  Float32List getFloat32List([int offset = 0, int length]) {
    length ??= _length32(offset);
    final list = Float32List(length);
    for (var i = 0, j = offset; i < length; i++, j += 4)
      list[i] = getFloat32(j);
    return list;
  }

  /// Creates an [Float32x4List] copy of the specified region of _this_.
  Float32x4List getFloat32x4List([int offset = 0, int length]) {
    length ??= _length128(offset);
    final list = Float32x4List(length);
    for (var i = 0, j = offset; i < length; i++, j += 4)
      list[i] = getFloat32x4(j);
    return list;
  }

  /// Creates an [Float64List] copy of the specified region of _this_.
  Float64List getFloat64List([int offset = 0, int length]) {
    length ??= _length64(offset);
    final list = Float64List(length);
    for (var i = 0, j = offset; i < length; i++, j += 8)
      list[i] = getFloat64(j);
    return list;
  }

  /// Creates an [Float64x2List] copy of the specified region of _this_.
  Float64x2List getFloat64x2List([int offset = 0, int length]) {
    length ??= _length128(offset);
    final list = Float64x2List(length);
    for (var i = 0, j = offset; i < length; i++, j += 4)
      list[i] = getFloat64x2(j);
    return list;
  }

  String getEndian(Endian endian) => endian == Endian.little ? 'LE' : 'BE';

  final _host = Endian.host;

  /// If [offset] is aligned on an 8-byte boundary, returns a [Int16List]
  /// view of the specified region; otherwise, creates a [Int16List] that
  /// is a copy of the specified region and returns it.
  Int16List asInt16List([int offset = 0, int length]) {
    final index = _absIndex(offset);
    length ??= _length16(offset);
    return (_isAligned16(index) && endian == _host)
        ? buf.buffer.asInt16List(index, length)
        : getInt16List(offset, length);
  }

  /// If [offset] is aligned on an 8-byte boundary, returns a [Int32List]
  /// view of the specified region; otherwise, creates a [Int32List] that
  /// is a copy of the specified region and returns it.
  Int32List asInt32List([int offset = 0, int length]) {
    final index = _absIndex(offset);
    length ??= _length32(offset);
    return (_isAligned32(index) && endian == _host)
        ? buf.buffer.asInt32List(index, length)
        : getInt32List(offset, length);
  }

  /// If [offset] is aligned on an 16-byte boundary, returns a [Int32List]
  /// view of the specified region; otherwise, creates a [Int32List] that
  /// is a copy of the specified region and returns it.
  Int32x4List asInt32x4List([int offset = 0, int length]) {
    final index = _absIndex(offset);
    length ??= _length128(offset);
    return (_isAligned128(index) && endian == _host)
        ? buf.buffer.asInt32x4List(index, length)
        : getInt32x4List(offset, length);
  }

  /// If [offset] is aligned on an 8-byte boundary, returns a [Int64List]
  /// view of the specified region; otherwise, creates a [Int64List] that
  /// is a copy of the specified region and returns it.
  Int64List asInt64List([int offset = 0, int length]) {
    final index = _absIndex(offset);
    length ??= _length64(offset);
    return (_isAligned64(index) && endian == _host)
        ? buf.buffer.asInt64List(index, length)
        : getInt64List(offset, length);
  }

  /// If [offset] is aligned on an 8-byte boundary, returns a [Uint16List]
  /// view of the specified region; otherwise, creates a [Uint16List] that
  /// is a copy of the specified region and returns it.
  Uint16List asUint16List([int offset = 0, int length]) {
    length ??= _length16(offset);
    final index = _absIndex(offset);
    return (_isAligned16(index) && endian == _host)
        ? buf.buffer.asUint16List(index, length)
        : getUint16List(offset, length);
  }

  /// If [offset] is aligned on an 8-byte boundary, returns a [Uint32List]
  /// view of the specified region; otherwise, creates a [Uint32List] that
  /// is a copy of the specified region and returns it.
  Uint32List asUint32List([int offset = 0, int length]) {
    length ??= _length32(offset);
    if (length < 0) return null;
    final index = _absIndex(offset);
    return (_isAligned32(index) && endian == _host)
        ? buf.buffer.asUint32List(index, length)
        : getUint32List(offset, length);
  }

  /// If [offset] is aligned on an 8-byte boundary, returns a [Uint64List]
  /// view of the specified region; otherwise, creates a [Uint64List] that
  /// is a copy of the specified region and returns it.
  Uint64List asUint64List([int offset = 0, int length]) {
    length ??= _length64(offset);
    final index = _absIndex(offset);
    return (_isAligned64(index) && endian == _host)
        ? buf.buffer.asUint64List(index, length)
        : getUint64List(offset, length);
  }

  /// If [offset] is aligned on an 8-byte boundary, returns a [Float32List]
  /// view of the specified region; otherwise, creates a [Float32List] that
  /// is a copy of the specified region and returns it.
  Float32List asFloat32List([int offset = 0, int length]) {
    length ??= _length32(offset);
    final index = _absIndex(offset);
    return (_isAligned32(index) && endian == _host)
        ? buf.buffer.asFloat32List(index, length)
        : getFloat32List(offset, length);
  }

  /// If [offset] is aligned on an 16-byte boundary, returns a
  /// [Float32x4List] view of the specified region; otherwise,
  /// creates a [Float32x4List] that is a copy of the specified
  /// region and returns it.
  Float32x4List asFloat32x4List([int offset = 0, int length]) {
    length ??= _length128(offset);
    final index = _absIndex(offset);
    return (_isAligned128(index) && endian == _host)
        ? buf.buffer.asFloat32x4List(index, length)
        : getFloat32x4List(offset, length);
  }

  /// If [offset] is aligned on an 8-byte boundary, returns a [Float64List]
  /// view of the specified region; otherwise, creates a [Float64List] that
  /// is a copy of the specified region and returns it.
  Float64List asFloat64List([int offset = 0, int length]) {
    length ??= _length64(offset);
    final index = _absIndex(offset);
    return (_isAligned64(index) && endian == _host)
        ? buf.buffer.asFloat64List(index, length)
        : getFloat64List(offset, length);
  }

  /// If [offset] is aligned on an 16-byte boundary, returns a [Float64x2List]
  /// view of the specified region; otherwise, creates a [Float64x2List] that
  /// is a copy of the specified region and returns it.
  Float64x2List asFloat64x2List([int offset = 0, int length]) {
    final index = _absIndex(offset);
    length ??= _length128(offset);
    return (_isAligned128(index) && endian == _host)
        ? buf.buffer.asFloat64x2List(index, length)
        : getFloat64x2List(offset, length);
  }

  // **** Get Strings and List<String>

  /// Returns a [String] containing an _ASCII_ decoding of the specified
  /// region of _this_.
  String getAscii([int offset = 0, int length]) =>
      _getString(offset, length, _ascii);

  /// Returns a [List<String>] containing an _ASCII_ decoding of the specified
  /// region of _this_, which is then _split_ using [separator].
  List<String> getAsciiList(
          [int offset = 0, int length, String separator = '\\']) =>
      _split(_getString(offset, length, _ascii), separator);

  /// Returns a [String] containing a _Latin_ decoding of the specified
  /// region of _this_.
  String getLatin([int offset = 0, int length]) =>
      _getString(offset, length, _latin);

  /// Returns a [List<String>] containing an _LATIN_ decoding of the specified
  /// region of _this_, which is then _split_ using [separator].
  List<String> getLatinList(
          [int offset = 0, int length, String separator = '\\']) =>
      _split(_getString(offset, length, _ascii), separator);

  /// Returns a [String] containing a _UTF-8_ decoding of the specified region.
  String getUtf8([int offset = 0, int length]) =>
      _getString(offset, length, _utf8);

  /// Returns a [List<String>] containing an _UTF8_ decoding of the specified
  /// region of _this_, which is then _split_ using [separator].
  List<String> getUtf8List(
          [int offset = 0, int length, String separator = '\\']) =>
      _split(_getString(offset, length, _utf8), separator);

  /// Returns a [String] containing a decoding of the specified region.
  /// If [decoder] is not specified, it defaults to _UTF-8_.
  String getString([int offset = 0, int length, Decoder decoder]) =>
      _getString(offset, length, decoder ?? _utf8);

  /// Returns a [List<String>]. This is done by first decoding
  /// the specified region using [decoder], and then _split_ing the
  /// resulting [String] using the [separator] character.
  List<String> getStringList(
          [int offset = 0,
          int length,
          Decoder decoder,
          String separator = '\\']) =>
      _split(_getString(offset, length, decoder ?? _utf8), separator);

  /// Returns a [String] containing a _Base64_ encoding of the specified
  /// region of _this_.
  String getBase64([int offset = 0, int length]) =>
      cvt.base64.encode(asUint8List(offset, length ?? this.length));

  String _getString(int offset, int length, Decoder decoder) {
    var list = asUint8List(offset, length ?? buf.length);
    return list.isEmpty ? '' : decoder(list, allowInvalid: allowInvalid);
  }

  List<String> _split(String s, [String separator = '\\']) {
    final x = s.trimLeft();
    return (x.isEmpty) ? <String>[] : s.split(separator);
  }


  // **** Internals

  /// Returns the absolute index of [offset] in the underlying [ByteBuffer].
  int _absIndex(int offset) => buf.offsetInBytes + offset;

  /// Returns the number of 32-bit elements from [offset] to
  /// [buf].lengthInBytes, where [offset] is the absolute offset in [buf].
  int _length16(int offset) {
    final len = buf.length - offset;
    if (len % 2 != 0) return -1;
    return len ~/ 2;
  }

  /// Returns the number of 32-bit elements from [offset] to
  /// [buf].lengthInBytes, where [offset] is the absolute offset in [buf].
  int _length32(int offset) {
    final len = buf.length - offset;
    if (len % 4 != 0) return -1;
    return len ~/ 4;
  }

  /// Returns the number of 32-bit elements from [offset] to
  /// [buf].lengthInBytes, where [offset] is the absolute offset in [buf].
  int _length64(int offset) {
    final len = buf.length - offset;
    if (len % 8 != 0) return -1;
    return len ~/ 8;
  }

  /// Returns the number of 32-bit elements from [offset] to
  /// [buf].lengthInBytes, where [offset] is the absolute offset in [buf].
  int _length128(int offset) {
    final len = buf.length - offset;
    if (len % 16 != 0) return -1;
    return len ~/ 16;
  }

  bool _isAligned(int index, int size) => (index % size) == 0;

  // offset is in bytes
  bool _isAligned16(int offset) => _isAligned(offset, 2);
  bool _isAligned32(int offset) => _isAligned(offset, 4);
  bool _isAligned64(int offset) => _isAligned(offset, 8);
  bool _isAligned128(int offset) => _isAligned(offset, 16);

// **** local code
  final _ascii = cvt.ascii.decode;
  final _latin = cvt.latin1.decode;

// Urgent: remove this when cvt.utf8.decode take a Uint8List argument.
  String _utf8(List<int> list, {bool allowInvalid}) {
    final u8List = (list is Uint8List) ? list : Uint8List.fromList(list);
    return cvt.utf8.decode(u8List, allowMalformed: allowInvalid);
  }
}
