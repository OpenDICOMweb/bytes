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

void main() {
  final rng = RNG();
  group('Bytes Float64 Tests', () {
    test('Basic Float64 tests', () {
      final vList0 = rng.float64List(5, 10);
      final bytes0 = Bytes.typedDataView(vList0);
//      printIt(0, vList0.length * 8, bytes0.bd);
      final vList1 = bytes0.asFloat64List();
      // log.debug('vList1: $vList1');
      expect(vList1, equals(vList0));
//      printIt(0, vList0.length * 8, bytes0.bd);
      final vList2 = bytes0.getFloat64List();
      // log.debug('vList2: $vList2');
      expect(vList2, equals(vList1));
      final vList3 = bytes0.asFloat64List();
      // log.debug('vList3: $vList3');
      expect(vList3, equals(vList2));

      final bytes4 =Bytes.empty(bytes0.length)..setFloat64List(0, vList0);
      final vList4 = bytes4.asFloat64List();
      expect(vList4, equals(vList3));
    });

    //TODO: finish tests
    test('Test Float64List', () {
      const length = 10;
      const loopCount = 100;
      const vInitial = 1.234;
      final box = ByteData(kFloat64Size);

      for (var i = 0; i < loopCount; i++) {
        final a =Bytes.empty(length * kFloat64Size);
        // log.debug('a: $a');
        assert(a.length == length * kFloat64Size, true);

        var v0 = vInitial;
        for (var i = 0, j = 0; i < length; i++, j += kFloat64Size) {
          // Write to box to lose precision
          box.setFloat64(0, v0);
          final v1 = box.getFloat64(0);
          a.setFloat64(i * kFloat64Size, v1);
          // log.debug('i: $i, j: $j v: $v1, a[$i]: ${a.getFloat64(i)}');
          expect(a.getFloat64(i * kFloat64Size) == v1, true);
          v0 += .1;
        }
      }
    });
  });
}
