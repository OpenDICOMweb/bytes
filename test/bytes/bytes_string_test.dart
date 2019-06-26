//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:convert' as cvt;
import 'dart:typed_data';

import 'package:bytes/bytes.dart';
import 'package:rng/rng.dart';
import 'package:test/test.dart';

void main() {
  final rng = RNG();
  const repetitions = 100;
  const min = 0;
  const max = 256;

  bool isValidLatinList(List<String> list) {
    if (list.isEmpty) return true;
    for (var i = 0; i < list.length; i++) {
      final s = list[i];
      if (s.isEmpty) continue;
      for (var i = 0; i < s.length; i++) {
        final c = s.codeUnitAt(i);
        if (!rng.isLatinVChar(c)) {
          var msg = 'Bad Latin Char: $c ${c.toRadixString(16)} '
              '${String.fromCharCode(c)})';
          throw ArgumentError(msg);
        }
      }
    }
    return true;
  }

  // Urgent fix: only checks latin string
  bool isValidUtf8List(List<String> list) {
    if (list.isEmpty) return true;
    for (var i = 0; i < list.length; i++) {
      final s = list[i];
      if (s.isEmpty) continue;
      for (var i = 0; i < s.length; i++) {
        final c = s.codeUnitAt(i);
        if (!rng.isLatinVChar(c)) {
          var msg = 'Bad Latin Char: $c ${c.toRadixString(16)} '
              '${String.fromCharCode(c)})';
          throw ArgumentError(msg);
        }
      }
    }
    return true;
  }
  List<String> sSplit(String s) => s.isEmpty ? <String>[] : s.split('\\');

  group('BytesBuffer Strings', () {
    test('ASCII String tests', () {
      final vListA = rng.asciiList(0, 0);
      final s0 = vListA.join('\\');
      final u8List = cvt.ascii.encode(s0);
      final bytes0 = Bytes.typedDataView(u8List);
      expect(s0.length == bytes0.length, isTrue);
      expect(bytes0.endian == Endian.little, isTrue);
      expect(vListA, equals(<String>[]));

      final vListB = ''.split('\\');
      expect(vListB, equals(<String>['']));

      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.asciiList(min, max);
        final s0 = vList0.join('\\');
        final u8Ascii = cvt.ascii.encode(s0);
        final bytes0 = Bytes.typedDataView(u8Ascii);
        expect(s0.length == bytes0.length, isTrue);
        expect(bytes0.endian == Endian.little, isTrue);

        final s1 = bytes0.getAscii();
        expect(s0 == s1, isTrue);
        final vList1 = sSplit(s1);
        expect(vList1, equals(vList0));

        final bytes1 = BytesLittleEndian.typedDataView(bytes0.buf);
        expect(bytes1.length == bytes0.length, isTrue);
        expect(bytes1.buffer == bytes0.buffer, isTrue);
        expect(bytes1 == bytes0, isTrue);

        final s2 = bytes1.getAscii();
        final vList2 = sSplit(s2);
        expect(vList2, equals(vList1));

        final bytes2 = Bytes.empty(bytes0.length, Endian.little)
          ..setAscii(0, s0);
        expect(bytes2 == bytes1, isTrue);
        final s3 = bytes2.getAscii();
        final vList3 = sSplit(s3);
        expect(vList3, equals(vList2));

        //TODO add test with string at an offset
      }
    });

    test('Latin String tests', () {
      final vList = rng.latinList(0, 0);
      final s0 = vList.join('\\');
      final u8List = cvt.latin1.encode(s0);
      final bytes0 = Bytes.typedDataView(u8List);
      expect(s0.length == bytes0.length, isTrue);
      expect(bytes0.endian == Endian.little, isTrue);
      expect(vList, equals(<String>[]));

      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.latinList(min, max);
        isValidLatinList(vList0);
        final s0 = vList0.join('\\');
        final u8Latin = cvt.latin1.encode(s0);
        final bytes0 = Bytes.typedDataView(u8Latin);
        expect(s0.length <= bytes0.length, isTrue);
        expect(bytes0.endian == Endian.little, isTrue);

        final s1 = bytes0.getLatin();
        expect(s0 == s1, isTrue);
        final vList1 = sSplit(s1);
        isValidLatinList(vList1);
        expect(vList1, equals(vList0));

        final bytes1 = BytesLittleEndian.typedDataView(bytes0.buf);
        expect(bytes1.length == bytes0.length, isTrue);
        expect(bytes1.buffer == bytes0.buffer, isTrue);
        expect(bytes1 == bytes0, isTrue);

        final s2 = bytes1.getLatin();
        final vList2 = sSplit(s2);
        isValidLatinList(vList2);
        expect(vList2, equals(vList1));

        final bytes2 = Bytes.empty(s0.length, Endian.little)
          ..setUint8List(0, u8Latin);
        expect(bytes2 == bytes1, isTrue);
        final s3 = bytes2.getLatin();
        final vList3 = sSplit(s3);
        isValidLatinList(vList3);
        expect(vList3, equals(vList2));
      }
    });

    /// DICOM UTF-8 Strings
    test('UTF8 String tests', () {
      final vList = rng.latinList(0, 0);
      final s0 = vList.join('\\');
      final u8Utf8 = cvt.latin1.encode(s0);
      final bytes0 = Bytes.typedDataView(u8Utf8);
      expect(s0.length == bytes0.length, isTrue);
      expect(bytes0.endian == Endian.little, isTrue);
      expect(vList, equals(<String>[]));

      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.latinList(min, max);
        isValidUtf8List(vList0);
        final s0 = vList0.join('\\');
        // Urgent change to UTF8
        final u8List = cvt.latin1.encode(s0);
        final bytes0 = Bytes.typedDataView(u8List);
        expect(s0.length <= bytes0.length, isTrue);
        expect(bytes0.endian == Endian.little, isTrue);

        final s1 = bytes0.getLatin();
        expect(s0 == s1, isTrue);
        final vList1 = sSplit(s1);
        isValidUtf8List(vList1);
        expect(vList1, equals(vList0));

        final bytes1 = BytesLittleEndian.typedDataView(bytes0.buf);
        expect(bytes1.length == bytes0.length, isTrue);
        expect(bytes1.buffer == bytes0.buffer, isTrue);
        expect(bytes1 == bytes0, isTrue);

        final s2 = bytes1.getLatin();
        final vList2 = sSplit(s2);
        isValidUtf8List(vList2);
        expect(vList2, equals(vList1));

        final bytes2 = Bytes.empty(s0.length, Endian.little)
          ..setUint8List(0, u8List);
        expect(bytes2 == bytes1, isTrue);
        final s3 = bytes2.getLatin();
        final vList3 = sSplit(s3);
        isValidUtf8List(vList3);
        expect(vList3, equals(vList2));
      }
    });
  });
}
