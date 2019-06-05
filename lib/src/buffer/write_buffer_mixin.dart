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

/// A mixin with methods for writing to a Bytes buffer.
mixin WriteBufferMixin {
  /// The underlying [Bytes] for _this_.
  Bytes get bytes;

  int get length;

  /// The current read index in the buffer.
  int get rIndex;

  /// The current write index in the buffer.
  int get wIndex;
  set wIndex(int i);

  /// Moves the [wIndex] forward/backward. Returns the new [wIndex].
  int wSkip(int n) {
    final v = wIndex + n;
    if (v <= rIndex || v >= bytes.length)
      throw RangeError.range(v, 0, bytes.length);
    return wIndex = v;
  }

  /// Returns a [ByteData] at [offset] with [length] copied from the
  /// underlying [ByteBuffer].
  ByteData asByteData([int offset, int length]) =>
      bytes.buf.buffer.asByteData(offset, length ?? bytes.length);

  /// Writes a [v] to _this_.
  void write(Bytes v, [int offset = 0, int length]) {
    length ??= v.length;
    _maybeGrow(length);
    for (var i = offset, j = wIndex; i < length; i++, j++)
      bytes.setUint8(j, v[i]);
    wIndex += length;
  }

  /// Writes a [ByteData] to _this_.
  void writeByteData(ByteData bd, [int offset = 0, int length]) {
    length ??= bd.lengthInBytes;
    _maybeGrow(length);
    bytes.setByteData(wIndex, bd, offset, length);
    wIndex += length;
  }

  /// Write [n] as an Int8 value to _this_.
  void writeInt8(int n) {
    _maybeGrow(1);
    bytes.setInt8(wIndex, n);
    wIndex++;
  }

  /// Writes a [List<int>] as a [Int8List] values to _this_.
  void writeInt8List(List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _maybeGrow(length);
    bytes.setInt8List(wIndex, list, offset, length);
    wIndex += length;
  }

  /// Write [n] as an Int16 value to _this_.
  void writeInt16(int n) {
    _maybeGrow(2);
    bytes.setInt16(wIndex, n);
    wIndex += 2;
  }

  /// Writes a [List<int>] as a [Int16List] values to _this_.
  void writeInt16List(List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    final size = length * 2;
    _maybeGrow(size);
    bytes.setInt16List(wIndex, list, offset, length);
    wIndex += size;
  }

  /// Write [n] as an Int32 value to _this_.
  void writeInt32(int n) {
    _maybeGrow(4);
    bytes.setInt32(wIndex, n);
    wIndex += 4;
  }

  /// Writes a [List<int>] as a [Int32List] values to _this_.
  void writeInt32List(List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    final size = length * 4;
    _maybeGrow(size);
    bytes.setInt32List(wIndex, list, offset, length);
    wIndex += size;
  }

  /// Write [n] as an Int64 value to _this_.
  void writeInt64(int n) {
    _maybeGrow(8);
    bytes.setInt64(wIndex, n);
    wIndex += 8;
  }

  /// Writes a [List<int>] as a [Int64List] values to _this_.
  void writeInt64List(List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    final size = length * 8;
    _maybeGrow(size);
    bytes.setInt64List(wIndex, list, offset, length);
    wIndex += size;
  }

  /// Write [n] as an Uint8 value to _this_.
  void writeUint8(int n) {
    _maybeGrow(1);
    bytes.setUint8(wIndex, n);
    wIndex++;
  }

  /// Writes a [List<int>] as a [Uint8List] values to _this_.
  void writeUint8List(List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _maybeGrow(length);
    bytes.setUint8List(wIndex, list, offset, length);
    wIndex += length;
  }

  /// Write [n] as an Uint16 value to _this_.
  void writeUint16(int n) {
    _maybeGrow(2);
    bytes.setUint16(wIndex, n);
    wIndex += 2;
  }

  /// Writes a [List<int>] as a [Uint16List] values to _this_.
  void writeUint16List(List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    final size = length * 2;
    _maybeGrow(size);
    bytes.setUint16List(wIndex, list, offset, length);
    wIndex += size;
  }

  /// Write [n] as an Uint32 value to _this_.
  void writeUint32(int n) {
    assert(n >= 0 && n <= 0xFFFFFFFF, 'Value out if range: $n');
    _maybeGrow(4);
    bytes.setUint32(wIndex, n);
    wIndex += 4;
  }

  /// Writes a [List<int>] as a [Uint32List] values to _this_.
  void writeUint32List(List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    final size = length * 4;
    _maybeGrow(size);
    bytes.setUint32List(wIndex, list, offset, length);
    wIndex += size;
  }

  /// Write [n] as an Uint64 value to _this_.
  void writeUint64(int n) {
    _maybeGrow(8);
    bytes.setUint64(wIndex, n);
    wIndex += 8;
  }

  /// Writes a [List<int>] as a [Uint64List] values to _this_.
  void writeUint64List(List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    final size = length * 8;
    _maybeGrow(size);
    bytes.setUint64List(wIndex, list, offset, length);
    wIndex += size;
  }

  /// Writes a [n] as a Float32 value to _this_.
  void writeFloat32(double n) {
    _maybeGrow(4);
    bytes.setFloat32(wIndex, n);
    wIndex += 4;
  }

  /// Writes a [List<double>] as a [Float32List] values to _this_.
  void writeFloat32List(Float32List list, [int offset = 0, int length]) {
    length ??= list.length;
    final size = length * 4;
    _maybeGrow(size);
    bytes.setFloat32List(wIndex, list, offset, length);
    wIndex += size;
  }

  /// Writes a [n] as a Float64 value to _this_.
  void writeFloat64(double n) {
    _maybeGrow(8);
    bytes.setFloat64(wIndex, n);
    wIndex += 8;
  }

  /// Writes a [List<double>] as a [Float64List] values to _this_.
  void writeFloat64List(List<double> list, [int offset = 0, int length]) {
    length ??= list.length;
    final size = length * 8;
    _maybeGrow(size);
    bytes.setFloat64List(wIndex, list, offset, length);
    wIndex += size;
  }

  // **** String writing methods

  /// Writes a UTF-8 encoding of [s] into _this_ at current [wIndex].
  void writeString(String s) => writeUint8List(cvt.utf8.encode(s));

  /// Writes [length] zeros to _this_.
  bool writeZeros(int length) {
    _maybeGrow(length);
    for (var i = 0, j = wIndex; i < length; i++, j++) bytes[j] = 0;
    wIndex += length;
    return true;
  }

  // **** List writing methods

  /// Ensures that [bytes] has at least [remaining] writable _bytes.
  /// The [bytes] is grows if necessary, and copies existing _bytes into
  /// the new [bytes].
  bool ensureRemaining(int remaining) => _maybeGrow(remaining);

  /// Check that the buffer has enough room to write an object of [size],
  /// the end of the current buf.
  bool maybeGrow(int size) => _maybeGrow(size);

  bool _maybeGrow(int size) {
    if (wIndex + size < bytes.length) return false;
    return bytes.ensureLength(wIndex + size);
  }

  @override
  String toString() => '$runtimeType($bytes.length)[$wIndex]';

  Uint8List close() {
    final list = bytes.asUint8List(0, wIndex);
    _isClosed = true;
    return list;
  }

  bool get isClosed => _isClosed;
  bool _isClosed = false;

  void get reset {
    wIndex = 0;
    _isClosed = false;
  }
}

/// A class with logging methods for WriteBuffers.
abstract class LoggingWriteBufferMixin {
  /// The write index for _this_.
  int get wIndex;

  /// The current writeIndex as a string.
  String get www => 'W@${wIndex.toString().padLeft(5, '0')}';

  /// The beginning of reading something.
  String get wbb => '>$www';

  /// In the middle of reading something.
  String get wmm => '|$www';

  /// The end of reading something.
  String get wee => '<$www';

  /// Returns a [String] containing
  String get pad => ''.padRight('$www'.length);

  /// Returns a warning [String] containing [msg].
  void warn(Object msg) => print('** Warning: $msg $www');

  /// Throws an [Exception] containing [msg].
  void error(Object msg) => throw Exception('**** Error: $msg $www');
}
