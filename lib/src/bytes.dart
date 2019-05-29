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

import 'package:bytes/src/bytes_endian.dart';
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
abstract class Bytes extends ListBase<int>
    with BytesGetMixin, BytesSetMixin
    implements Comparable<Bytes> {
  // **** Interface
  // Urgent decide if this interface is needed
/*
  @override
  int getInt16(int i);
  @override
  int getInt32(int i);
  @override
  int getInt64(int i);

  @override
  int getUint16(int i);
  @override
  int getUint32(int i);
  @override
  int getUint64(int i);

  @override
  double getFloat32(int i);
  @override
  double getFloat64(int i);

  @override
  void setInt16(int i, int v);
  @override
  void setInt32(int i, int v);
  @override
  void setInt64(int i, int v);

  @override
  void setUint16(int i, int v);
  @override
  void setUint32(int i, int v);
  @override
  void setUint64(int i, int v);

  @override
  void setFloat32(int i, double v);
  @override
  void setFloat64(int i, double v);
*/

  // **** End interface
  @override
  Uint8List buf;
  ByteData _bd;

  /// Internal Constructor
  Bytes(this.buf);

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

  // Urgent move to DicomBytes
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
  factory Bytes.fromString(String s, [Endian endian = Endian.little]) {
    if (s == null) return null;
    if (s.isEmpty) return kEmptyBytes;
    final Uint8List list = cvt.utf8.encode(s);
    return (endian == Endian.little)
        ? BytesLittleEndian.typedDataView(list)
        : BytesBigEndian.typedDataView(list);
  }

  /// Returns a [Bytes] containing UTF-8 encoding of the concatination of
  /// the [String]s in [vList].
  factory Bytes.fromStringList(List<String> vList,
      [String separator = '\\', Endian endian = Endian.little]) {
    if (vList.isEmpty) return Bytes.kEmptyBytes;
    return (endian == Endian.little)
        ? Bytes.fromString(vList.join(separator), endian)
        : Bytes.fromString(vList.join(separator), endian);
  }

  @override
  int operator [](int i) => buf[i];

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

  // **** Getters that have no Endianness

  /// Creates an [Bytes] copy of the specified region of _this_.
  Bytes getBytes([int offset = 0, int length]) {
    final newBuf = getUint8List(offset, length);
    return Bytes.typedDataView(newBuf);
  }

  /// Creates a new [Bytes] from _this_ containing the specified region.
  /// The [endian]ness is the same as _this_.
  @override
  Bytes sublist([int start = 0, int end]) =>
      getBytes(start, (end ??= buf.length) - start);

  /// Returns a view of the specified region of _this_. [endian] defaults
  /// to the same [endian]ness as _this_.
  Bytes asBytes([int offset = 0, int length]) =>
      Bytes.typedDataView(asUint8List(offset, length ?? this.length));

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
    for (var i = 0, j = offset; i < length; i++, j++) list[i] = buf[j];
    return list;
  }

  /// Creates an [Int8List] view of the specified region of _this_.
  Int8List asInt8List([int offset = 0, int length]) {
    length ??= buf.length - offset;
    return buf.buffer.asInt8List(buf.offsetInBytes + offset, length);
  }

  /// Returns an 8-bit _unsigned_ integer value
  /// (between 0 and 255 inclusive) at index [i].
  int getUint8(int i) => buf[i];

  /// Returns a [Uint8List] that is a copy of the specified region of _this_.
  Uint8List getUint8List([int offset = 0, int length]) {
    length ??= buf.length;
    final copy = Uint8List(length);
    for (var i = 0, j = offset; i < length; i++, j++) copy[i] = buf[j];
    return copy;
  }

/*
  // Allows the removal of padding characters.
  Uint8List asUint8List([int offset = 0, int length]) {
    length ??= buf.length;
    return buf.buffer.asUint8List(buf.offsetInBytes + offset, length);
  }
*/

  /// Returns a [String] containing a _UTF-8_ decoding of the specified region.
  Uint8List asUint8List([int offset = 0, int length]) =>
      buf.buffer.asUint8List(buf.offsetInBytes + offset, length ?? buf.length);

/*
  Uint8List asUint8List([int offset = 0, int length]) {
    length ??= buf.length;
    final index = buf.offsetInBytes + offset;
    if (index < 0 || length > buf.lengthInBytes)
      throw ArgumentError('Invalid Offset: $offset');
    return buf.buffer.asUint8List(index, length);
  }
*/

  /// Creates an [Int8List] copy of the specified region of _this_.
  ByteData getByteData([int offset = 0, int length]) =>
      getUint8List(offset, length).buffer.asByteData();

  // **** Get Strings and List<String>

  /// Returns a [String] containing a _UTF-8_ decoding of the specified region.
  String getString({int offset = 0, int length, bool allowInvalid = true}) =>
      getUtf8(offset: offset, length: length, allowInvalid: allowInvalid);

/*
  /// Returns a [List<String>]. This is done by first decoding
  /// the specified region as _UTF-8_, and then _split_ing the
  /// resulting [String] using the [separator].
  List<String> getStringList(
      {int offset = 0,
        int length,
        bool allowInvalid = true,
        String separator = '\\'}) {
    final s =
    getString(offset: offset, length: length, allowInvalid: allowInvalid);
    return (s.isEmpty) ? <String>[] : s.split(separator);
  }
*/

  /// Returns a [String] containing a _UTF-8_ decoding of the specified region.
  /// Also, allows the removal of padding characters.
  String getUtf8({int offset = 0, int length, bool allowInvalid = true}) =>
      cvt.utf8.decode(asUint8List(offset, length ?? this.length),
          allowMalformed: allowInvalid);

  /// Returns a [String] containing a _ASCII_ decoding of the specified
  /// region of _this_. Also allows the removal of a padding character.
  String getAscii({int offset = 0, int length, bool allowInvalid = true}) =>
      cvt.ascii.decode(asUint8List(offset, length ?? this.length),
          allowInvalid: allowInvalid);

  /// Returns a [String] containing a _Latin_ decoding of the specified
  /// region of _this_. Also allows the removal of a padding character.
  String getLatin({int offset = 0, int length, bool allowInvalid = true}) =>
      cvt.latin1.decode(asUint8List(offset, length ?? this.length),
          allowInvalid: allowInvalid);

  /// Returns a [String] containing a _ASCII_ decoding of the specified
  /// region of _this_. Also allows the removal of a padding character.
  String getBase64([int offset = 0, int length]) =>
      cvt.base64.encode(asUint8List(offset, length ?? this.length));

  // **** Setters that have no Endianness

  /// Sets the byte at [offset] in _this_ to [v].
  @override
  void operator []=(int offset, int v) => buf[offset] = v;

  /// Copies [length] bytes from other starting at offset into _this_
  /// starting at [start]. [length] defaults [bytes].length.
  void setBytes(int start, Bytes bytes, [int offset = 0, int length]) {
    length ?? bytes.length;
    _checkRange(offset, length);
    for (var i = start, j = offset; i < length; i++, j++) buf[i] = bytes[j];
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
    for (var i = offset, j = start; i < length; i++, j++) buf[j] = list[i];
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

  /// UTF-8 encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start]. Returns the offset
  /// of the last byte + 1.
  void setString(int start, String s, [int offset = 0, int length]) =>
      setUtf8(start, s);

  // TODO: unit test
  /// UTF-8 encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start]. Returns the offset
  /// of the last byte + 1.
  int setUtf8(int start, String s) => setUint8List(start, cvt.utf8.encode(s));

/*
  /// Converts the [String]s in [sList] into a [Uint8List].
  /// Then copies the bytes into _this_ starting at
  /// [start].
  /// Returns the number of bytes written.
  int setUtf8List(int start, List<String> sList) =>
      setUtf8(start, sList.join('\\'));
*/

  // TODO: unit test
  /// UTF-8 encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start]. Returns the offset
  /// of the last byte + 1.
  int setAscii(int start, String s) => setUint8List(start, cvt.ascii.encode(s));

/*
  /// Writes the ASCII [String]s in [sList] to _this_ starting at
  /// [start].
  /// Returns the number of bytes written.
  int setAsciiList(int start, List<String> sList) =>
      setAscii(start, sList.join('\\'));
*/

  // TODO: unit test
  /// UTF-8 encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start]. Returns the offset
  /// of the last byte + 1.
  int setLatin(int start, String s) =>
      setUint8List(start, cvt.latin1.encode(s));

/*
  /// Writes the LATIN [String]s in [sList] to _this_ starting at
  /// [start].
  ///
  /// _Note_: All latin character sets are encoded as single 8-bit bytes.
  int setLatinList(int start, List<String> sList) =>
      setAscii(start, sList.join('\\'));
*/

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
    final newBD = Uint8List(len);
    for (var i = 0; i < buf.lengthInBytes; i++) newBD[i] = buf[i];
    buf = newBD;
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
void alignmentError(
    Uint8List buf, int offsetInBytes, int lengthInBytes, int sizeInBytes) {
  throw AlignmentError(buf, offsetInBytes, lengthInBytes, sizeInBytes);
}
