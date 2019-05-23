// Copyright (c) 2016, 2017, 2018, 2019 Open DICOMweb Project.
// All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Author: Jim Philbin <jfphilbin@gmail.edu> -
// See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

mixin LittleEndianSetMixin {
  Uint8List get buf;
  ByteData get bd;

  Endian get endian => Endian.little;
  String get endianness => 'LE';

  // **** Public Setters

  // Internal setters take an absolute index [i] into the underlying
  // [ByteBuffer] ([buf].buffer).  The external interface of this package
  // uses [offset]s relative to the current [buf.offsetInBytes].

  // **** Int8 set methods

  void setInt8(int i, int v) => buf[i] = v;
  void setInt16(int i, int v) => bd.setInt16(i, v, Endian.little);
  void setInt32(int i, int v) => bd.setInt32(i, v, Endian.little);
  void setInt64(int i, int v) => bd.setInt64(i, v, Endian.little);

  void setInt32x4(int offset, Int32x4 value) {
    var i = offset;
    bd
      ..setInt32(i, value.w, Endian.little)
      ..setInt32(i += 4, value.x, Endian.little)
      ..setInt32(i += 4, value.y, Endian.little)
      ..setInt32(i += 4, value.z, Endian.little);
  }

  // **** Uint set methods

  void setUint8(int i, int v) => buf[i] = v;
  void setUint16(int i, int v) => bd.setUint16(i, v, Endian.little);
  void setUint32(int i, int v) => bd.setUint32(i, v, Endian.little);
  void setUint64(int i, int v) => bd.setUint64(i, v, Endian.little);

  // Float32 set methods

  void setFloat32(int i, double v) => bd.setFloat32(i, v, Endian.little);
  void setFloat64(int i, double v) => bd.setFloat64(i, v, Endian.little);


}

mixin BigEndianSetMixin {
  Uint8List get buf;
  ByteData get bd;

  Endian get endian => Endian.big;


  // **** Public Setters

  // Internal setters take an absolute index [i] into the underlying
  // [ByteBuffer] ([buf].buffer).  The external interface of this package
  // uses [offset]s relative to the current [buf.offsetInBytes].

  // **** Int8 set methods

  void setInt8(int i, int v) => buf[i] = v;
  void setInt16(int i, int v) => bd.setInt16(i, v, Endian.big);
  void setInt32(int i, int v) => bd.setInt32(i, v, Endian.big);
  void setInt64(int i, int v) => bd.setInt64(i, v, Endian.big);

  void setInt32x4(int offset, Int32x4 value) {
    var i = offset;
    bd
      ..setInt32(i, value.w, Endian.big)
      ..setInt32(i += 4, value.x, Endian.big)
      ..setInt32(i += 4, value.y, Endian.big)
      ..setInt32(i += 4, value.z, Endian.big);
  }

  // **** Uint set methods

  void setUint8(int i, int v) => buf[i] = v;
  void setUint16(int i, int v) => bd.setUint16(i, v, Endian.big);
  void setUint32(int i, int v) => bd.setUint32(i, v, Endian.big);
  void setUint64(int i, int v) => bd.setUint64(i, v, Endian.big);

  // Float32 set methods

  void setFloat32(int i, double v) => bd.setFloat32(i, v, Endian.big);
  void setFloat64(int i, double v) => bd.setFloat64(i, v, Endian.big);

 // Urgent should we be range checking values??
  void _checkRange(int offset, int sizeInBytes) =>
      __checkRange(offset, sizeInBytes, buf);
}

void __checkRange(int offset, int sizeInBytes, Uint8List buf) {
  final length = offset + sizeInBytes;
  if (length > buf.length)
    throw RangeError('$length is larger then bytes remaining $buf.length');
}
