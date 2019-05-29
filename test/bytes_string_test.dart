//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:convert' as cvt;
import 'dart:math';
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

  group('Bytes.fromAscii Utf8', () {
    test('ASCII String tests', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.asciiList();
        print('vList0 $vList0');
        final s0 = vList0.join('\\');

        final bytes0 = Bytes.fromString(s0);
        final buf0 = bytes0.buf;
        expect(s0.length == bytes0.length, true);
        expect(bytes0.endian == Endian.little, true);

        final s1 = bytes0.getUtf8();
        expect(s0 == s1, true);
        final vList1 = s1.split('\\');
        expect(vList1, equals(vList0));

        final bytes1 = BytesLittleEndian.typedDataView(bytes0.buf);
        expect(bytes1.buffer == bytes0.buffer, true);

        final s3 = bytes1.getString();
        final vList2 = s3.split('\\');
        expect(vList2, equals(vList1));

        final bytes2 = Bytes.empty(bytes0.length, Endian.little)
          ..setString(0, s0);
        expect(bytes2 == bytes1, true);
        final s4 = bytes2.getUtf8();
        final vList3 = s4.split('\\');
        expect(vList3, equals(vList2));
      }
    });

    test('Latin String tests', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.latinList();
        print('vList0 $vList0');
        final s0 = vList0.join('\\');
        print('s0.length ${s0.length}');

        final bytes0 = Bytes.fromString(s0);
        print('bytes0.length ${bytes0.length}');
        final buf0 = bytes0.buf;
        expect(s0.length <= bytes0.length, true);
        expect(bytes0.endian == Endian.little, true);

        final s1 = bytes0.getUtf8();
        expect(s0 == s1, true);
        final vList1 = s1.split('\\');
        expect(vList1, equals(vList0));

        final bytes1 = BytesLittleEndian.typedDataView(bytes0.buf);
        expect(bytes1.length == bytes0.length, true);
        expect(bytes1.buffer == bytes0.buffer, true);

        final s3 = bytes1.getString();
        final vList2 = s3.split('\\');
        expect(vList2, equals(vList1));

        final bytes2 = Bytes.empty(bytes0.length, Endian.little)
          ..setString(0, s0);
        expect(bytes2 == bytes1, true);
        final s4 = bytes2.getUtf8();
        final vList3 = s4.split('\\');
        expect(vList3, equals(vList2));
      }
    });

    /// DICOM UTF-8 Strings
    test('UTF8 String tests', () {
      for (var i = 0; i < repetitions; i++) {
        final u8List = rng.utf8Bytes();
        print('u8List.length ${u8List.length}');
        final s0 = cvt.utf8.decode(u8List, allowMalformed: true);
        print('s0.length ${s0.length}');
        final bytes0 = Bytes.typedDataView(u8List);
        print('bytes0.length ${bytes0.length}');
        expect(u8List.length == bytes0.length, true);
        expect(u8List.buffer == bytes0.buffer, true);
        expect(bytes0.endian == Endian.little, true);

        final s1 = bytes0.getUtf8();
        print('s1.length ${s1.length}');
        expect(s1 == s0, true);

        final bytes1 = BytesLittleEndian.from(bytes0);
        expect(bytes1.length == bytes0.length, true);
        expect(bytes1.buffer == bytes0.buffer, false);
        expect(bytes1.endian == Endian.little, true);

//        TODO: make this work
/*
        final bytes2 = Bytes.empty(bytes0.length);
        print('bytes2.length ${bytes1.length}');
        bytes2.setUtf8(0, s0);
        expect(bytes2 == bytes1, true);
        final s2 = bytes2.getUtf8();
        expect(s2, equals(s1));
*/

      }
    });
  });
}
