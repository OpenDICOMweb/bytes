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

  group('ReadBuffer Float32 Tests', () {
    test('ReadBuffer LE Simple Float32 test', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.float32List(min, max);
        expect(vList0 is Float32List, isTrue);
        final rBuf0 = getReadBufferLE(getFloat32LE(vList0));
        final out = Float32List(vList0.length);

        for (var j = 0; j < vList0.length; j++) {
          final v = rBuf0.readFloat32();
          expect(v, equals(vList0[j]));
          out[j] = v;
        }
        expect(out, equals(vList0));
      }
    });

    test('ReadBuffer LE Float32List test', () {
      final vList = rng.float32List(min, max);
      for (var i = 0; i < repetitions; i++) {
        final rBuf1 = getReadBufferLE(getFloat32LE(vList));
        final vList1 = rBuf1.readFloat32List(vList.length);
        expect(vList1, equals(vList));
      }
    });

    test('ReadBuffer BE Simple Float32 tests', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.float32List(min, max);
        expect(vList0 is Float32List, isTrue);
        final rBuf0 = getReadBufferBE(getFloat32BE(vList0));
        expect(rBuf0.endian == Endian.big, isTrue);
        final out = Float32List(vList0.length);

        for (var j = 0; j < vList0.length; j++) {
          final v = rBuf0.readFloat32();
      //    expect(v, equals(vList0[j]));
          out[j] = v;
        }
        expect(out, equals(vList0));
      }
    });

    test('ReadBuffer BE Float32List test', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.float32List(min, max);
        final rBuf1 = getReadBufferBE(getFloat32BE(vList0));
        final vList1 = rBuf1.readFloat32List(vList0.length);
        expect(vList1, equals(vList0));
      }
    });
  });

  group('WriteBuffer Float32 Tests', () {
    test('WriteBuffer Float32 LE tests', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.float32List(min, max);
        var size = vList0.lengthInBytes;
        size = size == 0 ? 1 : size;
        final rBuf0 = getWriteBuffer(vList0.length * 4, 'LE');
        final out = Float32List(vList0.length);

        final bytes = rBuf0.bytes;
        var offset = 0;
        for (var j = 0; j < vList0.length; j++) {
          final x = vList0[j];
          rBuf0.writeFloat32(x);
          out[j] = x;
          expect(bytes.getFloat32(j * 4) == x, isTrue);
          offset += 4;
          expect(rBuf0.wIndex == offset, isTrue);
        }
        expect(out, equals(vList0));

        final rBuf1 = getWriteBuffer(size, 'LE')..writeFloat32List(vList0);
        final vList1 = rBuf1.bytes.getFloat32List(0, vList0.length);
        expect(vList1, equals(vList0));
      }
    });

    test('WriteBuffer Float32 BE  tests', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.float32List(min, max);
        var size = vList0.lengthInBytes;
        size = size == 0 ? 1 : size;
        final rBuf0 = getWriteBuffer(size, 'BE');
        final out = Float32List(vList0.length);

        final bytes = rBuf0.bytes;
        var offset = 0;
        for (var j = 0; j < vList0.length; j++) {
          final x = vList0[j];
          rBuf0.writeFloat32(x);
          out[j] = x;
          expect(bytes.getFloat32(j * 4) == x, isTrue);
          offset += 4;
          expect(rBuf0.wIndex == offset, isTrue);
        }
        expect(out, equals(vList0));

        final rBuf1 = getWriteBuffer(size, 'BE')..writeFloat32List(vList0);
        final vList1 = rBuf1.bytes.getFloat32List(0, vList0.length);
        expect(vList1, equals(vList0));
      }
    });
  });
}
