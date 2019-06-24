// Copyright (c) 2016, 2017, 2018, 2019 Open DICOMweb Project.
// All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Author: Jim Philbin <jfphilbin@gmail.edu> -
// See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

mixin EndianSetters {
  void setInt16(int i, int v);
  void setInt32(int i, int v);
  void setInt64(int i, int v);

  void setUint16(int i, int v);
  void setUint32(int i, int v);
  void setUint64(int i, int v);

  void setFloat32(int i, double v);
  void setFloat64(int i, double v);

  void setInt32x4(int i, Int32x4 v);
  void setFloat32x4(int i, Float32x4 v);
  void setFloat64x2(int i, Float64x2 v);
}

mixin LittleEndianSetMixin implements EndianSetters {
  Uint8List get buf;
  ByteData get bd;

  @override
  void setInt16(int i, int v) => bd.setInt16(i, v, Endian.little);
  @override
  void setInt32(int i, int v) => bd.setInt32(i, v, Endian.little);
  @override
  void setInt64(int i, int v) => bd.setInt64(i, v, Endian.little);

  @override
  void setUint16(int i, int v) => bd.setUint16(i, v, Endian.little);
  @override
  void setUint32(int i, int v) => bd.setUint32(i, v, Endian.little);
  @override
  void setUint64(int i, int v) => bd.setUint64(i, v, Endian.little);

  @override
  void setFloat32(int i, double v) => bd.setFloat32(i, v, Endian.little);
  @override
  void setFloat64(int i, double v) => bd.setFloat64(i, v, Endian.little);

  @override
  void setInt32x4(int offset, Int32x4 value) {
    var i = offset;
    bd
      ..setInt32(i, value.w, Endian.little)
      ..setInt32(i += 4, value.x, Endian.little)
      ..setInt32(i += 4, value.y, Endian.little)
      ..setInt32(i += 4, value.z, Endian.little);
  }

  @override
  void setFloat32x4(int index, Float32x4 v) {
    var i = index;
    bd
      ..setFloat32(i, v.w, Endian.little)
      ..setFloat32(i + 4, v.x, Endian.little)
      ..setFloat32(i + 8, v.y, Endian.little)
      ..setFloat32(i + 12, v.z, Endian.little);
  }

  @override
  void setFloat64x2(int index, Float64x2 v) {
    var i = index;
    bd
      ..setFloat64(i, v.x, Endian.little)
      ..setFloat64(i += 4, v.y, Endian.little);
  }
}

mixin BigEndianSetMixin implements EndianSetters {
  ByteData get bd;

  @override
  void setInt16(int i, int v) => bd.setInt16(i, v, Endian.big);

  @override
  void setInt32(int i, int v) => bd.setInt32(i, v, Endian.big);

  @override
  void setInt64(int i, int v) => bd.setInt64(i, v, Endian.big);

  @override
  void setUint16(int i, int v) => bd.setUint16(i, v, Endian.big);

  @override
  void setUint32(int i, int v) => bd.setUint32(i, v, Endian.big);

  @override
  void setUint64(int i, int v) => bd.setUint64(i, v, Endian.big);

  @override
  void setFloat32(int i, double v) => bd.setFloat32(i, v, Endian.big);

  @override
  void setFloat64(int i, double v) => bd.setFloat64(i, v, Endian.big);

  @override
  void setInt32x4(int offset, Int32x4 value) {
    var i = offset;
    bd..setInt32(i, value.w, Endian.big)..setInt32(
        i += 4, value.x, Endian.big)..setInt32(
        i += 4, value.y, Endian.big)..setInt32(i += 4, value.z, Endian.big);
  }

  @override
  void setFloat32x4(int index, Float32x4 v) {
    var i = index;
    bd..setFloat32(i, v.w, Endian.big)..setFloat32(
        i + 4, v.x, Endian.big)..setFloat32(i + 8, v.y, Endian.big)..setFloat32(
        i + 12, v.z, Endian.big);
  }

  @override
  void setFloat64x2(int index, Float64x2 v) {
    var i = index;
    bd..setFloat64(i, v.x, Endian.big)..setFloat64(i += 4, v.y, Endian.big);
  }
}