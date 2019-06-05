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
import 'package:bytes/src/buffer/bytes_buffer_base.dart';
import 'package:bytes/src/buffer/write_buffer_mixin.dart';

/// A writable [ByteBuffer].
class WriteBuffer extends BytesBufferBase with WriteBufferMixin {
  @override
  Bytes bytes;
  @override
  final int rIndex;
  @override
  int wIndex;

  /// Creates a new WriteBuffer from [bytes].
  WriteBuffer(this.bytes)
      : rIndex = 0,
        wIndex = 0;

  /// Creates an empty WriteBuffer.
  WriteBuffer.empty(
      [int length = kDefaultLength, Endian endian = Endian.little])
      : rIndex = 0,
        wIndex = 0,
        bytes = Bytes.empty(length, endian);

  /// Creates a [WriteBuffer] from another [WriteBuffer].
  WriteBuffer.from(WriteBuffer wb,
      [this.rIndex = 0, int length, Endian endian = Endian.little])
      : wIndex = rIndex,
        bytes = Bytes.from(wb.bytes, rIndex, length, endian);

  /// Creates a WriteBuffer from a [Bytes].
  WriteBuffer.fromBytes(this.bytes, this.rIndex, this.wIndex);

  /// Creates a [WriteBuffer] that uses a [TypedData] view of [td].
  WriteBuffer.typedDataView(TypedData td,
      [this.rIndex = 0, int length, Endian endian = Endian.little])
      : wIndex = length ?? td.lengthInBytes,
        bytes = Bytes.typedDataView(
            td, rIndex, length ?? td.lengthInBytes, endian);

  /// Unsupported.
  set rIndex(int i) => throw UnsupportedError('Not readable.');
}
