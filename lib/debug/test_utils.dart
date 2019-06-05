// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Original author: Jim Philbin <jfphilbin@gmail.edu> -
// See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

import 'package:bytes/bytes.dart';
import 'package:bytes/bytes_buffer.dart';

// ignore_for_file: public_member_api_docs

ReadBuffer getReadBuffer(TypedData td, [String type = 'LE']) {
  switch (type) {
    case 'LE':
      return getReadBufferLE(td);
    case 'BE':
      return getReadBufferBE(td);
    default:
      throw ArgumentError();
  }
}

ReadBuffer getReadBufferLE(TypedData td) {
  final bytes = BytesLittleEndian.typedDataView(td);
  return ReadBuffer(bytes);
}

ReadBuffer getReadBufferBE(TypedData td) {
  final bytes = BytesBigEndian.typedDataView(td);
  return ReadBuffer(bytes);

}

WriteBuffer getWriteBuffer([int length = 4096, String type = 'LE']) {
  switch (type) {
    case 'LE':
      return getWriteBufferLE(length);
    case 'BE':
      return getWriteBufferBE(length);
    default:
      throw ArgumentError();
  }
}

WriteBuffer getWriteBufferLE(int length) {
  final bytes = BytesLittleEndian.empty(length);
  return WriteBuffer(bytes);
}

WriteBuffer getWriteBufferBE(int length) {
  final bytes = BytesBigEndian.empty(length);
  return WriteBuffer(bytes);
}
