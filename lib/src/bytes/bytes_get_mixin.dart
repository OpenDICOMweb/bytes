//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

/// [BytesGetMixin] is a class that provides a read-only byte array that
/// supports both [Uint8List] and [ByteData] interfaces.
mixin BytesGetMixin {
  Uint8List get buf;
  ByteData get bd;
  Endian get endian;
  String get endianness;

  int getInt16(int i);
  int getInt32(int i);
  int getInt64(int i);

  int getUint16(int i);
  int getUint32(int i);
  int getUint64(int i);

  double getFloat32(int i);
  double getFloat64(int i);

  // **** End of Interface

  // **** Signed Integer Lists

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

  Int32x4 getInt32x4(int offset) => Int32x4(getInt32(offset),
      getInt32(offset + 4), getInt32(offset + 8), getInt32(offset + 12));

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

  Float32x4 getFloat32x4(int offset) => Float32x4(getFloat32(offset),
      getFloat32(offset + 4), getFloat32(offset + 8), getFloat32(offset + 12));

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

  Float64x2 getFloat64x2(int offset) =>
      Float64x2(getFloat64(offset), getFloat64(offset + 8));

  /// Creates an [Float64x2List] copy of the specified region of _this_.
  Float64x2List getFloat64x2List([int offset = 0, int length]) {
    length ??= _length128(offset);
    final list = Float64x2List(length);
    for (var i = 0, j = offset; i < length; i++, j += 4)
      list[i] = getFloat64x2(j);
    return list;
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

  /// If [offset] is aligned on an 16-byte boundary, returns a [Int32List]
  /// view of the specified region; otherwise, creates a [Int32List] that
  /// is a copy of the specified region and returns it.
  Int32x4List asInt32x4List([int offset = 0, int length]) {
    final index = _absIndex(offset);
    length ??= _length128(offset);
    return (_isAligned128(index))
        ? buf.buffer.asInt32x4List(index, length)
        : getInt32x4List(offset, length);
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

  String getEndian(Endian endian) => endian == Endian.little ? 'LE' : 'BE';

  final _host = Endian.host;

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
    final index = _absIndex(offset);
    length ??= _length128(offset);
    return (_isAligned128(index))
        ? buf.buffer.asFloat32x4List(index, length)
        : getFloat32x4List(offset, length);
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

  /// If [offset] is aligned on an 16-byte boundary, returns a [Float64x2List]
  /// view of the specified region; otherwise, creates a [Float64x2List] that
  /// is a copy of the specified region and returns it.
  Float64x2List asFloat64x2List([int offset = 0, int length]) {
    final index = _absIndex(offset);
    length ??= _length128(offset);
    return (_isAligned128(index))
        ? buf.buffer.asFloat64x2List(index, length)
        : getFloat64x2List(offset, length);
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
}
