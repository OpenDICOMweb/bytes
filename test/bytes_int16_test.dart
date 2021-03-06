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

  group('Bytes Float Tests', () {
    final intList = [kInt16MinValue, kInt16MaxValue];

    test('Basic Int16 tests', () {
      final vList0 = Int16List.fromList(intList);
      // log.debug('vList0: $vList0');

      // Typed Data View
      final bytes0 = Bytes.typedDataView(vList0);
      // log.debug('bytes0: $bytes0');
      final vList1 = bytes0.asInt16List();
      // log.debug('vList1: $vList1');
      expect(vList1, equals(vList0));
      expect(vList1[0], equals(vList0[0]));
      expect(vList1[1], equals(vList0[1]));

      // Copy
      final vList2 = bytes0.getInt16List();
      // log.debug('vList2: $vList2');
      expect(vList2, equals(vList1));
      expect(vList2[0], equals(vList0[0]));
      expect(vList2[1], equals(vList0[1]));

      // View
      final vList3 = bytes0.asInt16List();
      // log.debug('vList3: $vList3');
      expect(vList3, equals(vList0));
      expect(vList3, equals(vList2));
      expect(vList3[0], equals(vList0[0]));
      expect(vList3[1], equals(vList0[1]));

      final bytes4 = Bytes(bytes0.length)..setInt16List(0, vList0);
      final vList4 = bytes4.asInt16List();
      expect(vList4, equals(vList3));
      expect(vList4[0], equals(vList0[0]));
      expect(vList4[1], equals(vList0[1]));
    });

    test('Basic Int16 offset tests', () {
      final vList0 = Int16List.fromList(intList);
      // log.debug('vList0: $vList0');
      final bytes0 = Bytes.typedDataView(vList0);
      // log.debug('bytes0: $bytes0');

      // Test offset
      final vList1 = vList0.sublist(1);
      // log.debug('vList1: $vList1');
      final bList1 = bytes0.asInt16List(2);
      // log.debug('bList1: $bList1');
      expect(bList1, equals(vList1));
      expect(vList1[0], equals(vList0[1]));

      // Test length
      final vList2 = vList0.sublist(0, 1);
      // log.debug('vList1: $vList1');
      final bList2 = bytes0.asInt16List(0, 1);
      // log.debug('bList1: $bList1');
      expect(bList2, equals(vList2));
      expect(vList2[0], equals(vList0[0]));

      final vList3 = vList0.sublist(0, 2);
      // log.debug('vList1: $vList1');
      final bList3 = bytes0.asInt16List(0, 2);
      // log.debug('bList1: $bList1');
      expect(bList3, equals(vList3));
      expect(vList3[0], equals(vList0[0]));
      expect(vList3[1], equals(vList0[1]));
    });

    test('Int16 tests', () {
      final vList0 = rng.int16List(5, 10);
      // log.debug('vList0: $vList0');
      expect(vList0 is Int16List, true);

      final bytes0 = Bytes.typedDataView(vList0);
      // log.debug('bytes0: $bytes0');
      expect(bytes0.length, equals(vList0.length * vList0.elementSizeInBytes));

      final vList1 = bytes0.getInt16List();
      // log.debug('vList1: $vList1');
      expect(vList1, equals(vList0));

      final bytes1 = Bytes.typedDataView(vList1);
      expect(bytes1.length, equals(vList1.length * vList1.elementSizeInBytes));

      final vList2 = bytes1.asInt16List();
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

    test('Int16 asInt16List tests', () {
      const count = 10;
      for (var k = 0; k < count; k++) {
        final vList0 = rng.int16List(k, count);
        // log.debug('$k: vList0:(${vList0.length}) $vList0');
        expect(vList0 is Int16List, true);

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

          final j = i * 2;
          final vList3 = bytes0.asInt16List(j, vList0.length - i);
          // log.debug('vList3: $vList3');
          expect(vList3, equals(vList1));
          expect(vList3.buffer == vList0.buffer, true);
          expect(vList3.buffer == bytes0.buffer, true);

          final vList4 = bytes0.asInt16List(0, vList0.length - i);
          // log.debug('vList4: $vList4');
          expect(vList4, equals(vList2));
          expect(vList3.buffer == vList0.buffer, true);
          expect(vList4.buffer == bytes0.buffer, true);
        }
      }
    });

    test('Int16 sublist tests', () {
      const count = 10;
      for (var k = 0; k < count; k++) {
        final vList0 = rng.int16List(k, count);
        // log.debug('$k: vList0:(${vList0.length}) $vList0');
        expect(vList0 is Int16List, true);

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

          final j = i * 2;
          final bytes1 = bytes0.sublist(j, bytes0.length);
          expect(bytes1.buffer != vList0.buffer, true);

          // log.debug('bytes1: $bytes1');
          final bytes2 = bytes0.sublist(0, bytes0.length - j);
          // log.debug('bytes2: $bytes2');
          expect(bytes2.buffer != vList0.buffer, true);

          final vList3 = bytes1.asInt16List();
          // log.debug('vList3: $vList3');
          expect(vList3, equals(vList1));
          expect(vList3.buffer == bytes1.buffer, true);

          final vList4 = bytes2.asInt16List();
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

    test('Int16 view tests', () {
      const count = 10;
      for (var k = 0; k < count; k++) {
        final vList0 = rng.int16List(k, count);
        // log.debug('$k: vList0:(${vList0.length}) $vList0');
        expect(vList0 is Int16List, true);

        final bytes0 = Bytes.typedDataView(vList0);
        // log.debug('bytes0: $bytes0');
        expect(bytes0.buffer == vList0.buffer, true);
        expect(
            bytes0.length, equals(vList0.length * vList0.elementSizeInBytes));

        for (var i = 0; i < vList0.length + 1; i++) {
          final j = i * 2;
          // log.debug('i: $i offset $j length ${vList0.length - i}');
          final vList1 = Int16List.view(vList0.buffer, j, vList0.length - i);
          expect(vList1.buffer == vList0.buffer, true);
          // log.debug('vList1: $vList1');
          final vList2 = Int16List.view(vList0.buffer, 0, vList0.length - i);
          // log.debug('vList2: $vList2');
          expect(vList2.buffer == vList0.buffer, true);

          final bytes1 = bytes0.asBytes(j, bytes0.length - j);
          expect(bytes1.buffer == vList0.buffer, true);
          expect(bytes1.buffer == bytes0.buffer, true);

          // log.debug('bytes1: $bytes1');
          final bytes2 = bytes0.asBytes(0, bytes0.length - j);
          // log.debug('bytes2: $bytes2');
          expect(bytes2.buffer == vList0.buffer, true);
          expect(bytes1.buffer == bytes0.buffer, true);

          final bytes3 = bytes0.asBytes(j, bytes0.length - j);
          // log.debug('bytes3: $bytes3');
          expect(bytes3, equals(bytes1));
          expect(bytes3.buffer == vList0.buffer, true);
          expect(bytes1.buffer == bytes0.buffer, true);

          final bytes4 = bytes0.asBytes(0, bytes0.length - j);
          // log.debug('bytes4: $bytes4');
          expect(bytes4, equals(bytes4));
          expect(bytes4.buffer == vList0.buffer, true);
          expect(bytes1.buffer == bytes0.buffer, true);
        }
      }
    });
  });
}
