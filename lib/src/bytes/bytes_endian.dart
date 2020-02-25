//  Copyright (c) 2016, 2017, 2018
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

import 'package:bytes/src/bytes/bytes.dart';
import 'package:bytes/src/constants.dart.old';
import 'package:bytes/src/bytes/bytes_endian_get_mixins.dart';
import 'package:bytes/src/bytes/bytes_endian_set_mixins.dart';

/// Bytes Package Overview
///
/// - All get_XXX_List methods return fixed length (unmodifiable) Lists.
/// - All asXXX methods return a view of the specified region.

/// [BytesLittleEndian] is a class that implements a Little Endian
/// byte array that supports both [Uint8List] and [ByteData] interfaces.
class BytesLittleEndian extends Bytes
    with LittleEndianGetMixin, LittleEndianSetMixin {
  @override
  Uint8List buf;

  /// Creates a new [BytesLittleEndian] from [buf].
  BytesLittleEndian(this.buf);

  /// Creates a new [BytesLittleEndian] containing [length] elements.
  /// [length] defaults to [kDefaultLength] and [endian] defaults
  /// to [Endian.little].
  BytesLittleEndian.empty([int length = kDefaultLength])
      : assert(length >= 0),
        buf = Uint8List(length);

  /// Returns a view of the specified region of _this_.
  BytesLittleEndian.view(Bytes bytes, [int offset = 0, int length])
      : buf = _bytesView(bytes.buf, offset, length ?? bytes.length);

  /// Creates a new [Bytes] from [bytes] containing the specified region
  /// and [endian]ness. [endian] defaults to [Endian.little].
  BytesLittleEndian.from(Bytes bytes, [int offset = 0, int length])
      : buf = copyUint8List(bytes.buf, offset, length ?? bytes.length);

  /// Creates a new [Bytes] from a [TypedData] containing the specified
  /// region (from offset of length) and [endian]ness.
  /// [endian] defaults to [Endian.little].
  BytesLittleEndian.typedDataView(TypedData td,
      [int offset = 0, int lengthInBytes])
      : buf = td.buffer.asUint8List(offset, lengthInBytes ?? td.lengthInBytes);

  /// Creates a new [Bytes] from a [List<int>].  [endian] defaults
  /// to [Endian.little]. Any values in [list] that are larger than 8-bits
  /// are truncated.
  BytesLittleEndian.fromList(List<int> list)
      : buf = (list is Uint8List) ? list : Uint8List.fromList(list);
}

/// [BytesBigEndian] is a class that implements a Big Endian byte array
/// that supports both [Uint8List] and [ByteData] interfaces.
class BytesBigEndian extends Bytes with BigEndianGetMixin, BigEndianSetMixin {
  @override
  Uint8List buf;

  /// Creates a new [BytesBigEndian] from [buf].
  BytesBigEndian(this.buf);

  /// Creates a new [BytesBigEndian] containing [length] elements.
  /// [length] defaults to [kDefaultLength] and [endian] defaults
  /// to [Endian.little].
  BytesBigEndian.empty([int length = kDefaultLength])
      : assert(length >= 0),
        buf = Uint8List(length);

  /// Returns a view of the specified region of _this_.
  BytesBigEndian.view(Bytes bytes, [int offset = 0, int length])
      : buf =_bytesView(bytes.buf, offset, length ?? bytes.length);

  /// Creates a new [Bytes] from [bytes] containing the specified region
  /// and [endian]ness. [endian] defaults to [Endian.little].
  BytesBigEndian.from(Bytes bytes, [int offset = 0, int length])
      : buf =copyUint8List(bytes.buf, offset, length ?? bytes.length);

  /// Creates a new [Bytes] from a [TypedData] containing the specified
  /// region (from offset of length) and [endian]ness.
  /// [endian] defaults to [Endian.little].
  BytesBigEndian.typedDataView(TypedData td,
      [int offset = 0, int lengthInBytes])
      : buf =(td is Uint8List)
            ? td
            : td.buffer.asUint8List(
                td.offsetInBytes + offset, lengthInBytes ?? td.lengthInBytes);

  /// Creates a new [Bytes] from a [List<int>].  [endian] defaults
  /// to [Endian.little]. Any values in [list] that are larger than 8-bits
  /// are truncated.
  BytesBigEndian.fromList(List<int> list)
      : buf =(list is Uint8List) ? list : Uint8List.fromList(list);
}

//TODO: move this to the appropriate place
/// Returns a [ByteData] that is a copy of the specified region of _this_.
Uint8List _bytesView(Uint8List list, int offset, int end) {
  final _offset = list.offsetInBytes + offset;
  final _length = (end ?? list.lengthInBytes) - _offset;
  return list.buffer.asUint8List(_offset, _length);
}

/// Returns a [Uint8List] that is a copy of the specified region of [list].
Uint8List copyUint8List(Uint8List list, int offset, int length) {
  final len = length ?? list.length;
  final copy = Uint8List(len);
  for (var i = 0, j = offset; i < len; i++, j++) copy[i] = list[j];
  return copy;
}
