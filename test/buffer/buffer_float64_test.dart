//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

import 'package:bytes/debug/test_utils.dart';
import 'package:rng/rng.dart';
import 'package:test/test.dart';
import 'package:test_tools/tools.dart';

void main() {
  final rng = RNG();
  const repetitions = 100;
  const min = 0;
  const max = 100;

  group('ReadBuffer Float64 Tests', () {
    test('ReadBuffer LE Float64 test', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.float64List(min, max);
        expect(vList0 is Float64List, isTrue);
        final rBuf = getReadBufferLE(getFloat64LE(vList0));
        final out = Float64List(vList0.length);

        for (var j = 0; j < vList0.length; j++) {
          final v = rBuf.readFloat64();
          expect(v, equals(vList0[j]));
          out[j] = v;
        }
        expect(out, equals(vList0));
        expect(rBuf.buffer == out.buffer, false);
      }
    });

    test('ReadBuffer LE Float64List test', () {
      final vList0 = rng.float64List(min, max);
      for (var i = 0; i < repetitions; i++) {
        final rBuf = getReadBufferLE(getFloat64LE(vList0));
        final vList1 = rBuf.readFloat64List(vList0.length);
        expect(vList1, equals(vList0));
      }
    });

    test('ReadBuffer BE Float64 tests', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.float64List(min, max);
        expect(vList0 is Float64List, isTrue);
        final rBuf = getReadBufferBE(getFloat64BE(vList0));
        expect(rBuf.endian == Endian.big, isTrue);
        final out = Float64List(vList0.length);

        for (var j = 0; j < vList0.length; j++) {
          final v = rBuf.readFloat64();
          expect(v, equals(vList0[j]));
          out[j] = v;
        }
        expect(out, equals(vList0));
        expect(rBuf.buffer == out.buffer, false);
      }
    });

    test('ReadBuffer BE Float64List test', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.float64List(min, max);
        final rBuf = getReadBufferBE(getFloat64BE(vList0));
        final vList1 = rBuf.readFloat64List(vList0.length);
        expect(vList1, equals(vList0));
      }
    });
  });

  group('WriteBuffer Float64 Tests', () {
    test('WriteBuffer Float64 LE tests', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.float64List(min, max);
        var size = vList0.lengthInBytes;
        size = size == 0 ? 1 : size;
        final rBuf0 = getWriteBuffer(vList0.length * 8, 'LE');
        final out = Float64List(vList0.length);

        final bytes = rBuf0.bytes;
        var offset = 0;
        for (var j = 0; j < vList0.length; j++) {
          final x = vList0[j];
          rBuf0.writeFloat64(x);
          out[j] = x;
          expect(bytes.getFloat64(j * 8) == x, isTrue);
          offset += 8;
          expect(rBuf0.wIndex == offset, isTrue);
        }
        expect(out, equals(vList0));

        final rBuf1 = getWriteBuffer(size, 'LE')..writeFloat64List(vList0);
        final vList1 = rBuf1.bytes.getFloat64List(0, vList0.length);
        expect(vList1, equals(vList0));
      }
    });

    test('WriteBuffer Float64 BE  tests', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.float64List(min, max);
        var size = vList0.lengthInBytes;
        size = size == 0 ? 1 : size;
        final rBuf0 = getWriteBuffer(size, 'BE');
        final out = Float64List(vList0.length);

        final bytes = rBuf0.bytes;
        var offset = 0;
        for (var j = 0; j < vList0.length; j++) {
          final x = vList0[j];
          rBuf0.writeFloat64(x);
          out[j] = x;
          expect(bytes.getFloat64(j * 8) == x, isTrue);
          offset += 8;
          expect(rBuf0.wIndex == offset, isTrue);
        }
        expect(out, equals(vList0));

        final rBuf1 = getWriteBuffer(size, 'BE')..writeFloat64List(vList0);
        final vList1 = rBuf1.bytes.getFloat64List(0, vList0.length);
        expect(vList1, equals(vList0));
      }
    });
  });
}
