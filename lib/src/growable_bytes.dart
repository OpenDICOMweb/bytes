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

/// A [Bytes] that can incrementally grow in size.
class GrowableBytes extends Bytes {
  /// The upper bound on the length of this [Bytes]. If [limit]
  /// is _null_ then its length cannot be changed.

  final int limit;

  /// Returns a new [Bytes] of [length].
  GrowableBytes(
      [int length,
      Endian endian = Endian.little,
      this.limit = Bytes.kDefaultLimit])
      : super(length, endian);

  /// Returns a new [Bytes] of [length].
  GrowableBytes._(int length, Endian endian, this.limit)
      : super(length, endian);

  /// Returns a copy of the specified region and endianness of [Bytes].
  GrowableBytes.from(Bytes bytes,
      [int offset = 0,
      int length,
      Endian endian,
      this.limit = Bytes.kDefaultLimit])
      : super.from(bytes, offset, length, endian);

  /// Returns a view of [td].
  GrowableBytes.typedDataView(TypedData td,
      [int offset = 0,
      int lengthInBytes,
      Endian endian = Endian.little,
      int limit])
      : limit = limit ?? Bytes.k1GB,
        super.typedDataView(td, offset, lengthInBytes, endian);
}
