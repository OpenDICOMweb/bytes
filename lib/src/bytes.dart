//  Copyright (c) 2016, 2017, 2018
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:collection';
import 'dart:convert' as cvt;
import 'dart:typed_data';

import 'package:bytes/src/bytes_get_mixin.dart';
import 'package:bytes/src/bytes_set_mixin.dart';
import 'package:bytes/src/constants.dart';

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

/// [Bytes] is a class that provides a read-only byte array that supports both
/// [Uint8List] and [ByteData] interfaces.
class Bytes extends ListBase<int>
    with BytesGetMixin, BytesSetMixin
    implements Comparable<Bytes> {
  @override
  Uint8List buf;
  ByteData _bd;
  @override
  Endian endian;

  /// Creates a new [Bytes] containing [length] zero elements.
  /// [length] defaults to [kDefaultLength] and [endian] defaults
  /// to [Endian.little].
  Bytes([int length = kDefaultLength, Endian endian = Endian.little])
      : assert(length >= 0),
        endian = endian ?? Endian.little,
        buf = Uint8List(length ?? 1024 * 1024); //1MB

  /// Returns a view of the specified region of _this_.
  Bytes.view(Bytes bytes,
      [int offset = 0, int length, Endian endian = Endian.little])
      : endian = endian ?? Endian.little,
        buf = _bytesView(bytes.buf, offset, length ?? bytes.length);

  /// Creates a new [Bytes] from [bytes] containing the specified region
  /// and [endian]ness. [endian] defaults to [Endian.little].
  Bytes.from(Bytes bytes,
      [int offset = 0, int length, Endian endian = Endian.little])
      : endian = endian ?? Endian.little,
        buf = copyUint8List(bytes.buf, offset, length ?? bytes.length);

  /// Creates a new [Bytes] from a [TypedData] containing the specified
  /// region (from offset of length) and [endian]ness.
  /// [endian] defaults to [Endian.little].
  Bytes.typedDataView(TypedData td,
      [int offset = 0, int lengthInBytes, Endian endian = Endian.little])
      : endian = endian ?? Endian.little,
        buf = td.buffer.asUint8List(
            td.offsetInBytes + offset, lengthInBytes ?? td.lengthInBytes);

  /// Creates a new [Bytes] from a [List<int>].  [endian] defaults
  /// to [Endian.little]. Any values in [list] that are larger than 8-bits
  /// are truncated.
  Bytes.fromList(List<int> list, [Endian endian = Endian.little])
      : endian = endian ?? Endian.little,
        buf = (list is Uint8List) ? list : Uint8List.fromList(list);

  /// Returns a [Bytes] containing the Base64 decoding of [s].
  factory Bytes.fromBase64(String s, {bool padToEvenLength = false}) {
    if (s.isEmpty) return kEmptyBytes;
    var bList = cvt.base64.decode(s);
    final bLength = bList.length;
    if (padToEvenLength == true && bLength.isOdd) {
      // Performance: It would be good to ignore this copy
      final nList = Uint8List(bLength + 1);
      for (var i = 0; i < bLength - 1; i++) nList[i] = bList[i];
      nList[bLength] = 0;
      bList = nList;
    }
    return Bytes.typedDataView(bList);
  }

  /// Returns [Bytes] containing a UTF8 encoding of [s];
  factory Bytes.fromString(String s) {
    if (s == null) return null;
    if (s.isEmpty) return kEmptyBytes;
    final Uint8List list = cvt.utf8.encode(s);
    return Bytes.typedDataView(list);
  }

  /// Returns a [Bytes] containing UTF-8 encoding of the concatination of
  /// the [String]s in [vList].
  factory Bytes.fromStringList(List<String> vList, [String separator = '\\']) =>
      (vList.isEmpty)
          ? Bytes.kEmptyBytes
          : Bytes.fromString(vList.join(separator));

  @override
  int operator [](int i) => buf[i];

  @override
  void operator []=(int i, int v) => buf[i] = v;

  @override
  bool operator ==(Object other) {
    if (other is Bytes) {
      if (length != other.length) return false;
      for (var i = 0; i < length; i++) if (this[i] != other[i]) return false;
      return true;
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    var hashCode = 0;
    for (var i = 0; i < buf.length; i++) hashCode += buf[i] + i;
    return hashCode;
  }

  @override
  ByteData get bd => _bd ??= buf.buffer.asByteData(buf.offsetInBytes);

  // *** Comparable interface

  /// Compares _this_ with [other] byte by byte.
  /// Returns a negative integer if _this_ is ordered before other, a
  /// positive integer if _this_ is ordered after other, and zero if
  /// _this_ and other are equal.
  ///
  /// Returns -2 _this_ is a proper prefix of [other], and +2 if [other]
  /// is a proper prefix of _this_.
  @override
  int compareTo(Bytes other) {
    final minLength = (length < other.length) ? length : other.length;
    for (var i = 0; i < minLength; i++) {
      final a = this[i];
      final b = other[i];
      if (a == b) continue;
      return (a < b) ? -1 : 1;
    }
    return (length < other.length) ? -2 : 2;
  }

  // **** TypedData interface.

  /// The number of bytes per element in _this_.
  /// _Note_: Included for compatibility with [TypedData].
  int get elementSizeInBytes => 1;

  /// The [ByteBuffer] associated with _this_.
  ByteBuffer get buffer => buf.buffer;

  /// The offset of _this_ in the underlying buffer.
  int get offset => buf.offsetInBytes;

  @override
  int get length => buf.length;

  @override
  set length(int newLength) {
    if (newLength < buf.lengthInBytes) return;
    ensureLength(newLength);
  }

  /// Returns a [String] indicating the endianness of _this_.
  String get endianness => (endian == Endian.little) ? 'LE' : 'BE';

  // **** Growable Methods

  /// Ensures that [buf] is at least [length] long, and grows
  /// the it if necessary, preserving existing data.
  ///
  ///     _Note_" [length] must be greater than 0.
  ///
  /// [buf] growth is controlled by two parameters: [doublingLimit] and
  /// [largeChunkIncrement]. [buf] size is grown by doubling the size of the
  /// existing [buf] until its length reaches [doublingLimit], after that
  /// the [buf] is grown in increments of [doublingLimit].
  bool ensureLength(int length) {
    assert(length > 0);
    var len = buf.lengthInBytes;
    if (length <= len) return false;

    if (len == 0) {
      len = 1;
    } else {
      while (len < length)
        len = (len < doublingLimit) ? len * 2 : len + largeChunkIncrement;
    }

    if (len >= kDefaultLimit) throw const OutOfMemoryError();
    final newBD = Uint8List(len);
    for (var i = 0; i < buf.lengthInBytes; i++) newBD[i] = buf[i];
    buf = newBD;
    _bd = buf.buffer.asByteData();
    return true;
  }

  @override
  String toString() =>
      '$endianness $runtimeType: $offset-${offset + length}:$length';

  /// The maximum length of _this_.
  static const int kMaximumLength = k1GB;

  /// Minimum [Bytes] length.
  static const int kMinLength = 16;

  /// Default [Bytes] length.
  static const int kDefaultLength = 1024;

  /// The default limit for growing _this_.
  static const int kDefaultLimit = k1GB;

  /// The canonical empty (zero length) [Bytes] object.
  static final Bytes kEmptyBytes = Bytes(0);
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

///
class AlignmentError extends Error {
  /// The Uint8List with the error.
  final Uint8List buf;

  /// The offset in [buf]'
  final int offsetInBytes;

  /// The length in from [offsetInBytes] in [buf].
  final int lengthInBytes;

  /// The element size in bytes.
  final int sizeInBytes;

  /// Constructor
  AlignmentError(
      this.buf, this.offsetInBytes, this.lengthInBytes, this.sizeInBytes);
}

/// Throws an [Alignment Error].
// ignore: prefer_void_to_null
Null alignmentError(
    Uint8List buf, int offsetInBytes, int lengthInBytes, int sizeInBytes) {
  throw AlignmentError(buf, offsetInBytes, lengthInBytes, sizeInBytes);
}
