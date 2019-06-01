//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

import 'package:bytes/bytes.dart';
import 'package:bytes/src/constants.dart';
import 'package:rng/rng.dart';
import 'package:test/test.dart';
import 'package:test_tools/tools.dart';

void main() {
  final rng = RNG();
  const repetitions = 100;
  const min = 0;
  const max = 100;

  group('BytesLittleEndian Float32', () {
    test('LE Float32 tests', () {
      // vList0 is Endian.host
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.float32List(min, max);
        expect(vList0 is Float32List, isTrue);

        final u8LE = getFloat32LE(vList0);
        expect(vList0.buffer != u8LE.buffer, isTrue);
        expect(isAligned32(vList0.offsetInBytes), isTrue);

        final bytes0 = BytesLittleEndian.typedDataView(u8LE);
        expect(bytes0.endian == Endian.little, isTrue);
        expect(bytes0.length == u8LE.length, isTrue);
        expect(bytes0.buffer == u8LE.buffer, isTrue);
        expect(isAligned32(bytes0.buf.offsetInBytes), isTrue);

        final vList1 = u8LE.buffer.asFloat32List();
        final vList2 = bytes0.getFloat32List();
        expect(vList2, equals(vList1));
        expect(vList2.buffer != vList1.buffer, isTrue);

        final bytes1 = Bytes.empty(bytes0.length, Endian.little)
          ..setFloat32List(0, vList2);
        final vList3 = bytes1.asFloat32List();
        expect(vList3, equals(vList2));
      }
    });


    test('Bytes.empty LE Float32', () {
      const vInitial = 1.234;
      final box = ByteData(kFloat32Size);
      final length = rng.getLength(0, 100);

      for (var i = 0; i < repetitions; i++) {
        final bytes = Bytes.empty(length * kFloat32Size, Endian.little);
        assert(bytes.length == length * kFloat32Size, isTrue);

        var v0 = vInitial;
        for (var i = 0, j = 0; i < length; i++, j += kFloat32Size) {
          // Write to box to lose precision
          box.setFloat32(0, v0);
          final v1 = box.getFloat32(0);
          final offset = i * kFloat32Size;
          bytes.setFloat32(offset, v1);
          final v2 = bytes.getFloat32(offset);
          expect(v2 == v1, isTrue);
          v0 += .1;
        }
      }
    });

    test('Bytes LE Float32List test', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.float32List(min, max);
        final u8LE = getFloat32LE(vList0);
        final bytes = BytesLittleEndian(u8LE);
        final vList1 = bytes.asFloat32List();
        final vList2 = bytes.getFloat32List();
        expect(vList0, equals(vList1));
        expect(vList1, equals(vList2));
      }
    });
  });

  group('BytesBigEndian Float32', () {
    test('BE Float32 tests', () {
      for (var i = 0; i < repetitions; i++) {
        // vList0 is Endian.host
        final vList0 = rng.float32List(min, max);
        expect(vList0 is Float32List, isTrue);

        final u8BE = getFloat32BE(vList0);
        expect(vList0.buffer != u8BE.buffer, isTrue);
        expect(isAligned32(vList0.offsetInBytes), isTrue);

        final bytes0 = BytesBigEndian(u8BE);
        expect(bytes0.endian == Endian.big, isTrue);
        expect(bytes0.length == u8BE.length, isTrue);
        expect(bytes0.buffer == u8BE.buffer, isTrue);
        expect(isAligned32(bytes0.buf.offsetInBytes), isTrue);

        final vList1 = u8BE.buffer.asFloat32List();
        final vList2 = bytes0.getFloat32List();
        expect(vList2, equals(vList0));
        expect(vList2.buffer != vList1.buffer, isTrue);

        final bytes1 = Bytes.empty(bytes0.length, Endian.big)
          ..setFloat32List(0, vList0);
        final vList3 = bytes1.asFloat32List();
        expect(vList3, equals(vList2));
      }
    });


    test('Bytes.empty BE Float32', () {
      const vInitial = 1.234;
      final box = ByteData(kFloat32Size);
      final length = rng.getLength(0, 100);

      for (var i = 0; i < repetitions; i++) {
        final bytes = Bytes.empty(length * kFloat32Size, Endian.big);
        assert(bytes.length == length * kFloat32Size, isTrue);

        var v0 = vInitial;
        for (var i = 0, j = 0; i < length; i++, j += kFloat32Size) {
          // Write to box to lose precision
          box.setFloat32(0, v0);
          final v1 = box.getFloat32(0);
          final offset = i * kFloat32Size;
          bytes.setFloat32(offset, v1);
          final v2 = bytes.getFloat32(offset);
          expect(v2 == v1, isTrue);
          v0 += .1;
        }
      }
    });

    test('Bytes BE Float32List test', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.float32List(min, max);
        final u8BE = getFloat32BE(vList0);
        final bytes = BytesBigEndian(u8BE);
        final vList1 = bytes.asFloat32List();
        final vList2 = bytes.getFloat32List();
        expect(vList0, equals(vList1));
        expect(vList1, equals(vList2));
      }
    });
  });
}
