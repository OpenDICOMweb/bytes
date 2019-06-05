//  Copyright (c) 2016, 2017, 2018,
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
  group('Bytes Float Tests', () {
    test('ReadBuffer', () {
      for (var i = 1; i < 10; i++) {
        final vList1 = rng.int64List(1, i);
        final bytes1 = Bytes.fromList(vList1);
        final rbuf = ReadBuffer(bytes1);

        expect(rbuf.bytes.buf.buffer == bytes1.buffer, isTrue);
        expect(rbuf.bytes == bytes1, isTrue);
        expect(rbuf.length == bytes1.length, isTrue);
        expect(
            rbuf.bytes.buf.buffer.lengthInBytes == bytes1.buffer.lengthInBytes,
            true);
        expect(rbuf.rIndex == 0, isTrue);
        expect(rbuf.wIndex == bytes1.length, isTrue);
      }
    });
  });
}
