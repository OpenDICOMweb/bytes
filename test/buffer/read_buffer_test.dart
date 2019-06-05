//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:convert' as cvt;
import 'package:bytes/bytes.dart';
import 'package:bytes/bytes_buffer.dart';
import 'package:rng/rng.dart';
import 'package:test/test.dart';

void main() {
  final rng = RNG();
  group('Bytes Tests', () {
    test('ReadBuffer', () {
      final vList = ['1q221', 'sadaq223'];
      final bytes0 = Bytes.fromString(vList.join('\\'));
      final rBuf = ReadBuffer(bytes0);

      expect(rBuf.bytes.buf.buffer == bytes0.buffer, isTrue);
      expect(rBuf.bytes == bytes0, isTrue);
      expect(rBuf.length == bytes0.length, isTrue);
      expect(rBuf.bytes.buf.buffer.lengthInBytes == bytes0.buffer.lengthInBytes,
          true);
      expect(rBuf.rIndex == 0, isTrue);
      expect(rBuf.wIndex == bytes0.length, isTrue);
    });

    test('ReadBuffer', () {
      final vList = rng.uint8List(1, 10);
      final bytes = Bytes.typedDataView(vList);
      final rBuf0 = ReadBuffer(bytes);

      expect(rBuf0.rIndex == bytes.offset, isTrue);
      expect(rBuf0.wIndex == bytes.length, isTrue);
      expect(rBuf0.bytes.buf.buffer.asUint8List().elementAt(0) == vList[0],
          isTrue);
      expect(rBuf0.offset == bytes.offset, isTrue);
      expect(rBuf0.bytes == bytes, isTrue);

      final rBuf1 = ReadBuffer.fromList(vList);
      expect(rBuf1.rIndex == bytes.offset, isTrue);
      expect(rBuf1.wIndex == bytes.length, isTrue);
      expect(rBuf1.bytes.buf.buffer.asUint8List().elementAt(0) == vList[0],
          isTrue);
      expect(rBuf1.offset == bytes.offset, isTrue);
      expect(rBuf1.bytes == bytes, isTrue);
    });

    test('ReadBuffer.from', () {
      final vList = rng.uint8List(1, 10);
      final bytes = Bytes.fromList(vList);
      final rb = ReadBuffer(bytes);
      expect(rb.rIndex == bytes.offset, isTrue);
      expect(rb.wIndex == bytes.length, isTrue);
      expect(
          rb.bytes.buf.buffer.asUint8List().elementAt(0) == vList[0], isTrue);
      expect(rb.offset == bytes.offset, isTrue);
      expect(rb.bytes == bytes, isTrue);

      final from0 = ReadBuffer.from(rb);
      expect(from0.rIndex == bytes.offset, isTrue);
      expect(from0.wIndex == bytes.length, isTrue);
      expect(from0.bytes.buf.buffer.asUint8List().elementAt(0) == vList[0],
          isTrue);
      expect(from0.offset == bytes.offset, isTrue);
      expect(from0.bytes == bytes, isTrue);
    });

    test('ReadBuffer ASCII s.codeUnits', () {
      for (var i = 1; i < 10; i++) {
        final s = rng.asciiString(i);
        final bytes = Bytes.fromList(s.codeUnits);
        final rb = ReadBuffer(bytes);
        final s0 = rb.readString(s.length);
        final s1 = cvt.ascii.decode(bytes.buf, allowInvalid: false);
        expect(s == s0, isTrue);
        expect(s0 == s1, isTrue);
      }
    });

    test('ReadBuffer UTF8 fromString', () {
      for (var i = 1; i < 10; i++) {
        final s = rng.asciiString(i);
        final bytes = Bytes.fromString(s);
        final rb = ReadBuffer(bytes);
        final s0 = rb.readString(s.length);
        final s1 = cvt.utf8.decode(bytes.buf, allowMalformed: false);
        expect(s == s0, isTrue);
        expect(s0 == s1, isTrue);
      }
    });

    test('ReadBuffer readUint8List', () {
      for (var i = 1; i < 10; i++) {
        final vList = rng.uint8List(1, i);
        final bytes = Bytes.fromList(vList);
        final rb = ReadBuffer(bytes);
        final v = rb.readUint8List(vList.length);
        expect(v, equals(vList));
      }
    });

    test('ReadBuffer readUint16List', () {
      for (var i = 1; i < 10; i++) {
        final vList = rng.uint16List(1, i);
        final bytes = Bytes.typedDataView(vList);
        final rb = ReadBuffer(bytes);
        final v = rb.readUint16List(vList.length);
        expect(v, equals(vList));
      }
    });

    test('ReadBuffer readUint32List', () {
      for (var i = 1; i < 10; i++) {
        final vList = rng.uint32List(1, i);
        final bytes = Bytes.typedDataView(vList);
        final rb = ReadBuffer(bytes);
        final v = rb.readUint32List(vList.length);
        expect(v, equals(vList));
      }
    });
  });
}
