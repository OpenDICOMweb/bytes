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
          throw  ArgumentError(msg);
        }
      }
    }
    return true;
  }

  List<String> sSplit(String s) => s.isEmpty ? <String>[] : s.split('\\');

  group('Bytes.fromAscii Utf8', () {
    test('ASCII String tests', () {
      final vListA = rng.asciiList(0, 0);
      print('vList0(${vListA.length}) $vListA');
      final s0 = vListA.join('\\');
      print('s0 "$s0"');

      final u8Ascii = cvt.ascii.encode(s0);
      final bytes0 = Bytes.typedDataView(u8Ascii);
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
        print('vList1(${vList1.length}) $vList1');
        expect(vList1, equals(vList0));

        final bytes1 = BytesLittleEndian.typedDataView(bytes0.buf);
        expect(bytes1.length == bytes0.length, isTrue);
        expect(bytes1.buffer == bytes0.buffer, isTrue);
        expect(bytes1 == bytes0, isTrue);

        final s2 = bytes1.getAscii();
        final vList2 = sSplit(s2);
        expect(vList2, equals(vList1));

        final bytes2 = Bytes.empty(bytes0.length, Endian.little)
          ..setString(0, s0);
        expect(bytes2 == bytes1, isTrue);
        final s3 = bytes2.getAscii();
        final vList3 = sSplit(s3);
        expect(vList3, equals(vList2));
      }
    });

    test('Latin String tests', () {
      final vList = rng.latinList(0, 0);
      print('vList(${vList.length}) $vList');
      final s0 = vList.join('\\');
      print('s0 "$s0"');
      final u8Latin = cvt.latin1.encode(s0);
      print('u8Latin $u8Latin');
      final bytes0 = Bytes.typedDataView(u8Latin);
      expect(s0.length == bytes0.length, isTrue);
      expect(bytes0.endian == Endian.little, isTrue);
      expect(vList, equals(<String>[]));

      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.latinList(min, max);
        isValidLatinList(vList0);
        print('vList0(${vList0.length}) $vList0');
        final s0 = vList0.join('\\');
        print('s0 "$s0"');
        final u8Latin = cvt.latin1.encode(s0);
        final bytes0 = Bytes.typedDataView(u8Latin);
        expect(s0.length <= bytes0.length, isTrue);
        expect(bytes0.endian == Endian.little, isTrue);

        final s1 = bytes0.getLatin();
        print('s1 "$s1"');
        expect(s0 == s1, isTrue);
        final vList1 = sSplit(s1);
        isValidLatinList(vList1);
        print('vList1(${vList1.length}) $vList1');
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
      for (var i = 0; i < repetitions; i++) {
        final u8List = rng.utf8Bytes(min, max);
        print('u8List.length ${u8List.length}');
        final s0 = cvt.utf8.decode(u8List, allowMalformed: true);
        print('s0.length ${s0.length}');
        final bytes0 = Bytes.typedDataView(u8List);
        print('bytes0.length ${bytes0.length}');
        expect(u8List.length == bytes0.length, isTrue);
        expect(u8List.buffer == bytes0.buffer, isTrue);
        expect(bytes0.endian == Endian.little, isTrue);

        final s1 = bytes0.getUtf8();
        print('s1.length ${s1.length}');
        expect(s1 == s0, isTrue);

        final bytes1 = BytesLittleEndian.from(bytes0);
        expect(bytes1.length == bytes0.length, isTrue);
        expect(bytes1.buffer == bytes0.buffer, false);
        expect(bytes1.endian == Endian.little, isTrue);

//        TODO: make this work
/*
        final bytes2 = Bytes.empty(bytes0.length);
        print('bytes2.length ${bytes1.length}');
        bytes2.setUtf8(0, s0);
        expect(bytes2 == bytes1, isTrue);
        final s2 = bytes2.getUtf8();
        expect(s2, equals(s1));
*/

      }
    });
  });
}
