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
import 'package:bytes/src/buffer/read_buffer_mixin.dart';
import 'package:bytes/src/buffer/write_buffer_mixin.dart';

/// The base class for Buffer
class BytesBuffer extends BytesBufferBase
    with ReadBufferMixin, WriteBufferMixin {
  @override
  Bytes bytes;
  @override
  int rIndex;
  @override
  int wIndex;

  /// Creates a [BytesBuffer] of [length] starting at [offset] in [bytes].
  BytesBuffer(this.bytes, [int offset = 0, int length])
      : rIndex = offset ?? 0,
        wIndex = length ?? bytes.length;

  /// Creates a [BytesBuffer] from another [BytesBuffer].
  BytesBuffer.from(BytesBuffer rb,
      [int offset = 0, int length, Endian endian = Endian.little])
      : bytes = Bytes.from(rb.bytes, offset, length, endian),
        rIndex = offset ?? rb.bytes.offset,
        wIndex = length ?? rb.bytes.length;

  /// Creates a [BytesBuffer] from a [ByteData].
  BytesBuffer.fromByteData(ByteData td,
      [int offset = 0, int length, Endian endian = Endian.little])
      : bytes = Bytes.typedDataView(td, offset, length, endian),
        rIndex = offset ?? td.offsetInBytes,
        wIndex = length ?? td.lengthInBytes;

  /// Creates a [BytesBuffer] from an [List<int>].
  BytesBuffer.fromList(List<int> list, [Endian endian = Endian.little])
      : bytes = Bytes.fromList(list, endian),
        rIndex = 0,
        wIndex = list.length;

  /// Creates a [BytesBuffer] from a view of [td].
  BytesBuffer.typedDataView(TypedData td,
      [int offset = 0, int length, Endian endian = Endian.little])
      : bytes = Bytes.typedDataView(td, offset, length, endian),
        rIndex = offset ?? td.offsetInBytes,
        wIndex = length ?? td.lengthInBytes;







}
