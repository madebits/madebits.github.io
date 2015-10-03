2004

A CBC Stream Cipher in C#
=============

<!--- tags: csharp encryption -->

*With wrappers for two open source AES implementations in C# and C*

This is an improved and updated version of a CodeProject [article](http://www.codeproject.com/dotnet/csstreamcipher.asp).

<div id='toc'></div>

.NET has very good support for cryptography as part of the `System.Security` namespace [NETC](http://msdn.microsoft.com/library/ default.asp?url=/library/ en-us/cpref/html/frlrfsystemsecuritycryptography.asp). To understand how .NET cryptography implementation works one has to know that most of interfaces and implementation are wrappers to Microsoft Crypto API [CAPI](http://www.faqs.org/rfcs/rfc2628.html). The Crypto API design is quite nice but it lacks an important feature: it is not transparent [CGNL](http://www.schneier.com/crypto-gram-9909.html). This means that a lot of trust must be placed into something whose internals are not known. Another problem with Cryto API is the way its default providers deal with keys. The keys are stored encrypted in a database in the local computer. Again no choice is given, but to trust it. For these reasons open source cryptography libraries will always find a way in .NET. The biggest such library comes as part of Mono [MONO](http://www.go-mono.com/crypto.html) and it is an open source rewrite of .NET `System.Security.Cryptography` namespace. Despite its availability, non Mono .NET users would have problems to use the library in .NET applications. It is integrated in the Mono corelib.dll and one has to import a lot of unnecessary code in order to use a simple algorithm, not to mention namespace conflicts. So other simpler open source implementations would serve well into .NET world.

When implementing a cryptography provider for .NET the best way to organize it to implement the interfaces of `System.Security.Cryptography`, so that your provider will work uniformly with any existing code that uses .NET interfaces and users do not have to learn a new API. This perfect software engineering solution has some security drawbacks. Given that .NET interfaces are well known, it is easier for any third party to intercept calls make to the generic interfaces. Because of the enriched metadata nature of .NET this is even easier to do than with normal binaries. The well known interfaces makes it possible to write generic spy software that works with many products. So despite the cryptography provider quality and transparency there is no insurance that there are no third party programs that can collect the keys in a .NET framework deployment, or in the underlying Crypto API. One partial solution, which is not optimized from the software engineering point of view, is to use custom interfaces. The situation is similar to using Outlook Express for viewing email. Because many people use it, a virus written for Outlook Express will very likely hit a lot of users. If a custom email client is used, no one will bother to write a virus for a program that is used by a small minority of users. In this context, the CBC stream cipher here uses its own simple interface which does not rely on any of .NET crypto API interfaces and classes. It actually uses only `System` and `System.IO` for streams.

##The CBC Stream Cipher Library

Everything started by an AES [FIPS197](http://csrc.nist.gov/publications/fips/fips197/fips-197.pdf) implementation in C# in the MSDN magazine [CSAES](http://msdn.microsoft.com/msdnmag/issues/03/11/AES/default.aspx). AES is symmetric block cipher algorithm, which means that the same key is use for encryption and decryption. The C# code of [CSAES](http://msdn.microsoft.com/msdnmag/issues/03/11/AES/default.aspx) is easy to understand but the implementation is very slow for some reason, even if the polynomials multiplication is replaced with fixed tables. A faster implementation of AES in C, which is freely available, can be found in [CAES](http://fp.gladman.plus.com/AES/index.htm).

To use the AES block cipher implementation for real encryption, a a stream cipher must be created. The easiest way is to create an ECB (Electronic Codebook) stream cipher which basically encrypts each block of a stream using the block cipher. The ECB mode is also supported in this implementation because it could be useful for testing purposes. It is not secure because the correlation patterns found in the plaintext will still be visible in the ciphertext. The CBC (Cipher Block Chaining) mode is safe from this weakness and it is relatively easy to implement. It basically XOR-s each plaintext block with the previous ciphertext block before encrypting it. This way the plaintext patterns are no more visible in the output. The CBC mode makes use of an initialization vector (IV) to XOR the first block. The IV does not need to be secret as it shows nothing about the data (plain or cipher) or about the key. The IV must be selected to be different (it has not to be necessarily random) for each stream (file) we encrypt with a given key. In the CBC implementation given here the IV size must be the same as the size of cipher block, which is always 16 bytes for AES. The CBC mode is the default mode for the stream cipher given here.

Any block cipher implementation can used with the library as long as there is a wrapper class that implements IBlockCipher interface shown below:

```csharp
interface IBlockCipher {
    void InitCipher(byte[] key); // key.Length is keysize in bytes
    void Cipher(byte[] inb, byte[] outb);
    void InvCipher(byte[] inb, byte[] outb);
    int[] KeySizesInBytes();
    // iv length will/must be the same as BlockSizeInBytes
    int BlockSizeInBytes();
}
```

Two wrappers are written that implement this interface: one for the C# AES implementation [CSAES](http://msdn.microsoft.com/msdnmag/issues/03/11/AES/default.aspx) and another for the fast C AES DLL implementation [CAES](http://fp.gladman.plus.com/AES/index.htm). This way these two algorithms can be use with the CBC stream cipher given here. See the 'aes.CAes.cs' in the code for an example how a wrapper looks like.

##Using the Code

The C# stream cipher library can be used as follows:

```csharp
IBlockCipher ibc = new CAes(); // new Aes();
byte[] key = ... ;
byte[] iv = ... ;
StreamCtx ctx = StreamCipher.MakeStreamCtx(ibc, key, iv);
```

`iv` array size can be found by calling `ibc.BlockSizeInBytes()` which returns 16 for AES. The key array size can be found by calling `ibc.KeySizesInBytes()` which returns {16, 24, 32} for AES, corresponding to 128, 192 and 256 bits. One of these values must be selected. An improvement of `IBlockCipher` in the future would be to return a key size step as .NET does.

`StreamCtx` objects returned by `StreamCipher.MakeStreamCtx` are read-only and `StreamCipher.MakeStreamCtx` must always be used to obtain a valid context. Once a `StreamCtx` context is obtained, it can used with the other static methods of StreamCipher class to encrypt or decrypt streams:

```csharp
Stream instr = ... ; // open plaintext stream
Stream outstr = ... ; // create a stream for ciphertext output
StreamCipher.Encrypt(ctx, instr, outstr);
```

It is recommend to buffer streams before passing them to the `StreamCipher` methods. To encrypt `byte` arrays use:

```csharp
byte[] indata = ... ;
byte[] outdata = StreamCipher.Encode(ctx, indata, StreamCipher.ENCRYPT);
```

Decryption is done similarly with respective methods. See 'aes-example.cs' for a complete example. The decryption process will fail silently if errors.

##Key Generation

One problem we skipped above it how to get a key. Any byte array with size equal to one of the values returned in `IBlockCipher.KeySizesInBytes()` array will do for AES. Other algorithms may have sets of weak key values, so a future improvement to `IBlockCipher` would be to add a method `byte[] GenerateKey()`, which would be implemented by the block cipher wrapper.

Most people cannot remember a 16 or 32 byte key such as *8ea2b7ca516745bfeafc49904b496089* without writing it somewhere. Physically storing a secret key somewhere, even when it is encrypted, is not a very feasible solution. People prefer better a form of key which is easier to remember, usually in the form of a string password (or pass-phrase).

Password based cryptography [PBCS](http://www.faqs.org/rfcs/rfc2898.html) is weaker that using keys directly, given that the search space of a password is smaller than for a key. For example, with a 256 bit key in AES there are 2^256 (read as: 2 in the power of 256) possibilities to search in the worst case. A keyboard contains approximately 2^6 unique keys (letters, capital letters, numbers, special characters) that can be used in a password. This means that for a truly random password of 20 characters long (which we will find too complicated to remember), the brute force search space is only (2^6)^20 = 2^120 in the worst case. This is even lower that the smallest key size for AES which is 2^128. So if a password encryption scheme with passwords of 20 characters is used, it makes no sense to use a key bigger than 128 bit for AES. In reality the length of the password is not known which means that for passwords up to 20 characters the search space size can be calculated as follows: sum(for i = 0 to 20) of (2^6)^i, which is again approximately the same as its biggest term value, that is 2^120.

Another problem with passwords is that people tend to reuse them. That is we prefer to (re)use the same password to encrypt different data units (files). This means that we are using the same key to encrypt a large amount of plain-text, resulting in a large amount of cipher-text which in theory can be used to explore patterns and find the cipher key (not the password) and obtain the plain-text. So, it is better to use different keys to encrypt different data units, which seem to contradicts the idea of having a single reusable password.

There are two ways how the situation can be improved without lengthening or changing the password as described in [PBCS](http://www.faqs.org/rfcs/rfc2898.html). The first one is to add a few different bytes in the end of the password every time it is used to generated a key, and use different bytes for different data units to be encrypted. These bytes are known as 'salt'. The salt bytes must be random, or at least different for each stream of data we encrypt. This way we would have a new different key every time, to use for encryption, based on the same root password. A salt between 8 and 16 bytes is usually enough to generate a big possible key space. To decrypt the data we must know the original salt used to encrypt it, apart of the password. The good news is that salt need not to be secret: if salt were to be kept secret then (a) do not use a salt but use a different password/key each time; (b) it needs to be remembered, and this result in a no better position that remembering the encryption key itself. Thus, while the salt does not enlarge the password search space, it grows the effective key space used for the cipher-text, making it impossible to find the keys by someone which has access to all your cipher-text and all your corresponding salts.

The second technique effectively grows the search space for passwords without growing up the password size. It takes into consideration not only the size of the search space but also the time it takes to make a try. When we said that the search space for random 20-character long passwords is around 2^120, which is smaller than 2^128, the space of the smallest AES key size, we assumed that testing for a password takes the same time as testing a key. We can make the situation better by growing the time it makes to generate a key from a password. Of course this cannot be done by adding delays in code, but by growing the amount of calculations needed. In [PBCS] this is controlled by what is called an iteration count. An iteration count of 2^10 will make the effective time grow up around 2^120 * 2^10 = 2^130 time units compared with an iteration count of 1. Bigger values are of course better but make the key generation two slow in practice with the current computation power. So if the password in known, one can compute the key in around 2^10 time units. If the password is not known, the worst case to try all passwords up to 20 characters would require around 2^130 time units.

These two improvements make using passwords (even when using the same password all the time) comparable in security with using different keys. The class KeyGen in the library presented here implements the first method described in [PBCS](http://www.faqs.org/rfcs/rfc2898.html) (which is easier to implement and also relatively secure - actually same secure as we do not reuse any bytes here). A key can be generated from a string password as follows:

```csharp
int keySize = 32;
byte[] salt = ...;
byte[] key = KeyGen.DeriveKey(password, keySize, salt); //iteration count 1024
```

`DeriveKey()` uses a free C# implementation of SHA256 to hash the data. It can generate keys up to 32 bytes (256 bits) long.

Time is relative. A number such as 2^120 means that if a computer makes 100 guesses per second, it will take approximately *421495432453359929256661295* years to finish (in the worst case). If one ever had *421495432453359929256661295* computers, it would take only one second to do the calculations. And if a hidden camera, or a keylogger is deployed to steal the password from someone as s/he types it in (etc, etc), not that many computers are needed.

##Generating Random Numbers

As mentioned above the IV and salt do not need to be really random - they just need to be different for each encrypted stream of data. The stream cipher library implemented here does not offer a way to create a salt or an IV, given that different applications may use different ways to generate and distribute them. A simple way to get an IV and salt byte array of a given length is to use a pseudo-random byte generator.

Normal pseudo-random byte generators have usually a short sequence period and are not very are not useful to generate the IVs and salts, because the generated pseudo-random data will be repeated after some time. A simple, but useful cryptographically strong pseudo-random generator can be created based on a secure hash function, such as, SHA256. The idea is to hash the output of SHA256 repetitively.

`StrongRandomGenerator` class in code (StrongRandomGenerator.cs) provides an implementation of a cryptographically strong random generator based on SHA256. It can be initialized with some random seed, or, by default, it uses various system parameters as a seed, and can be used as follows:

```csharp
byte[] IV = new byte[16];
byte[] salt = new byte[16];
StrongRandomGenerator rnd = new StrongRandomGenerator();
rnd.NextBytes(IV);
rnd.NextBytes(salt);
```

Each `StrongRandomGenerator` instance has by default a different seed. The `NextBytes()` method can be called as many times as desired.

Properties of hash based pseudo-random generators are not well-understood. I will argue that `StrongRandomGenerator` pseudo-random generator fulfills the two main requirements of a cryptographically secure pseudo-random generator:

* Unfeasible periodicity. The periodicity is around 2^256 (it depends on how good the SHA256 is). This is practically enough, as the number of all possible IVs for AES is 2^128.

* Unpredictable. The output of the function is not predictable to an external observer. The implementation reports only the first half of each SHA256 hash. This way even when using the minimum buffer, there are still 2^128 possibilities what the next value will be.

##Compatibility

`StreamCipher.cs` has padding compatible with (CryptoAPI) .NET's `SymmetricAlgorithm` implementation. The data encrypted with .NET Rijndael can be decrypted with this library (using the AES wrappers) and vice-versa.

`KeyGen.DeriveKey` is also compatible with .NET `PasswordDeriveBytes`. This call:

```csharp
string password = ...;
int keyLength = 16; // up to 32
byte[] salt = ...;
int iterationCount = ...;

byte[] key = KeyGen.DeriveKey(password,
  keyLength, salt, iterationCount);
```

produces the same key from a password as the following `System.Security.Cryptography` code:

```csharp
PasswordDeriveBytes pdb = new PasswordDeriveBytes(
  password, salt, "SHA256", iterationCount);
byte[] key = pdb.GetBytes(keyLength);
```

##Acknowledgments

Thanks to Ulrike Meyer for explaining why the IV-s need not to be secret. The understanding of salt and iteration count also followed a nice discussion with her of [PBCS](http://www.faqs.org/rfcs/rfc2898.html). James McCaffrey' comments on the first ECB version of the stream cipher encouraged finishing the standard-compatible CBC version.