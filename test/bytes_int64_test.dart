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
import 'package:rng/rng.dart';
import 'package:test/test.dart';

void main() {
  final rng = RNG();
  group('Bytes Float Tests', () {
    test('Basic Int64 tests', () {
      final vList0 = rng.int64List(5, 10);
      // log.debug('vList0: $vList0');
      final bytes0 = Bytes.typedDataView(vList0);
      final vList1 = bytes0.asInt64List();
      expect(vList1, equals(vList0));
      // log.debug('vList1: $vList1');
      final vList2 = bytes0.getInt64List();
      // log.debug('vList2: $vList2');
      expect(vList2, equals(vList1));
      final vList3 = bytes0.asInt64List();
      // log.debug('vList3: $vList3');
      expect(vList3, equals(vList0));
      expect(vList3, equals(vList2));
      final bytes4 = Bytes(bytes0.length)..setInt64List(0, vList0);
      final vList4 = bytes4.asInt64List();
      expect(vList4, equals(vList3));
    });

    test('Int64 tests', () {
      final vList0 = rng.int64List(5, 10);
      // log.debug('vList0: $vList0');
      expect(vList0 is Int64List, true);

      final bytes0 = Bytes.typedDataView(vList0);
      // log.debug('bytes0: $bytes0');
      expect(bytes0.length, equals(vList0.length * vList0.elementSizeInBytes));

      final vList1 = bytes0.getInt64List();
      // log.debug('vList1: $vList1');
      expect(vList1, equals(vList0));

      final bytes1 = Bytes.typedDataView(vList1);
      expect(bytes1.length, equals(vList1.length * vList1.elementSizeInBytes));

      final vList2 = bytes1.asInt64List();
      // log.debug('vList2: $vList2');
      expect(vList2, equals(vList0));
      expect(vList2, equals(vList1));

      final bytes2 = Bytes.typedDataView(vList2);
      // log.debug('bytes2: $bytes2');
      expect(bytes2.length, equals(vList2.length * vList2.elementSizeInBytes));

      for (var i = 0; i < vList0.length; i++) {
        expect(vList2[i], equals(vList0[i]));
        expect(vList2[i], equals(vList1[i]));
      }

      for (var i = 0; i < vList0.length; i++) {
        expect(bytes2[i], equals(bytes0[i]));
        expect(bytes2[i], equals(bytes1[i]));
      }

      final bytes3 = bytes2.sublist(0);
      // log.debug('bytes3: $bytes3');
      final bytes4 = bytes2.asBytes();
      // log.debug('bytes4: $bytes4');

      expect(bytes1 == bytes0, true);
      expect(bytes2 == bytes1, true);
      expect(bytes3 == bytes2, true);
      expect(bytes4 == bytes3, true);
    });

    test('Int64 asInt64List tests', () {
      const count = 10;
      for (var k = 0; k < count; k++) {
        final vList0 = rng.int64List(k, count);
        // log.debug('$k: vList0:(${vList0.length}) $vList0');
        expect(vList0 is Int64List, true);

        final bytes0 = Bytes.typedDataView(vList0);
        // log.debug('$k: bytes0: $bytes0');
        expect(bytes0.buffer == vList0.buffer, true);
        expect(
            bytes0.length, equals(vList0.length * vList0.elementSizeInBytes));

        for (var i = 0; i < vList0.length + 1; i++) {
          // log.debug('i: $i length ${vList0.length - i}');
          final vList1 = vList0.sublist(i, vList0.length);
          expect(vList1.buffer != vList0.buffer, true);
          // log.debug('vList1: $vList1');
          final vList2 = vList0.sublist(0, vList0.length - i);
          expect(vList2.buffer != vList0.buffer, true);
          // log.debug('vList2: $vList2');

          final j = i * 8;

          final vList3 = bytes0.asInt64List(j, vList0.length - i);
          // log.debug('vList3: $vList3');
          expect(vList3, equals(vList1));
          expect(vList3.buffer == vList0.buffer, true);
          expect(vList3.buffer == bytes0.buffer, true);

          final vList4 = bytes0.asInt64List(0, vList0.length - i);
          // log.debug('vList4: $vList4');
          expect(vList4, equals(vList2));
          expect(vList3.buffer == vList0.buffer, true);
          expect(vList4.buffer == bytes0.buffer, true);
        }
      }
    });

    test('Int64 sublist tests', () {
      const count = 10;
      for (var k = 0; k < count; k++) {
        final vList0 = rng.int64List(k, count);
        // log.debug('$k: vList0:(${vList0.length}) $vList0');
        expect(vList0 is Int64List, true);

        final bytes0 = Bytes.typedDataView(vList0);
        // log.debug('$k: bytes0: $bytes0');
        expect(bytes0.buffer == vList0.buffer, true);
        expect(
            bytes0.length, equals(vList0.length * vList0.elementSizeInBytes));

        for (var i = 0; i < vList0.length + 1; i++) {
          // log.debug('i: $i length ${vList0.length - i}');
          final vList1 = vList0.sublist(i, vList0.length);
          expect(vList1.buffer != vList0.buffer, true);
          // log.debug('vList1: $vList1');
          final vList2 = vList0.sublist(0, vList0.length - i);
          expect(vList2.buffer != vList0.buffer, true);
          // log.debug('vList2: $vList2');

          final j = i * 8;
          final bytes1 = bytes0.sublist(j, bytes0.length);
          expect(bytes1.buffer != vList0.buffer, true);

          // log.debug('bytes1: $bytes1');
          final bytes2 = bytes0.sublist(0, bytes0.length - j);
          // log.debug('bytes2: $bytes2');
          expect(bytes2.buffer != vList0.buffer, true);

          final vList3 = bytes1.asInt64List();
          // log.debug('vList3: $vList3');
          expect(vList3, equals(vList1));
          expect(vList3.buffer == bytes1.buffer, true);

          final vList4 = bytes2.asInt64List();
          // log.debug('vList4: $vList4');
          expect(vList4, equals(vList2));
          expect(vList4.buffer == bytes2.buffer, true);

          final bytes3 = bytes0.sublist(j, bytes0.length);
          // log.debug('bytes3: $bytes3');
          expect(bytes3, equals(bytes1));
          expect(bytes3.buffer != bytes0.buffer, true);

          final bytes4 = bytes0.sublist(0, bytes0.length - j);
          // log.debug('bytes4: $bytes4');
          expect(bytes4, equals(bytes4));
          expect(bytes4.buffer != bytes0.buffer, true);
        }
      }
    });

    test('Int64 view tests', () {
      const count = 10;
      for (var k = 0; k < count; k++) {
        final vList0 = rng.int64List(k, count);
        // log.debug('$k: vList0:(${vList0.length}) $vList0');
        expect(vList0 is Int64List, true);

        final bytes0 = Bytes.typedDataView(vList0);
        // log.debug('bytes0: $bytes0');
        expect(bytes0.buffer == vList0.buffer, true);
        expect(
            bytes0.length, equals(vList0.length * vList0.elementSizeInBytes));

        for (var i = 0; i < vList0.length + 1; i++) {
          final j = i * 8;
          // log.debug('i: $i offset $j length ${vList0.length - i}');
          final vList1 = Int64List.view(vList0.buffer, j, vList0.length - i);
          // log.debug('vList1: $vList1');
          expect(vList1.buffer == vList0.buffer, true);

          final vList2 = Int64List.view(vList0.buffer, 0, vList0.length - i);
          // log.debug('vList2: $vList2');
          expect(vList2.buffer == vList0.buffer, true);

          final bytes1 = bytes0.asBytes(j, bytes0.length - j);
          // log.debug('bytes1: $bytes1');
          expect(bytes1.buffer == vList0.buffer, true);
          expect(bytes1.buffer == bytes0.buffer, true);

          // log.debug('bytes1: $bytes1');
          final bytes2 = bytes0.asBytes(0, bytes0.length - j);
          // log.debug('bytes2: $bytes2');
          expect(bytes2.buffer == vList0.buffer, true);
          expect(bytes1.buffer == bytes0.buffer, true);

          final bytes3 = bytes0.asBytes(j, bytes0.length - j);
          // log.debug('bytes3: $bytes3 \n bytes1: $bytes1');
          expect(bytes3 == bytes1, true);
          expect(bytes3.buffer == vList0.buffer, true);
          expect(bytes1.buffer == bytes0.buffer, true);

          final bytes4 = bytes0.asBytes(0, bytes0.length - j);
          // log.debug('bytes4: $bytes4');
          expect(bytes4, equals(bytes2));
          expect(bytes4.buffer == vList0.buffer, true);
          expect(bytes1.buffer == bytes0.buffer, true);
        }
      }
    });
  });
}
