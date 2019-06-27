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

typedef Decoder = String Function(Uint8List list, {bool allowInvalid});
typedef Encoder = Uint8List Function(String s);

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

  ByteData _bd;

  @override
  ByteData get bd => _bd ??= buf.buffer.asByteData(buf.offsetInBytes);

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

  /// Returns an [ByteData] view of the specified region of _this_.
  ByteData asByteData([int offset = 0, int length]) {
    length ??= buf.length - offset;
    return buf.buffer.asByteData(buf.offsetInBytes + offset, length);
  }

  /// Returns the 8-bit _signed_ integer value
  /// (between -128 and 127 inclusive) at index [i].
  int getInt8(int i) => bd.getInt8(i);

  /// Creates an [Int8List] copy of the specified region of _this_.
  Int8List getInt8List([int offset = 0, int length]) {
    length ??= buf.length;
    final list = Int8List(length);
    for (var i = 0, j = offset; i < length; i++, j++) list[i] = bd.getInt8(j);
    return list;
  }

  /// Creates an [Int8List] view of the specified region of _this_.
  Int8List asInt8List([int offset = 0, int length]) =>
      buf.buffer.asInt8List(buf.offsetInBytes + offset, length ??= buf.length);

  /// Returns an 8-bit _unsigned_ integer value
  /// (between 0 and 255 inclusive) at index [i].
  int getUint8(int i) => buf[i];

  /// Returns a [Uint8List] that is a copy of the specified region of _this_.
  Uint8List getUint8List([int offset = 0, int length]) {
    length ??= buf.length;
    final list = Uint8List(length);
    for (var i = 0, j = offset; i < length; i++, j++) list[i] = buf[j];
    return list;
  }

  /// Returns a [String] containing a _UTF-8_ decoding of the specified region.
  Uint8List asUint8List([int offset = 0, int length]) =>
      buf.buffer.asUint8List(offset, length ?? buf.length);

  /// Creates an [Int8List] copy of the specified region of _this_.
  ByteData getByteData([int offset = 0, int length]) =>
      getUint8List(offset, length).buffer.asByteData();

  // **** Get Strings and List<String>

  /// Returns a [String] containing an _ASCII_ decoding of the specified
  /// region of _this_.
  String getAscii([int offset = 0, int length]) =>
      _getString(offset, length, _ascii);

  /// Returns a [List<String>] containing an _ASCII_ decoding of the specified
  /// region of _this_, which is then _split_ using [separator].
  List<String> getAsciiList(
          [int offset = 0, int length, String separator = '\\']) =>
      _split(_getString(offset, length, _ascii), separator);

  /// Returns a [String] containing a _Latin_ decoding of the specified
  /// region of _this_.
  String getLatin([int offset = 0, int length]) =>
      _getString(offset, length, _latin);

  /// Returns a [List<String>] containing an _LATIN_ decoding of the specified
  /// region of _this_, which is then _split_ using [separator].
  List<String> getLatinList(
          [int offset = 0, int length, String separator = '\\']) =>
      _split(_getString(offset, length, _ascii), separator);

  /// Returns a [String] containing a _UTF-8_ decoding of the specified region.
  String getUtf8([int offset = 0, int length]) =>
      _getString(offset, length, _utf8);

  /// Returns a [List<String>] containing an _UTF8_ decoding of the specified
  /// region of _this_, which is then _split_ using [separator].
  List<String> getUtf8List(
          [int offset = 0, int length, String separator = '\\']) =>
      _split(_getString(offset, length, _utf8), separator);

  /// Returns a [String] containing a decoding of the specified region.
  /// If [decoder] is not specified, it defaults to _UTF-8_.
  String getString(
          [int offset = 0,
          int length,
          Decoder decoder]) =>
      _getString(offset, length, decoder ?? _utf8);

  /// Returns a [List<String>]. This is done by first decoding
  /// the specified region using [decoder], and then _split_ing the
  /// resulting [String] using the [separator] character.
  List<String> getStringList(
          [int offset = 0,
          int length,
          Decoder decoder,
          String separator = '\\']) =>
      _split(_getString(offset, length, decoder ?? _utf8), separator);

  /// Returns a [String] containing a _Base64_ encoding of the specified
  /// region of _this_.
  String getBase64([int offset = 0, int length]) =>
      cvt.base64.encode(asUint8List(offset, length ?? this.length));

  String _getString(int offset, int length, Decoder decoder) {
    var list = asUint8List(offset, length ?? buf.length);
    return list.isEmpty ? '' : decoder(list, allowInvalid: allowInvalid);
  }

  List<String> _split(String s, [String separator = '\\']) {
    final x = s.trimLeft();
    return (x.isEmpty) ? <String>[] : s.split(separator);
  }

  // **** Setters that have no Endianness

  /// Sets the byte at [offset] in _this_ to [v].
  @override
  void operator []=(int offset, int v) => buf[offset] = v;

  /// Copies [length] bytes from other starting at offset into _this_
  /// starting at [start]. [length] defaults [bytes].length.
  void setBytes(int start, Bytes bytes, [int offset = 0, int length]) {
    length ?? bytes.length;
    _checkRange(offset, length);
    final buf1 = bytes.buf;
    for (var i = start, j = offset; i < length; i++, j++) buf[i] = buf1[j];
  }

  /// Sets the bytes at [offset] in _this_ to the bytes in [bd] from
  /// [offset] to [length].
  int setByteData(int start, ByteData bd, [int offset = 0, int length]) {
    length ??= bd.lengthInBytes;
    _checkRange(offset, length);
    for (var i = start, j = offset; i < length; i++, j++)
      buf[i] = bd.getUint8(j);
    return length;
  }

  /// Sets the byte at [offset] in _this_ to [v].
  void setInt8(int offset, int v) => buf[offset] = v;

  /// Returns the number of bytes set.
  int setInt8List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkRange(offset, length);
    for (var i = start, j = offset; i < length; i++, j++) buf[i] = list[j];
    return length;
  }

  /// Sets the byte at [offset] in _this_ to [v].
  void setUint8(int offset, int v) => buf[offset] = v;

  /// Sets the bytes in _this_ from [start] to [start] + [length]
  /// to the elements in [list] from [offset] to [offset] + [length]
  int setUint8List(int start, List<int> list, [int offset = 0, int length]) {
    length ??= list.length;
    _checkRange(offset, length);
    for (var i = start, j = offset; i < length; i++, j++) buf[i] = list[j];
    return length;
  }

  // **** String Setters

  // TODO: unit test
  // TODO: what is the use case for having offset and length?
  /// Ascii encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start].
  /// Returns the number of bytes written.
  int setAscii(int start, String s) =>
      _setStringBytes(start, cvt.ascii.encode(s));

  /// Writes the ASCII [String]s in [sList] to _this_ starting at
  /// [start]. Returns the number of bytes written.
  int setAsciiList(int start, List<String> sList, [String separator = '\\']) =>
      _setLatinList(start, sList, separator, 127);

  // TODO: unit test
  /// UTF-8 encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start].
  /// Returns the number of bytes written.
  int setLatin(int start, String s) =>
      _setStringBytes(start, cvt.latin1.encode(s));

  /// Writes the LATIN [String]s in [sList] to _this_ starting at
  /// [start]. Returns the number of bytes written.
  ///
  /// _Note_: All latin character sets are encoded as single 8-bit bytes.
  int setLatinList(int start, List<String> sList, [String separator = '\\']) =>
      _setLatinList(start, sList, separator, 255);

  /// Copy [String]s from [sList] into _this_ separated by [separator].
  // Note: this only works for single byte code points, e.g. Ascii, Latin...).
  int _setLatinList(
      int start, List<String> sList, String separator, int limit) {
    final sepChar = separator.codeUnitAt(0);
    if (sList.isEmpty) return 0;
    final last = sList.length - 1;
    var k = start;

    for (var i = 0; i < sList.length; i++) {
      final s = sList[i];
      for (var j = 0; j < s.length; j++) {
        final c = s.codeUnitAt(j);
        if (c > limit)
          throw ArgumentError('Character code $c is out of range $limit');
        setUint8(k++, s.codeUnitAt(j));
      }
      if (i != last) setUint8(k++, sepChar);
    }
    return k - start;
  }

  // TODO: unit test
  /// UTF-8 encodes [s] and then writes the code units to _this_
  /// starting at [start]. Returns the number of bytes written.
  int setUtf8(int start, String s) =>
      _setStringBytes(start, cvt.utf8.encode(s));

  /// Converts the [String]s in [sList] into a [Uint8List].
  /// Then copies the bytes into _this_ starting at
  /// [start]. Returns the number of bytes written.
  int setUtf8List(int start, List<String> sList, [String separator = '\\']) =>
      setUtf8(start, sList.join(separator));

  /// Moves bytes from [list] to _this_. Returns the number of bytes written.
  int _setStringBytes(int start, Uint8List list) {
    final length = list.length;
    for (var i = 0, j = start; i < length; i++, j++) buf[j] = list[i];
    return length;
  }

  // TODO fix to use Latin
  /// UTF-8 encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start]. Returns the offset
  /// of the last byte + 1.
  ///
  /// Note: Currently only encodes Latin1.
  void setString(int start, String s, [Encoder encoder]) =>
      _setStringBytes(start, encoder(s));

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

  /// The length at which _ensureLength_ switches from doubling the
  /// underlying [Uint8List] _buf_ to incrementing by [largeChunkIncrement].
  static int doublingLimit = 128 * k1MB;

  /// The incremental increase in the underlying [Uint8List] _buf_ length
  /// when growing _buf_, once its length is greater than the [doublingLimit].
  static int largeChunkIncrement = 4 * k1MB;

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
    _bd = buf.buffer.asByteData();
    return true;
  }

  @override
  String toString() =>
      '$runtimeType($endianness): $offset-${offset + length}:$length';

  // **** Internals

  void _checkRange(int offset, int sizeInBytes) {
    final length = offset + sizeInBytes;
    if (length > buf.length)
      throw RangeError('$length is larger then bytes remaining $buf.length');
  }

  /// If _true_ [Decoder] will allow invalid characters.
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
  static BytesLittleEndian fromAscii(String s) =>
      _stringToBytes(s, cvt.ascii.encode);

  /// Returns a [Bytes] containing the ASCII encoding of [list].
  static BytesLittleEndian fromAsciiList(List<String> list) =>
      _listToBytes(list, cvt.ascii.encode);

  // Urgent: unit test
  /// Returns a [Bytes] containing the Utf8 decoding of [s].
  static BytesLittleEndian fromLatin(String s) =>
      _stringToBytes(s, cvt.latin1.encode);

  /// Returns a [Bytes] containing the ASCII encoding of [list].
  static BytesLittleEndian fromLatinList(List<String> list) =>
      _listToBytes(list, cvt.latin1.encode);

  // Urgent: unit test
  /// Returns a [Bytes] containing the Utf8 decoding of [s].
  static BytesLittleEndian fromUtf8(String s) =>
      _stringToBytes(s, cvt.utf8.encode);

  /// Returns a [Bytes] containing the ASCII encoding of [list].
  static BytesLittleEndian fromUtf8List(List<String> list) =>
      _listToBytes(list, cvt.utf8.encode);

  // Urgent: unit test
  /// Returns a [Bytes] containing the Utf8 decoding of [s].
  static BytesLittleEndian fromString(String s) => fromUtf8(s);

  /// Returns a [Bytes] containing the ASCII encoding of [list].
  static BytesLittleEndian fromStringList(List<String> list) =>
      fromUtf8List(list);

  // Urgent: unit test
  /// Returns a [Bytes] containing the Base64 decoding of [s].
  static BytesLittleEndian fromBase64(String s) =>
      _stringToBytes(s, cvt.ascii.encode);
}

// Urgent: unit test
/// Returns a [Bytes] containing a decoding of [s].
BytesLittleEndian _stringToBytes(String s, List<int> decoder(String s)) {
  if (s.isEmpty) return Bytes.kEmptyBytes;
  Uint8List list = decoder(s);
  return Bytes.typedDataView(list);
}

/// Returns a [Bytes] containing a decoding of [list].
BytesLittleEndian _listToBytes(List<String> list, Uint8List decoder(String s)) {
  var s = list.join('\\').trimLeft();
  return _stringToBytes(s, decoder);
}

// **** local code
final _ascii = cvt.ascii.decode;
final _latin = cvt.latin1.decode;

// Urgent: remove this when cvt.utf8.decode take a Uint8List argument.
String _utf8(List<int> list, {bool allowInvalid}) {
  final u8List = (list is Uint8List) ? list : Uint8List.fromList(list);
  return cvt.utf8.decode(u8List, allowMalformed: allowInvalid);
}
