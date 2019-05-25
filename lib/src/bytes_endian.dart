//  Copyright (c) 2016, 2017, 2018
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:convert' as cvt;
import 'dart:typed_data';

import 'package:bytes/src/bytes.dart';
import 'package:bytes/src/constants.dart';
import 'package:bytes/src/bytes_endian_get_mixins.dart';
import 'package:bytes/src/bytes_endian_set_mixins.dart';

/// The length at which _ensureLength_ switches from doubling the
/// underlying [Uint8List] _buf_ to incrementing by [largeChunkIncrement].
int doublingLimit = 128 * k1MB;

/// The incremental increase in the underlying [Uint8List] _buf_ length
/// when growing _buf_, once its length is greater than the [doublingLimit].
int largeChunkIncrement = 4 * k1MB;

/// Bytes Package Overview
///
/// - All get_XXX_List methods return fixed length (unmodifiable) Lists.
/// - All asXXX methods return a view of the specified region.

/// [BytesLittleEndian] is a class that implements a Little Endian
/// byte array that supports both [Uint8List] and [ByteData] interfaces.
class BytesLittleEndian extends Bytes
    with LittleEndianGetMixin, LittleEndianSetMixin {
  /// Creates a new [BytesLittleEndian] from [buf].
  BytesLittleEndian(Uint8List buf) : super(buf);

  /// Creates a new [BytesLittleEndian] containing [length] elements.
  /// [length] defaults to [kDefaultLength] and [endian] defaults
  /// to [Endian.little].
  BytesLittleEndian.empty([int length = kDefaultLength])
      : assert(length >= 0),
        super(Uint8List(length ?? k1MB));

  /// Returns a view of the specified region of _this_.
  BytesLittleEndian.view(Bytes bytes, [int offset = 0, int length])
      : super(_bytesView(bytes.buf, offset, length ?? bytes.length));

  /// Creates a new [Bytes] from [bytes] containing the specified region
  /// and [endian]ness. [endian] defaults to [Endian.little].
  BytesLittleEndian.from(Bytes bytes, [int offset = 0, int length])
      : super(copyUint8List(bytes.buf, offset, length ?? bytes.length));

  /// Creates a new [Bytes] from a [TypedData] containing the specified
  /// region (from offset of length) and [endian]ness.
  /// [endian] defaults to [Endian.little].
  BytesLittleEndian.typedDataView(TypedData td,
      [int offset = 0, int lengthInBytes])
      : super(td.buffer.asUint8List(
            td.offsetInBytes + offset, lengthInBytes ?? td.lengthInBytes));

  /// Creates a new [Bytes] from a [List<int>].  [endian] defaults
  /// to [Endian.little]. Any values in [list] that are larger than 8-bits
  /// are truncated.
  BytesLittleEndian.fromList(List<int> list)
      : super((list is Uint8List) ? list : Uint8List.fromList(list));

  /// Returns a [Bytes] containing the Base64 decoding of [s].
  factory BytesLittleEndian.fromBase64(String s,
      {bool padToEvenLength = false}) {
    if (s.isEmpty) return Bytes.kEmptyBytes;
    var bList = cvt.base64.decode(s);
    final bLength = bList.length;
    if (padToEvenLength == true && bLength.isOdd) {
      // Performance: It would be good to ignore this copy
      final nList = Uint8List(bLength + 1);
      for (var i = 0; i < bLength - 1; i++) nList[i] = bList[i];
      nList[bLength] = 0;
      bList = nList;
    }
    return BytesLittleEndian.typedDataView(bList);
  }

  /// Returns [Bytes] containing a UTF8 encoding of [s];
  factory BytesLittleEndian.fromString(String s) {
    if (s == null) return null;
    if (s.isEmpty) return Bytes.kEmptyBytes;
    final Uint8List list = cvt.utf8.encode(s);
    return BytesLittleEndian.typedDataView(list);
  }

  /// Returns a [Bytes] containing UTF-8 encoding of the concatination of
  /// the [String]s in [vList].
  factory BytesLittleEndian.fromStringList(List<String> vList,
          [String separator = '\\']) =>
      (vList.isEmpty)
          ? Bytes.kEmptyBytes
          : Bytes.fromString(vList.join(separator));
}

/// [BytesBigEndian] is a class that implements a Big Endian byte array
/// that supports both [Uint8List] and [ByteData] interfaces.
class BytesBigEndian extends Bytes with BigEndianGetMixin, BigEndianSetMixin {
  /// Creates a new [BytesBigEndian] from [buf].
  BytesBigEndian(Uint8List buf) : super(buf);

  /// Creates a new [BytesBigEndian] containing [length] elements.
  /// [length] defaults to [kDefaultLength] and [endian] defaults
  /// to [Endian.little].
  BytesBigEndian.empty([int length = kDefaultLength])
      : assert(length >= 0),
        super(Uint8List(length ?? k1MB));

  /// Returns a view of the specified region of _this_.
  BytesBigEndian.view(Bytes bytes, [int offset = 0, int length])
      : super(_bytesView(bytes.buf, offset, length ?? bytes.length));

  /// Creates a new [Bytes] from [bytes] containing the specified region
  /// and [endian]ness. [endian] defaults to [Endian.little].
  BytesBigEndian.from(Bytes bytes, [int offset = 0, int length])
      : super(copyUint8List(bytes.buf, offset, length ?? bytes.length));

  /// Creates a new [Bytes] from a [TypedData] containing the specified
  /// region (from offset of length) and [endian]ness.
  /// [endian] defaults to [Endian.little].
  BytesBigEndian.typedDataView(TypedData td,
      [int offset = 0, int lengthInBytes])
      : super(td.buffer.asUint8List(
            td.offsetInBytes + offset, lengthInBytes ?? td.lengthInBytes));

  /// Creates a new [Bytes] from a [List<int>].  [endian] defaults
  /// to [Endian.little]. Any values in [list] that are larger than 8-bits
  /// are truncated.
  BytesBigEndian.fromList(List<int> list)
      : super((list is Uint8List) ? list : Uint8List.fromList(list));
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
