// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Author: Jim Philbin <jfphilbin@gmail.edu> -
// See the AUTHORS file for other contributors.
import 'dart:typed_data';

import 'package:bytes/bytes.dart';
import 'package:rng/rng.dart';
import 'package:test_tools/tools.dart';

void main() {
  final rng = RNG();
  const repetitions = 100;
  const min = 0;
  // TODO make 100
  const max = 4;
  final hostEndian = Endian.host;

  for (var i = 0; i < repetitions; i++) {
    // vList0 is Endian.host
    final vList0 = rng.float32List(1, 1);
    print('vList00 $vList0}');
    print('bytes01 ${vList0.buffer.asUint8List()}}');
    for (var i = 0; i < vList0.length; i++) {
      final x = vList0[i];
      if (x == double.nan) print('vList0[$i] = $x');
    }

    assert(vList0 is Float32List);
    final u8List = getFloat32LE(Float32List.fromList(vList0));
    print('bytes02 $u8List');
    assert(vList0.buffer != u8List.buffer);
    assert(isAligned32(vList0.offsetInBytes));

    final bytes0 = BytesBigEndian.typedDataView(u8List);
    print('bytes03 ${bytes0.buf}');
    var x = bytes0.getFloat32(0);
    print('         x = $x');
    assert(bytes0.buf == u8List);
    assert(bytes0.endian == Endian.big);
    assert(bytes0.length == u8List.length);
    assert(bytes0.buffer == u8List.buffer);
    assert(isAligned32(bytes0.buf.offsetInBytes));

    final vList1 = bytes0.getFloat32List();
    print('float2 $vList1}');
    for (var i = 0; i < vList1.length; i++) {
      final x = vList0[i];
      if (x == double.nan) print('vList0[$i] = $x');
    }
    final bytes1 = Bytes.empty(bytes0.length, Endian.big);
    for (var i = 0; i < vList0.length; i++) {
      print('vList0[$i] = ${vList0[i]}');
      bytes1.setFloat32(i * 4, vList0[i]);
      final x = bytes1.getFloat32(i * 4);
      print('         x = $x');
    }

    //      ..setFloat32List(0, vList0);
    print('bytes10: ${bytes1.buf}');
    assert(bytes1.length == bytes0.length);
    if (bytes1 != bytes0) {
      print('bytes0 $bytes0');
      print('bytes1 $bytes1');
    }
    assert(bytes1.hashCode == bytes0.hashCode);
    final a = bytes1 == bytes0;
    assert(bytes1 == bytes0);
    assert(bytes1 == bytes0);

    final vList3 = bytes1.getFloat32List();
    print('float3 $vList3}');
    for (var i = 0; i < vList3.length; i++) {
      final x = vList3[i];
      if (x == double.nan) print('vList3[$i] = $x');
    }

    if (bytes0.endian == hostEndian) {
      assert(vList3 == vList0);
      if (isAligned32(vList0.offsetInBytes))
        assert(vList3.buffer == bytes1.buffer);
    } else {
      assert(vList3.buffer != bytes1.buffer);
    }

    final vList4 = bytes1.getFloat32List();
    for (var i = 0; i < vList4.length; i++) {
      final x = vList4[i];
      if (x == double.nan) print('vList4[$i] = $x');
    }

    for (var i = 0; i < vList0.length; i++) {
      final x = vList0[i];
      if (x.isNaN) print('vList2[vList2[$i] is $x');
      if (vList4[i].isNaN) print('vList4[$i] is ${vList4[i]}');
      if (vList0[i] != vList4[i]) print('${vList0[i]} != ${vList4[i]}');
    }
    assert(vList4.buffer != bytes1.buffer);
    assert(vList4.length == vList0.length);
    for (var i = 0; i < vList4.length; i++)
      assert(vList4[i] == vList0[i], 'vList4 ${vList4} vList2 ${vList0}');
    assert(vList4.buffer != bytes1.buffer);
  }
}
