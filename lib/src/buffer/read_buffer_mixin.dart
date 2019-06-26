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

mixin ReadBufferMixin {
  /// The underlying [Bytes] for _this_.
  Bytes get bytes;

  /// The current read index in the buffer.
  int get rIndex;
  set rIndex(int n);

  /// The current write index in the buffer.
  int get wIndex;
  set wIndex(int n);

  bool rHasRemaining(int length);

  Uint8List asUint8List([int start, int length]);
  ByteData asByteData([int offset, int length]);
  void rError(Object msg);

  // **** End of interface

  int rSkip(int n) {
    final v = rIndex + n;
    if (v < 0 || v > wIndex) throw RangeError.range(v, 0, wIndex);
    return rIndex = v;
  }

  ByteData bdView([int start = 0, int end]) {
    end ??= rIndex;
    final length = end - start;
    return bytes.asByteData(start, length);
  }

  int readInt8() {
    final v = bytes.getInt8(rIndex);
    rIndex++;
    return v;
  }

  Int8List readInt8List(int length) {
    final v = bytes.getInt8List(rIndex, length);
    rIndex += length;
    return v;
  }

  int readInt16() {
    final v = bytes.getInt16(rIndex);
    rIndex += 2;
    return v;
  }

  Int16List readInt16List(int length) {
    final v = bytes.getInt16List(rIndex, length);
    rIndex += length * kInt16Size;
    return v;
  }

  int readInt32() {
    final v = bytes.getInt32(rIndex);
    rIndex += 4;
    return v;
  }

  Int32List readInt32List(int length) {
    final v = bytes.getInt32List(rIndex, length);
    rIndex += length * kInt32Size;
    return v;
  }

  int readInt64() {
    final v = bytes.getInt64(rIndex);
    rIndex += 8;
    return v;
  }

  Int64List readInt64List(int length) {
    final v = bytes.getInt64List(rIndex, length);
    rIndex += length * kInt64Size;
    return v;
  }

  int readUint8() {
    final v = bytes.getUint8(rIndex);
    rIndex++;
    return v;
  }

  Uint8List readUint8View([int offset = 0, int length]) {
    length ??= bytes.length;
    final v = asUint8List(rIndex, length);
    rIndex += length;
    return v;
  }

  Uint8List readUint8List(int length) {
    final v = bytes.getUint8List(rIndex, length);
    rIndex += length;
    return v;
  }

  int readUint16() {
    final v = bytes.getUint16(rIndex);
    rIndex += 2;
    return v;
  }

  Uint16List readUint16List(int length) {
    final v = bytes.getUint16List(rIndex, length);
    rIndex += length * kUint16Size;
    return v;
  }

  int readUint32() {
    final v = bytes.getUint32(rIndex);
    rIndex += 4;
    return v;
  }

  Uint32List readUint32List(int length) {
    final v = bytes.getUint32List(rIndex, length);
    rIndex += length * kUint32Size;
    return v;
  }

  int readUint64() {
    final v = bytes.getUint64(rIndex);
    rIndex += 8;
    return v;
  }

  Uint64List readUint64List(int length) {
    final v = bytes.getUint64List(rIndex, length);
    rIndex += length * kUint64Size;
    return v;
  }

  double readFloat32() {
    final v = bytes.getFloat32(rIndex);
    rIndex += 4;
    return v;
  }

  Float32List readFloat32List(int length) {
    final v = bytes.getFloat32List(rIndex, length);
    rIndex += length * kFloat32Size;
    return v;
  }

  double readFloat64() {
    final v = bytes.getFloat64(rIndex);
    rIndex += 8;
    return v;
  }

  Float64List readFloat64List(int length) {
    final v = bytes.getFloat64List(rIndex, length);
    rIndex += length * kFloat64Size;
    return v;
  }

  /// Read a short Value Field Length.
  String readAscii(int length, {bool allowInvalid = true}) {
    final v = bytes.getAscii(rIndex, length);
    rIndex += length;
    return v;
  }

  List<String> readAsciiList(int length,
      {bool allowInvalid = false, String separator = '\\'}) {
    final list = bytes.getAsciiList(rIndex, length);
    rIndex += length;
    return list;
  }

  /// Read a short Value Field Length.
  String readLatin(int length, {bool allowInvalid = true}) {
    final v = bytes.getLatin(rIndex, length);
    rIndex += length;
    return v;
  }

  List<String> readLatinList(int length,
      {bool allowInvalid = false, String separator = '\\'}) {
    final list = bytes.getLatinList(rIndex, length);
    rIndex += length;
    return list;
  }

  /// Read a short Value Field Length.
  String readUtf8(int length, {bool allowInvalid = true}) {
    final s = bytes.getUtf8(rIndex, length);
    rIndex += length;
    return s;
  }

  List<String> readUtf8List(int length,
      {bool allowInvalid = false, String separator = '\\'}) {
    final list = bytes.getUtf8List(rIndex, length);
    rIndex += length;
    return list;
  }

  String readString(int length, {bool allowInvalid = false}) {
    final s = bytes.getString(rIndex, length);
    rIndex += length;
    return s;
  }

  List<String> getStringList(int length, {bool allowInvalid = false}) =>
      bytes.getStringList(rIndex, length);

  List<String> readStringList(int length,
      {bool allowInvalid = false, String separator = '\\'}) {
    final list = bytes.getStringList(rIndex, length);
    rIndex += length;
    return list;
  }

  Uint8List get contentsRead =>
      bytes.buf.buffer.asUint8List(bytes.offset, rIndex);

  Uint8List get contentsUnread => bytes.buf.buffer.asUint8List(rIndex, wIndex);

  Uint8List get contentsWritten => bytes.buf.buffer.asUint8List(rIndex, wIndex);

  @override
  String toString() => '$runtimeType: @R$rIndex @W$wIndex $bytes';

  //Urgent move below this to DicomReadBuffer
  /// The underlying [ByteData]
  ByteData get bd => bytes.bd;
}
