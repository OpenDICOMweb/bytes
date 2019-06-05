//  Copyright (c) 208, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'package:bytes/bytes.dart';
import 'package:bytes/bytes_buffer.dart';
import 'package:rng/rng.dart';
import 'package:test/test.dart';

void main() {
  final rng = RNG();
  group('Bytes Int8 Tests', () {
    test('ReadBuffer', () {
      for (var i = 1; i < 10; i++) {
        final vList = rng.int8List(1, i);
        final bytes = Bytes.fromList(vList);
        final buf = ReadBuffer(bytes);

        expect(buf.bytes.buf.buffer == bytes.buf.buffer, isTrue);
        expect(buf.bytes == bytes, isTrue);
        expect(buf.length == bytes.length, isTrue);
        expect(buf.getInt8() == bytes.getInt8(0), isTrue);

        expect(buf.rIndex == 0, isTrue);
        expect(buf.wIndex == bytes.length, isTrue);
      }
    });

    test('Int8 Buffer Growing Test', () {
      const startSize = 1;
      const iterations = 1024 * 1;
      final wb = WriteBuffer.empty(startSize);
      expect(wb.rIndex == 0, isTrue);
      expect(wb.wIndex == 0, isTrue);
      expect(wb.length == startSize, isTrue);
      for (var i = 0; i <= iterations - 1; i++) {
        final v = i % 127;
        wb.writeInt8(v);
        final x = wb.bytes.getInt8(i);
        expect(v == x, isTrue);
      }
      expect(wb.wIndex == iterations, isTrue);
    });
  });
}
