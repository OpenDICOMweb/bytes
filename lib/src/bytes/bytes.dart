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

import 'package:bytes/src/bytes/bytes_endian.dart';
import 'package:bytes/src/bytes/bytes_get_mixin.dart';
import 'package:bytes/src/bytes/bytes_set_mixin.dart';
import 'package:bytes/src/constants.dart';

/// Bytes Package Overview
///
/// - All get_XXX_List methods return fixed length (unmodifiable) Lists.
/// - All asXXX methods return a view of the specified region.

/// [Bytes] is a class that provides a read-only byte array that supports both
/// [Uint8List] and [ByteData] interfaces.
abstract class Bytes extends ListBase<int>
    with BytesGetMixin, BytesSetMixin
    implements Comparable<Bytes> {
  @override
  Uint8List get buf;
  set buf(Uint8List list);

  /// Internal Constructor
  Bytes();

  /// Creates a new [Bytes] containing [length] elements.
  /// [length] defaults to [kDefaultLength] and [endian] defaults
  /// to [Endian.little].
  factory Bytes.empty(
          [int length = kDefaultLength, Endian endian = Endian.little]) =>
      (endian == Endian.little)
          ? BytesLittleEndian.empty(length)
          : BytesBigEndian.empty(length);

  /// Returns a view of the specified region of _this_.
  factory Bytes.view(Bytes bytes, [int offset = 0, int length]) =>
      (bytes.endian == Endian.little)
          ? BytesLittleEndian.view(bytes, offset, length)
          : BytesBigEndian.view(bytes, offset, length);

  /// Creates a new [Bytes] from [bytes] containing the specified region
  /// and [endian]ness. [endian] defaults to [bytes].[endian].
  factory Bytes.from(Bytes bytes, [int offset = 0, int length, Endian endian]) {
    endian ??= bytes.endian;
    return (endian == Endian.little)
        ? BytesLittleEndian.from(bytes, offset, length)
        : BytesBigEndian.from(bytes, offset, length);
  }

  /// Creates a new [Bytes] from a [TypedData] containing the specified
  /// region (from offset of length) and [endian]ness.
  /// [endian] defaults to [Endian.little].
  factory Bytes.typedDataView(TypedData td,
          [int offset = 0, int length, Endian endian = Endian.little]) =>
      (endian == Endian.little)
          ? BytesLittleEndian.typedDataView(td, offset, length)
          : BytesBigEndian.typedDataView(td, offset, length);

  /// Creates a new [Bytes] from a [List<int>].  [endian] defaults
  /// to [Endian.little]. Any values in [list] that are larger than 8-bits
  /// are truncated.
  factory Bytes.fromList(List<int> list, [Endian endian = Endian.little]) =>
      (endian == Endian.little)
          ? BytesLittleEndian.fromList(list)
          : BytesBigEndian.fromList(list);

  @override
  int operator [](int i) => buf[i];

  @override
  bool operator ==(Object other) {
    if (other is Bytes) {
      final len = buf.length;
      if (len != other.buf.length) return false;
      for (var i = 0; i < len; i++) if (buf[i] != other.buf[i]) return false;
      return true;
    }
    return false;
  }

  @override
  int get hashCode {
    var hashCode = 0;
    for (var i = 0; i < buf.length; i++) hashCode += buf[i] % 17;
    return hashCode;
  }

  // TODO: test performance of caching _bd vs doing conversion
/*
  ByteData _bd;

  @override
  ByteData get bd => _bd ??= buf.buffer.asByteData(buf.offsetInBytes);
*/

  @override
  ByteData get bd => buf.buffer.asByteData(buf.offsetInBytes);

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
  @override
  String get endianness => (endian == Endian.little) ? 'LE' : 'BE';

  // **** Getters that have no Endianness

  /// Creates an [Bytes] copy of the specified region of _this_.
  Bytes getBytes([int offset = 0, int length]) =>
      Bytes.typedDataView(buf, offset, length ?? buf.length, endian);

  /// Creates a new [Bytes] from _this_ containing the specified region.
  /// The [endian]ness is the same as _this_.
  @override
  Bytes sublist([int start = 0, int end]) =>
      Bytes.fromList(buf.sublist(start, end ??= buf.length), endian);

  /// Returns a view of the specified region of _this_. [endian] defaults
  /// to the same [endian]ness as _this_.
  Bytes asBytes([int offset = 0, int length]) =>
      Bytes.typedDataView(buf, offset, length ?? buf.length, endian);

  /// Sets the byte at [offset] in _this_ to [v].
  @override
  void operator []=(int offset, int v) => buf[offset] = v;

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

  // **** Growable Methods

  ///  Returns _false_ if [length], which must be greater than 0, is
  ///  less then or equal to the current [buf] length; otherwise,
  ///  creates a new [Uint8List] with a _lengthInBytes_ greater than
  ///  [length] and then copies [buf]s bytes into it. Finally,
  ///  [buf] is set to the new [Uint8List].
  ///
  /// [buf] growth is controlled by two parameters: [doublingLimit] and
  /// [largeChunkIncrement]. [buf] size is grown by doubling the size of the
  /// existing [buf] until its length reaches [doublingLimit], after that
  /// the [buf] is grown in increments of [doublingLimit].
  bool ensureLength(int length) {
    assert(length > 0);
    var len = buf.lengthInBytes;
    if (len > length) return false;

    if (len == 0) {
      len = 1;
    } else {
      while (len < length)
        len = (len < doublingLimit) ? len * 2 : len + largeChunkIncrement;
    }

    if (len >= kDefaultLimit) throw const OutOfMemoryError();
    final newBuf = Uint8List(len);
    for (var i = 0; i < buf.lengthInBytes; i++) newBuf[i] = buf[i];
    buf = newBuf;
    // TODO: Remove or keep after testing bd caching
    //    _bd = buf.buffer.asByteData();
    return true;
  }

  @override
  String toString() =>
      '$runtimeType($endianness): $offset-${offset + length}:$length';

  /// The length at which _ensureLength_ switches from doubling the
  /// underlying [Uint8List] _buf_ to incrementing by [largeChunkIncrement].
  static int doublingLimit = 128 * k1MB;

  /// The incremental increase in the underlying [Uint8List] _buf_ length
  /// when growing _buf_, once its length is greater than the [doublingLimit].
  static int largeChunkIncrement = 4 * k1MB;

  /// If _true_ the Decoder will allow invalid characters.
  static bool allowInvalid = true;

  /// The maximum length of _this_.
  static const int kMaximumLength = k1GB;

  /// Minimum [Bytes] length.
  static const int kMinLength = 16;

  /// Default [Bytes] length.
  static const int kDefaultLength = 1024;

  /// The default limit for growing _this_.
  static const int kDefaultLimit = k1GB;

  /// The canonical empty (zero length) [Bytes] object.
  static final Bytes kEmptyBytes = Bytes.empty(0);

  // Urgent: unit test
  /// Returns a [Bytes] containing the ASCII encoding of [s].
  static Bytes fromAscii(String s) => _stringToBytes(s, cvt.ascii.encode);

  /// Returns a [Bytes] containing the ASCII encoding of [list].
  static Bytes fromAsciiList(List<String> list) =>
      _listToBytes(list, cvt.ascii.encode);

  // Urgent: unit test
  /// Returns a [Bytes] containing the Utf8 decoding of [s].
  static Bytes fromLatin(String s) => _stringToBytes(s, cvt.latin1.encode);

  /// Returns a [Bytes] containing the ASCII encoding of [list].
  static Bytes fromLatinList(List<String> list) =>
      _listToBytes(list, cvt.latin1.encode);

  // Urgent: unit test
  /// Returns a [Bytes] containing the Utf8 decoding of [s].
  static BytesLittleEndian fromUtf8(String s) =>
      _stringToBytes(s, cvt.utf8.encode);

  /// Returns a [Bytes] containing the ASCII encoding of [list].
  static Bytes fromUtf8List(List<String> list) =>
      _listToBytes(list, cvt.utf8.encode);

  // Urgent: unit test
  /// Returns a [Bytes] containing the Utf8 decoding of [s].
  static Bytes fromString(String s) => fromUtf8(s);

  /// Returns a [Bytes] containing the ASCII encoding of [list].
  static Bytes fromStringList(List<String> list) => fromUtf8List(list);

  // Urgent: unit test
  /// Returns a [Bytes] containing the Base64 decoding of [s].
  static Bytes fromBase64(String s) => _stringToBytes(s, cvt.ascii.encode);
}

// Urgent: unit test
/// Returns a [Bytes] containing a decoding of [s].
Bytes _stringToBytes(String s, List<int> decoder(String s)) {
  if (s.isEmpty) return Bytes.kEmptyBytes;
  Uint8List list = decoder(s);
  return Bytes.typedDataView(list);
}

/// Returns a [Bytes] containing a decoding of [list].
Bytes _listToBytes(List<String> list, Uint8List decoder(String s)) {
  var s = list.join('\\').trimLeft();
  return _stringToBytes(s, decoder);
}
