// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Original author: Jim Philbin <jfphilbin@gmail.edu> - 
// See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

/// An error in [TypedData] alignment.
class AlignmentError extends Error {
  /// The Uint8List with the error.
  final Uint8List buf;

  /// The offset in [buf]'
  final int offsetInBytes;

  /// The length in from [offsetInBytes] in [buf].
  final int lengthInBytes;

  /// The element size in bytes.
  final int sizeInBytes;

  /// Constructor
  AlignmentError(
      this.buf, this.offsetInBytes, this.lengthInBytes, this.sizeInBytes);
}

/// Throws an [Alignment Error].
void alignmentError(
    Uint8List buf, int offsetInBytes, int lengthInBytes, int sizeInBytes) {
  throw AlignmentError(buf, offsetInBytes, lengthInBytes, sizeInBytes);
}
