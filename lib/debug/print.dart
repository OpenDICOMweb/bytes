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

/// If _this_ has a length greater than the value, then the
/// number of bytes displayed by [bytesInfo] equal this value.
int truncateBytesLength = 12;

/// If _true_ the values in _this_ will be included in [bytesInfo].
bool showByteValues = true;

/// Returns a [String] with useful information about _this_.
String bytesInfo(Bytes bytes) {
  final sb = StringBuffer(bytes.toString());
  final offset = bytes.offset;
  final length = bytes.length;


  sb.write('$offset-${offset + length}:$length');
  // TODO: fix for truncated values print [x, y, z, ...]
  if (showByteValues) {
    if (length > truncateBytesLength) {
      sb.writeln('${bytes.sublist(offset, truncateBytesLength)}...');
    } else {
      sb.writeln('${bytes.sublist(offset, length)}');
    }
  }
  return '$sb';
}

// ToDo remove?
/// Utility for debugging
void printIt(int offset, int size, ByteData bd) {
  var s = '''
         offset $offset
           size $size
offset in bytes ${bd.offsetInBytes}
  size in bytes ${bd.lengthInBytes}
  ''';
  print(s);
}

