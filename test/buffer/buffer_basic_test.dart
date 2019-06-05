//  Copyright (c) 208, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'package:bytes/debug/test_utils.dart';
import 'package:rng/rng.dart';
import 'package:test/test.dart';

void main() {
  final rng = RNG();

  group('ReadBuffer Basic Tests', () {
    test('ReadBuffer LE', () {
      final vList0 = rng.int8List();
      final rBuf = getReadBufferLE(vList0);
      final bytes = rBuf.bytes;
      expect(rBuf.bytes == bytes, isTrue);
      expect(rBuf.buffer == bytes.buffer, isTrue);
      expect(rBuf.length == bytes.length, isTrue);
      expect(rBuf.rIndex == 0, isTrue);
      expect(rBuf.wIndex == bytes.length, isTrue);
    });

    test('ReadBuffer BE', () {
      final vList0 = rng.int8List();
      final rBuf = getReadBufferBE(vList0);
      final bytes = rBuf.bytes;
      expect(rBuf.bytes == bytes, isTrue);
      expect(rBuf.buffer == bytes.buffer, isTrue);
      expect(rBuf.length == bytes.length, isTrue);
      expect(rBuf.rIndex == 0, isTrue);
      expect(rBuf.wIndex == bytes.length, isTrue);
    });
  });

  group('WriteBuffer Basic Tests', () {
    test('WriteBuffer LE', () {
      final vList0 = rng.int8List();
      final wBuf = getWriteBufferLE(vList0.length);
      final bytes = wBuf.bytes;
      expect(wBuf.bytes == bytes, isTrue);
      expect(wBuf.buffer == bytes.buffer, isTrue);
      expect(wBuf.length == bytes.length, isTrue);
      expect(wBuf.rIndex == 0, isTrue);
      expect(wBuf.wIndex == 0, isTrue);
    });

    test('WriteBuffer BE', () {
      final vList0 = rng.int8List();
      final wBuf = getWriteBufferBE(vList0.length);
      final bytes = wBuf.bytes;
      expect(wBuf.bytes == bytes, isTrue);
      expect(wBuf.buffer == bytes.buffer, isTrue);
      expect(wBuf.length == bytes.length, isTrue);
      expect(wBuf.rIndex == 0, isTrue);
      expect(wBuf.wIndex == 0, isTrue);
    });

    test('WriteBuffer LE Buffer Growing Test', () {
      const startSize = 1;
      const iterations = 1024 * 1;
      final wb0 = getWriteBuffer(startSize, 'LE');
      expect(wb0.rIndex == 0, isTrue);
      expect(wb0.wIndex == 0, isTrue);
      expect(wb0.length == startSize, isTrue);

      var offset = 0;
      for (var i = 0; i <= iterations - 1; i++) {
        final v = rng.nextFloat32;
        wb0.writeFloat32(v);
        offset += 4;
        expect(wb0.wIndex == offset, isTrue);
      }
      expect(wb0.wIndex == iterations * 4, isTrue);
    });

    test('WriteBuffer BE Buffer Growing Test', () {
      const startSize = 1;
      const endSize = 1024 * 1024;
      final wb0 = getWriteBuffer(startSize, 'BE');
      expect(wb0.rIndex == 0, isTrue);
      expect(wb0.wIndex == 0, isTrue);
      expect(wb0.length == startSize, isTrue);

      var offset = 0;
      for (var i = 0; i <= endSize - 1; i++) {
       // final v = rng.nextFloat32;
        const v = 255;
        wb0.writeUint8(v);
        offset++;
        expect(wb0.wIndex == offset, isTrue);
      }
      expect(wb0.wIndex == endSize, isTrue);
    });
  });
}
