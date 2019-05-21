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

/// [BytesGetMixin] is a class that provides a read-only byte array that
/// supports both [Uint8List] and [ByteData] interfaces.
mixin BytesGetMixin {
  Uint8List get buf;
  ByteData get bd;
  Endian get endian;

  // **** End of Interface

  // **** Public Getters

  /// Returns an 8-bit integer values at
  ///     `index = [buf].offsetInBytes + [i]`
  /// in the underlying [Uint8List].
  /// _Note_: [i] may be negative.
  int getInt8(int i) => buf[i];

  int getInt16(int i) => bd.getInt16(i, endian);
  int getInt32(int i) => bd.getInt32(i, endian);
  int getInt64(int i) => bd.getInt64(i, endian);

  Int32x4 getInt32x4(int offset) {
    _checkRange(offset, 16);
    var i = offset;
    final w = getInt32(i);
    final x = getInt32(i += 4);
    final y = getInt32(i += 4);
    final z = getInt32(i += 4);
    return Int32x4(w, x, y, z);
  }

  Int32x4List getInt32x4List(int offset, int length) {
    if (length % 4 != 0) throw ArgumentError();
    final result = Int32x4List(length);
    for (var i = 0, off = offset; i < length; i++, off += 16) {
      final v = getInt32x4(off);
      result[i] = v;
    }
    return result;
  }

  /// Returns an 8-bit unsigned integer values at
  ///     `index = [buf].offsetInBytes + [i]`
  /// in the underlying [Uint8List].
  /// _Note_: [i] may be negative.
  int getUint8(int i) => buf[i];
  int getUint16(int i) => bd.getUint16(i, endian);
  int getUint32(int i) => bd.getUint32(i, endian);
  int getUint64(int i) => bd.getUint64(i, endian);

  double getFloat32(int i) => bd.getFloat32(i, endian);

  Float32x4 getFloat32x4(int index) {
    _checkRange(index, 16);
    var i = index;
    final w = getFloat32(i);
    final x = getFloat32(i += 4);
    final y = getFloat32(i += 4);
    final z = getFloat32(i += 4);
    return Float32x4(w, x, y, z);
  }

  double getFloat64(int i) => bd.getFloat64(i, endian);

  Float64x2 getFloat64x2(int index) {
    _checkRange(index, 16);
    var i = index;
    final x = getFloat64(i);
    final y = getFloat64(i += 8);
    return Float64x2(x, y);
  }

  // **** Internal methods for creating copies and views of sub-regions.

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

  bool _isAligned(int index, int size) => (index % size) == 0;

  // offset is in bytes
  bool _isAligned16(int offset) => _isAligned(offset, 2);
  bool _isAligned32(int offset) => _isAligned(offset, 4);
  bool _isAligned64(int offset) => _isAligned(offset, 8);

  // **** TypedData views

  /// Returns an [ByteData] view of the specified region of _this_.
  ByteData _viewOfBuf([int offset = 0, int length]) {
    length ??= buf.length - offset;
    return buf.buffer.asByteData(_absIndex(offset), length);
  }

  //Urgent make this use buf
  /// Returns a view of the specified region of _this_. [endian] defaults
  /// to the same [endian]ness as _this_.
  Bytes asBytes([int offset = 0, int length]) =>
      Bytes.typedDataView(_viewOfBuf(offset, length));

  /// Creates an [ByteData] view of the specified region of _this_.
  ByteData asByteData([int offset = 0, int length]) =>
      _viewOfBuf(offset, (length ??= buf.length) - offset);

  /// Creates an [Int8List] view of the specified region of _this_.
  Int8List asInt8List([int offset = 0, int length]) {
    length ??= buf.length - offset;
    return buf.buffer.asInt8List(_absIndex(offset), length);
  }

  /// If [offset] is aligned on an 8-byte boundary, returns a [Int16List]
  /// view of the specified region; otherwise, creates a [Int16List] that
  /// is a copy of the specified region and returns it.
  Int16List asInt16List([int offset = 0, int length]) {
    final index = _absIndex(offset);
    length ??= _length16(offset);
    return (_isAligned16(index))
        ? buf.buffer.asInt16List(index, length)
        : getInt16List(offset, length);
  }

  /// If [offset] is aligned on an 8-byte boundary, returns a [Int32List]
  /// view of the specified region; otherwise, creates a [Int32List] that
  /// is a copy of the specified region and returns it.
  Int32List asInt32List([int offset = 0, int length]) {
    final index = _absIndex(offset);
    length ??= _length32(offset);
    return (_isAligned32(index))
        ? buf.buffer.asInt32List(index, length)
        : getInt32List(offset, length);
  }

  /// If [offset] is aligned on an 8-byte boundary, returns a [Int64List]
  /// view of the specified region; otherwise, creates a [Int64List] that
  /// is a copy of the specified region and returns it.
  Int64List asInt64List([int offset = 0, int length]) {
    final index = _absIndex(offset);
    length ??= _length64(offset);
    return (_isAligned64(index))
        ? buf.buffer.asInt64List(index, length)
        : getInt64List(offset, length);
  }

  // Allows the removal of padding characters.
  Uint8List asUint8List([int offset = 0, int length]) {
    length ??= buf.length;
    final index = _absIndex(offset);
    return buf.buffer.asUint8List(index, length);
  }

  /// If [offset] is aligned on an 8-byte boundary, returns a [Uint16List]
  /// view of the specified region; otherwise, creates a [Uint16List] that
  /// is a copy of the specified region and returns it.
  Uint16List asUint16List([int offset = 0, int length]) {
    length ??= _length16(offset);
    final index = _absIndex(offset);
    return (_isAligned16(index))
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
    return (_isAligned32(index))
        ? buf.buffer.asUint32List(index, length)
        : getUint32List(offset, length);
  }

  /// If [offset] is aligned on an 8-byte boundary, returns a [Uint64List]
  /// view of the specified region; otherwise, creates a [Uint64List] that
  /// is a copy of the specified region and returns it.
  Uint64List asUint64List([int offset = 0, int length]) {
    length ??= _length64(offset);
    final index = _absIndex(offset);
    return (_isAligned64(index))
        ? buf.buffer.asUint64List(index, length)
        : getUint64List(offset, length);
  }

  /// If [offset] is aligned on an 8-byte boundary, returns a [Float32List]
  /// view of the specified region; otherwise, creates a [Float32List] that
  /// is a copy of the specified region and returns it.
  Float32List asFloat32List([int offset = 0, int length]) {
    length ??= _length32(offset);
    final index = _absIndex(offset);
    return (_isAligned32(index))
        ? buf.buffer.asFloat32List(index, length)
        : getFloat32List(offset, length);
  }

  /// If [offset] is aligned on an 8-byte boundary, returns a [Float64List]
  /// view of the specified region; otherwise, creates a [Float64List] that
  /// is a copy of the specified region and returns it.
  Float64List asFloat64List([int offset = 0, int length]) {
    final index = _absIndex(offset);
    length ??= _length64(offset);
    return (_isAligned64(index))
        ? buf.buffer.asFloat64List(index, length)
        : getFloat64List(offset, length);
  }

  // **** TypedData copies

  /// Creates a new [Bytes] from _this_ containing the specified region.
  /// The [endian]ness is the same as _this_.
  Bytes sublist([int start = 0, int end]) {
    final list = getUint8List(start, (end ??= buf.length) - start);
    return Bytes.typedDataView(list);
  }

  /// Creates an [Int8List] copy of the specified region of _this_.
  Bytes getBytes([int offset = 0, int length]) {
    final bd = getUint8List(offset, length);
    return Bytes.typedDataView(bd);
  }

  /// Creates an [Int8List] copy of the specified region of _this_.
  ByteData getByteData([int offset = 0, int length]) =>
      getUint8List(offset, length).buffer.asByteData();

  /// Creates an [Int8List] copy of the specified region of _this_.
  Int8List getInt8List([int offset = 0, int length]) {
    length ??= buf.length;
    final list = Int8List(length);
    for (var i = 0, j = offset; i < length; i++, j++) list[i] = buf[j];
    return list;
  }

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

  /// Creates an [Int64List] copy of the specified region of _this_.
  Int64List getInt64List([int offset = 0, int length]) {
    length ??= _length64(offset);
    final list = Int64List(length);
    for (var i = 0, j = offset; i < length; i++, j += 8) list[i] = getInt64(j);
    return list;
  }

  // **** Unsigned Integer Lists

  Uint8List getUint8List([int offset = 0, int length]) =>
      copyUint8List(buf, offset, length);
// Urgent merge these
  /// Returns a [Uint8List] that is a copy of the specified region of [list].
  Uint8List copyUint8List(Uint8List list, int offset, int length) {
    final len = length ?? list.length;
    final copy = Uint8List(len);
    for (var i = 0, j = offset; i < len; i++, j++) copy[i] = list[j];
    return copy;
  }

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

  /// Creates an [Float64List] copy of the specified region of _this_.
  Float64List getFloat64List([int offset = 0, int length]) {
    length ??= _length64(offset);
    final list = Float64List(length);
    for (var i = 0, j = offset; i < length; i++, j += 8)
      list[i] = getFloat64(j);
    return list;
  }

  // **** Get Strings and List<String>

  /// Returns a [String] containing a _Base64_ encoding of the specified
  /// region of _this_.
  String getBase64([int offset = 0, int length]) {
    final bList = asUint8List(offset, length);
    return bList.isEmpty ? '' : cvt.base64.encode(bList);
  }

  // Allows the removal of padding characters.
  Uint8List _asUint8ListForString(
      [int offset = 0, int length, bool removePadding]) {
    length ??= buf.length;
    final index = _absIndex(offset);
    if (index < 0 || length > buf.lengthInBytes)
      throw ArgumentError('Invalid Offset: $offset');
    return buf.buffer.asUint8List(index, length);
  }


  /// Returns a [String] containing a _UTF-8_ decoding of the specified region.
  String getString({int offset = 0, int length, bool allowInvalid = true}) {
    final v = _asUint8ListForString(offset, length ?? buf.length);
    return v.isEmpty ? '' : cvt.utf8.decode(v, allowMalformed: true);
  }

  /// Returns a [List<String>]. This is done by first decoding
  /// the specified region as _UTF-8_, and then _split_ing the
  /// resulting [String] using the [separator].
  List<String> getStringList(
      {int offset = 0,
      int length,
      bool allowInvalid = true,
      String separator = '\\'}) {
    final s =
        getString(offset: offset, length: length, allowInvalid: allowInvalid);
    return (s.isEmpty) ? <String>[] : s.split(separator);
  }

  // **** Internals

  /// Returns the absolute index of [offset] in the underlying [ByteBuffer].
  int _absIndex(int offset) => buf.offsetInBytes + offset;

  void _checkRange(int offset, int sizeInBytes) {
    final length = offset + sizeInBytes;
    if (length > buf.length)
      throw RangeError('$length is larger then bytes remaining $buf.length');
  }
}
