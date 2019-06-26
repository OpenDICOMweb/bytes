//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

import 'package:bytes/bytes.dart';
import 'package:bytes/src/buffer/bytes_buffer_base.dart';
import 'package:bytes/src/buffer/read_buffer_mixin.dart';

/// A read only BytesBuffer.

class ReadBuffer extends BytesBufferBase with ReadBufferMixin {
  @override
  final Bytes bytes;
  @override
  int rIndex;
  @override
  int get wIndex => bytes.length;
  @override
  set wIndex(int offset) => throw UnsupportedError('wIndex is not settable');

  /// Creates a [ReadBuffer] of [length] starting at [offset] in [bytes].
  ReadBuffer(Bytes bytes, [int offset = 0, int length])
      : bytes = bytes.asBytes(offset, length),
        rIndex = 0;

  /// Creates a [ReadBuffer] from another [ReadBuffer].
  ReadBuffer.from(ReadBuffer rb,
      [int offset = 0, int length, Endian endian = Endian.little])
      : bytes = Bytes.from(rb.bytes, offset, length, endian),
        rIndex = offset ?? rb.bytes.offset;

  /// Creates a [ReadBuffer] from a [ByteData].
  ReadBuffer.fromByteData(ByteData td,
      [int offset = 0, int length, Endian endian = Endian.little])
      : bytes = Bytes.typedDataView(td, offset, length, endian),
        rIndex = offset ?? td.offsetInBytes;

  /// Creates a [ReadBuffer] from an [List<int>].
  ReadBuffer.fromList(List<int> list, [Endian endian = Endian.little])
      : bytes = Bytes.fromList(list, endian),
        rIndex = 0;

  /// Creates a [ReadBuffer] from a view of [td].
  ReadBuffer.typedDataView(TypedData td,
      [int offset = 0, int length, Endian endian = Endian.little])
      : bytes = Bytes.typedDataView(td, offset, length, endian),
        rIndex = offset ?? td.offsetInBytes;

  /// Return a new Big Endian[ReadBuffer] containing the unread
  /// portion of _this_.
  ReadBuffer get asBigEndian =>
      ReadBuffer.from(this, rIndex, wIndex, Endian.big);

  /// Return a new Little Endian[ReadBuffer] containing the unread
  /// portion of _this_.
  ReadBuffer get asLittleEndian =>
      ReadBuffer.from(this, rIndex, wIndex, Endian.little);
}

/// A mixin used for logging [ReadBuffer] methods.
mixin LoggingReadBufferMixin {
  /// The read index into the underlying [Bytes].
  int get rIndex;

  String get _rrr => 'R@${rIndex.toString().padLeft(5, '0')}';

  /// The current readIndex as a string.
  String get rrr => _rrr;

  /// The beginning of reading something.
  String get rbb => '> $_rrr';

  /// In the middle of reading something.
  String get rmm => '| $_rrr';

  /// The end of reading something.
  String get ree => '< $_rrr';

  /// Right pads [rrr] with spaces.
  String get pad => ''.padRight('$_rrr'.length);
}

/// A [ReadBuffer] that logs calls to methods.
class LoggingReadBuffer extends ReadBuffer with LoggingReadBufferMixin {
  /// Creates a [LoggingReadBuffer] from [ByteData].
  factory LoggingReadBuffer(Uint8List buf,
          [int offset = 0, int length, Endian endian = Endian.little]) =>
      LoggingReadBuffer._(
          buf.buffer.asUint8List(offset, length), 0, length, endian);

  /// Creates a [LoggingReadBuffer] from a [Uint8List].
  factory LoggingReadBuffer.fromByteData(ByteData bd,
      [int offset = 0, int length, Endian endian = Endian.little]) {
    final td = bd.buffer.asUint8List(offset, length);
    return LoggingReadBuffer._(td, offset, length, endian);
  }

  LoggingReadBuffer._(TypedData td,
      [int offset = 0, int length, Endian endian = Endian.little])
      : super.typedDataView(td, offset, length, endian);
}
