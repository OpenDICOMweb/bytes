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

  void setInt16(int i, int v) => bd.setInt16(i, v, Endian.little);
  void setInt32(int i, int v) => bd.setInt32(i, v, Endian.little);
  void setInt64(int i, int v) => bd.setInt64(i, v, Endian.little);

  void setUint16(int i, int v) => bd.setUint16(i, v, Endian.little);
  void setUint32(int i, int v) => bd.setUint32(i, v, Endian.little);
  void setUint64(int i, int v) => bd.setUint64(i, v, Endian.little);

  void setFloat32(int i, double v) => bd.setFloat32(i, v, Endian.little);
  void setFloat64(int i, double v) => bd.setFloat64(i, v, Endian.little);
}

mixin BigEndianSetMixin {
  ByteData get bd;

  void setInt16(int i, int v) => bd.setInt16(i, v, Endian.big);
  void setInt32(int i, int v) => bd.setInt32(i, v, Endian.big);
  void setInt64(int i, int v) => bd.setInt64(i, v, Endian.big);

  void setUint16(int i, int v) => bd.setUint16(i, v, Endian.big);
  void setUint32(int i, int v) => bd.setUint32(i, v, Endian.big);
  void setUint64(int i, int v) => bd.setUint64(i, v, Endian.big);

  void setFloat32(int i, double v) => bd.setFloat32(i, v, Endian.big);
  void setFloat64(int i, double v) => bd.setFloat64(i, v, Endian.big);
}
