//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
import 'package:bytes/bytes_buffer.dart';
import 'package:test/test.dart';

void main() {
  group('ByteDataBuffer', () {
    test('Buffer Growing Test', () {
      const startSize = 1;
      const iterations = 1024 * 1;
      final wb = WriteBuffer.empty(startSize);
      expect(wb.rIndex == 0, isTrue);
      expect(wb.wIndex == 0, isTrue);
      expect(wb.length == startSize, isTrue);
      for (var i = 0; i <= iterations - 1; i++) {
        final v = i % 127;
        wb.writeInt8(v);
      }
      expect(wb.wIndex == iterations, isTrue);
    });
  });
}
