//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'package:bytes/bytes.dart';
import 'package:bytes/src/constants.dart';
import 'package:test/test.dart';

void main() {
  group('Bytes Growing Tests', () {
    test('Test ensureLength for doubling size', () {
      final bytes = Bytes.empty();
      for (var i = 1; i < k1GB; i = i * 2) bytes.ensureLength(i);
    });

    test('Test ensureLength above 1MB', () {
      final bytes = Bytes.empty(k1MB);
      for (var i = 1; i < 128 * k1MB; i++) bytes.ensureLength(i);
    });
  });
}
