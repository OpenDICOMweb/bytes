//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

import 'package:bytes/src/bytes.dart';
import 'package:bytes/src/bytes_endian.dart';

/// A [Bytes] that can incrementally grow in size.
abstract class GrowableBytes extends Bytes {
  @override
  Uint8List get buf;

  /// Creates a new [Bytes] containing [length] elements.
  /// [length] defaults to [kDefaultLength] and [endian] defaults
  /// to [Endian.little].
  factory GrowableBytes(
          [int length = Bytes.kDefaultLength, Endian endian = Endian.little]) =>
      (endian == Endian.little)
          ? BytesLittleEndian(length)
          : BytesBigEndian(length);

  /// Returns a view of the specified region of _this_.
  factory GrowableBytes.view(Bytes bytes,
          [int offset = 0, int length, Endian endian = Endian.little]) =>
      (endian == Endian.little)
          ? BytesLittleEndian.view(bytes, offset, length)
          : BytesBigEndian.view(bytes, offset, length);

  /// Creates a new [Bytes] from [bytes] containing the specified region
  /// and [endian]ness. [endian] defaults to [Endian.little].
  factory GrowableBytes.from(Bytes bytes,
          [int offset = 0, int length, Endian endian = Endian.little]) =>
      (endian == Endian.little)
          ? BytesLittleEndian.from(bytes, offset, length)
          : BytesBigEndian.from(bytes, offset, length);

  /// Creates a new [Bytes] from a [TypedData] containing the specified
  /// region (from offset of length) and [endian]ness.
  /// [endian] defaults to [Endian.little].
  factory GrowableBytes.typedDataView(TypedData td,
          [int offset = 0, int length, Endian endian = Endian.little]) =>
      (endian == Endian.little)
          ? BytesLittleEndian.typedDataView(td, offset, length)
          : BytesBigEndian.typedDataView(td, offset, length);
}
