2007

#Base32 Encoding in C++

<!--- tags: cpp -->

Base32 encoding uses only 32 symbols to encode any data byte array (of 256 possible byte values). The 32 symbols to encode the data can be any, but often they are printable characters, letters (A-Z) and numbers (0-9). There are 26 letters and 10 numerical characters that make 36 in total, so 4 of them can be removed. Some documents, such as [RFC 3548](http://www.rfc-archive.org/getrfc.php?rfc=3548), standardize the printable characters to be used for base 32 encoding, but the choice may vary.

The implementation code here distinguishes between:

* encoding of data as base32, that is, expressing them as an byte array of values from 0 to 31, and
* mapping the base32 encoded data to a 32 characters alphabet.
* 
The implementation is in C++, but is mostly ANSI C compatible. It uses a `__int64` type as an intermediate buffer, which may not be supported by all compilers. For gcc in Linux, replace the `unsigned __int64` with `unsigned long long int`.

##Encoding Data

In order to use encode a byte array, find out first how long the output base32 data buffer needs to be. Given that 32 values are less than 256 values, the encoded array will be somehow longer. Finding the encoded buffer length can be done as follows:

```cpp
#define INPUT_LEN 123

unsigned char data256[INPUT_LEN] ;
// fill the data buffer with data
// ...

int encodeLength = Base32.GetEncode32Length(INPUT_LEN);
unsigned char data32[] = new char[encodeLength];
```

Then the data can be encoded in base32:

```cpp
if(!Base32.Encode32(data256, INPUT_LEN, data32))
{
 //error
}
```

##Mapping to a Base32 Alphabet

After the base32 encoding of the data, a mapping to an alphabet can be done as follows:

```cpp
const char alphabet[] = "123456789ABCDEFGHJKMNPQRSTUVWXYZ";
Base32.Map32(data32, encodeLength, alphabet);
```

`data32` data values are mapped in place.

##Reversing the Process

To reverse the process just repeat the symmetrical steps:

```cpp
Base32.Unmap32(data32, encodeLength, alphabet);
```

As with mapping, the unmap is done in place. The decoding code follows:

```cpp
int decodeLength = Base32.GetDecode32Length(data32);
char decode256[] = new char[decodeLength];

Base32.Decode32(data32, encodeLength, decode256);
```

Finally, when finished, free the buffers:

```cpp
delete[] data32;
delete[] decode256;
```