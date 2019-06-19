# ToDo for Bytes & BytesBuffer Package

### Bytes

### Done

1. Make existing debug work
1. Make existing test work
4. Document all public methods,...

### Current

1. test noPadding
1. Separate String methods into Mixin.
1. make all test look like bytes_float32_test
1. Add test for all get/set methods little-endian and big-endian
1. Add test for String methods
5. Test and record performance
1. Finish README.md


### V 0.8

1. create mixins for big/little endian
2. Make Bytes abstract with Constructors for:

    a. Growable
      
        i. big endian
        ii. little endian
    
    b. Not Growable
    
        i. big endian
        ii. little endian
   
    c. ReadOnly

        i. big endian
        ii. little endian
        
5. Test and record performance

6. Add Read-Only version

### V 0.9

1. Remove all log.debug statements.

## ToDo for Bytes Package

### Done

1. Make existing debug work
1. Make existing test work

### Current

1. Should primitive getter and setters be checking length??
1. look at making rIndex/wIndex private
1. verify initialization of rIndex/wIndex
1. Separate String methods to Mixin
1. Add _isGrowable_ argument to constructors
1. Add write tests to all test files
1. Add string test
1. Add Byte and ByteData tests
1. Remove all ignore_for_file
4. Document all public methods,...
1. Add WriteBuffer test to all tests
5. Test and record performance
1. Finish README.md


### V 0.8

1. create mixins for big/little endian
2. Make Bytes abstract with Constructors for:

    a. Growable
      
        i. big endian
        ii. little endian
    
    b. Not Growable
    
        i. big endian
        ii. little endian
   
    c. ReadOnly

        i. big endian
        ii. little endian
        
5. Test and record performance

### V 0.9

1. Remove all log.debug statements.
