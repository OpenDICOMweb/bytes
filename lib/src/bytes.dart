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
import 'package:bytes/src/charset/charset.dart';

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
      : endian = endian ?? Endian.little,
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

/*
  /// Creates a new [Bytes] from [bd]. [endian] defaults to [Endian.little].
  Bytes.fromByteData(ByteData bd, [Endian endian = Endian.little])
      : endian = endian ?? Endian.little,
        buf = bd.buffer.asUint8List(bd.offsetInBytes);

  /// Creates a new [Bytes] that contains the specified view of [list].
  /// [endian] defaults to [Endian.little].
  Bytes.fromUint8List(Uint8List list,
      [int offset = 0, int length, Endian endian = Endian.little])
      : endian = endian ?? Endian.little,
        buf = list.buffer.asUint8List(offset, length ?? list.length);
*/

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

  /// Returns a [Bytes] containing the ASCII encoding of [s].
  factory Bytes.ascii(String s) {
    if (s == null) return null;
    return s.isEmpty ? kEmptyBytes : Bytes.typedDataView(cvt.ascii.encode(s));
  }

  /// Returns [Bytes] containing the UTF-8 encoding of [s];
  factory Bytes.utf8(String s) {
    if (s == null) return null;
    if (s.isEmpty) return kEmptyBytes;
    final Uint8List u8List = cvt.utf8.encode(s);
    return Bytes.typedDataView(u8List);
  }

  /// Returns [Bytes] containing the Latin character set encoding of [s];
  factory Bytes.latin(String s) {
    if (s == null) return null;
    if (s.isEmpty) return kEmptyBytes;
    final u8List = cvt.latin1.encode(s);
    return Bytes.typedDataView(u8List);
  }

  /// Returns [Bytes] containing the [charset] encoding of [s];
  factory Bytes.fromString(String s, Ascii charset) {
    charset ??= utf8;
    if (s == null) return null;
    if (s.isEmpty) return kEmptyBytes;
    return Bytes.typedDataView(charset.encode(s));
  }

  /// Returns a [Bytes] containing ASCII code units.
  ///
  /// The [String]s in [vList] are [join]ed into a single string using
  /// using [separator] (which defaults to '\') to separate them, and
  /// then they are encoded as ASCII, and returned as [Bytes].
  factory Bytes.asciiFromList(List<String> vList, [String separator = '\\']) =>
      Bytes.ascii(_listToString(vList, separator));

  /// Returns a [Bytes] containing UTF-8 code units.
  ///
  /// The [String]s in [vList] are [join]ed into a single string using
  /// using [separator] (which defaults to '\') to separate them, and
  /// then they are encoded as UTF-8 and returned as [Bytes].
  factory Bytes.utf8FromList(List<String> vList, [String separator = '\\']) =>
      Bytes.utf8(_listToString(vList, separator));

  /// Returns a [Bytes] containing Latin (1 - 9) code units.
  ///
  /// The [String]s in [vList] are [join]ed into a single string using
  /// using [separator] (which defaults to '\') to separate them, and
  /// then they are encoded as UTF-8, and returned as [Bytes].
  factory Bytes.latinFromList(List<String> vList, [String separator = '\\']) =>
      Bytes.latin(_listToString(vList, separator));

  /// Returns a [Bytes] containing [charset] code units.
  /// [charset] defaults to UTF8.
  ///
  /// The [String]s in [vList] are [join]ed into a single string using
  /// using [separator] (which defaults to '\') to separate them, and
  /// then they are encoded as UTF-8, and returned as [Bytes].
  factory Bytes.fromStringList(List<String> vList,
          {Ascii charset, String separator = '\\'}) =>
      Bytes.fromString(_listToString(vList, separator), charset ?? utf8);

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
    grow(newLength);
  }

/* Urgent use in BytesReadOnly
  set length(int length) =>
      throw UnsupportedError('$runtimeType: length is not modifiable');
*/

  /// Returns a [String] indicating the endianness of _this_.
  String get endianness => (endian == Endian.little) ? 'LE' : 'BE';

  // **** Growable Methods

  /// Ensures that [buf] is at least [length] long, and grows
  /// the buf if necessary, preserving existing data.
  bool ensureLength(int length) => _ensureLength(buf, length);

  /// Creates a new buffer of length at least [minLength] in size, or if
  /// [minLength == null, at least double the length of the current buffer;
  /// and then copies the contents of the current buffer into the new buffer.
  /// Finally, the new buffer becomes the buffer for _this_.
  bool grow([int minLength]) {
    final old = buf;
    buf = _grow(old, minLength ??= old.lengthInBytes * 2);
    _bd = buf.buffer.asByteData();
    return buf == old;
  }

  @override
  String toString() => '$endianness $runtimeType: ${bufInfo(buf)}';

  /// If _this_ has a length greater than the value, then the
  /// number of bytes displayed by [bufInfo] equal this value.
  int truncateBytesLength = 12;

  /// If _true_ the values in _this_ will be included in [bufInfo].
  bool showByteValues = true;

  /// Returns a [String] with useful information about _this_.
  String bufInfo(Uint8List buf) {
    final start = buf.offsetInBytes;
    final length = buf.lengthInBytes;
    final _length =
        (length > truncateBytesLength) ? truncateBytesLength : length;
    final end = start + length;
    final sb = StringBuffer('$start-$end:$length');
    // TODO: fix for truncated values print [x, y, z, ...]
    if (showByteValues) sb.writeln('${buf.buffer.asUint8List(start, _length)}');
    return '$sb';
  }

  /// Ensures that [list] is at least [minLength] long, and grows
  /// the buf if necessary, preserving existing data.
  static bool _ensureLength(Uint8List list, int minLength) =>
      (minLength > list.lengthInBytes) ? _reallyGrow(list, minLength) : false;

  /// 1 gigabyte.
  static const int k1GB = 1024 * 1024 * 1024;

  /// The maximum length of _this_.
  static const int kMaximumLength = k1GB;

  /// Minimum [Bytes] length.
  static const int kMinLength = 16;

  /// Default [Bytes] length.
  static const int kDefaultLength = 1024;

  /// The default limit for growing _this_.
  static const int kDefaultLimit = 1024 * 1024 * 1024; // 1 GB

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

// TODO maxLength if for DICOM Value Field
String _listToString(List<String> vList, String separator) {
  if (vList == null) return null;
  if (vList.isEmpty) return '';
  return vList.length == 1 ? vList[0] : vList.join(separator);
}

/// If [minLength] is less than or equal to the current length of
/// [buf] returns [buf]; otherwise, returns a new [ByteData] with a length
/// of at least [minLength].
Uint8List _grow(Uint8List buf, int minLength) {
  final oldLength = buf.lengthInBytes;
  return (minLength <= oldLength) ? buf : _reallyGrow(buf, minLength);
}

/// Returns a new [ByteData] with length at least [minLength].
Uint8List _reallyGrow(Uint8List buf, int minLength) {
  var newLength = minLength;
  do {
    newLength *= 2;
    if (newLength >= Bytes.kDefaultLimit) return null;
  } while (newLength < minLength);
  final newBD = Uint8List(newLength);
  for (var i = 0; i < buf.lengthInBytes; i++) newBD[i] = buf[i];
  return newBD;
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
