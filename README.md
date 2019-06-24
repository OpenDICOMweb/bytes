# Bytes


The Bytes package:
    -  Combines Uint8List and ByteData.
    - _Endianness_ is declared when the Bytes are created.
    - Includes methods for getting/setting Ascii, Latin, and Utf8 Stringss
    - Includes methods for getting/setting all TypedData classes 

# Design
The Bytes class combines Uint8List and ByteData. The _endianness_
of a Bytes is declared at the time it is created, and then remains the
same for it lifetime.

_Note_: 
# Basics

All _String_s when converted to Bytes are UTF8

It defines DICOM objects such as:

1. Tags
2. Elements
3. Datasets
4. Entities

It defines DICOM values such as:

1. Ages
2. Dates
3. DateTimes
4. Frames
5. Times
5. Uids
6. Uuids

It also defines DICOM utility classes such as:

1.

3. throwOnError
4. client package
5. server package

## Usage

A simple usage example:

    import 'package:bytes/bytes.dart';

    main() {
      var awesome = new Awesome();
    }

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/OpenDICOMweb/sdk/issues
