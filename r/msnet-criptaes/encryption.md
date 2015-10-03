#Cr!ptAES: Encryption

[Cr!ptAes](#r/msnet-criptaes.md) | [Usage](#r/msnet-criptaes/usage.md) | [Encryption](#r/msnet-criptaes/encryption.md)

Cr!ptAES is a file-based encryption program. It encrypts files as streams in CBC mode. Cr!ptAES does NOT use any of .NET, or CryptoAPI algorithms implementations, or interfaces. Cr!ptAES is fully standards compliant and its AES implementation is fully compatible with .NET Rijndael SymmetricAlgorithm implementation in CBC mode. The complete C# source code of all deployed algorithms is provided.

* Cr!ptAES uses a fast open source C# AES (Rijndael) FIPS-197 implementation from [BouncyCastle.org](http://www.bouncycastle.org/). This C# implementation is based on the open source Java implementation with the optimizations of Brian Gladman. All the AES keys lengths of 128 bit, 192 bit, and 256 bit are supported. Blowfish and Serpent implementations come also from BouncyCastle.org.
* Cr!ptAES uses a custom lightweight CBC stream cipher, and combines it with AESFastEngine, BlowfishEngine and SerpentEngine from BouncyCastle.org, by removing the BouncyCastle.org infrastructure code from the raw encryption algorithms. The CBC stream cipher has padding compatible with PKCS #5, section 6.2, and when combined with AES, it is the same as .NET Rijndael implementations in CBC mode.
* Password generation is based on RFC 2898 - PKCS #5. Cr!ptAES uses a free implementation of SHA256 and the generation method is binary compatible with .NET PasswordDeriveBytes.GetBytes method. The default iteration count is 1024 and it is configurable by the user. For Blowfish, the weak keys are checked and avoided (using new random salt) automatically during encryption. For Blowfish 448, PKCS #5 and the SHA512 from the same source as SHA256 are used.
* Initialization vector for CBC mode and the random salt (the salt is as big as the key size) for the password are generated using a strong random pseudo-random generator based on SHA256. The initialization seed is based on various unique system run-time and not run-time parameters, and on the mouse moves that the user makes from the program start, until the first key is generated.
* No .NET System.Security.Cryptography, or system CryptoAPI, or Random classes, methods, or interfaces are used. The implementation is fully compatible with .NET Rijndael implementation in CBC mode.

The complete standards-compatible encryption system of Cr!ptAES is shown below:

![](r/msnet-criptaes/encryption-schema.gif)

Cr!ptAES offers strong encryption. The user can specify the password, the encryption type, and optionally the iteration count. The encryption type controls the size of encryption key, size of the salt (same as key size), the size of the IV (the same as block size), and the encryption algorithm and the block size used. The password and the iteration count control the encryption key used. The IV and salt are generated randomly and are saved in the head of the file (safe). The password, or the hashed encryption key are never saved.

During the decryption the IV and salt sizes are again found from the encryption type supplied by the user. The decryption key is generated in the same way as during encryption, from the password and the iteration count. If one of the three input parameters: the password, the encryption type, or the iteration count is wrong, then the data cannot be decrypted. The encryption type and the iteration count have limited variability and should NOT be used as a secret. Only the password should be a secret, and it should be long enough, at least 25 random characters.

##CBC Mode Explained

MSDN Magazine of November 2006 has an [article](http://msdn.microsoft.com/msdnmag/issues/06/11/ExtendingSDL/default.aspx) by Mark Pustilnik where he nicely explains the differences between the safe CBC encryption mode and the weak ECB encryption mode via an illustration of the Windows logo repeated below. Cr!ptAES uses the safer CBC encryption mode for the entire file contents (not block-wise, as hard-disk real-time random-access volume encryption tools are forced to do, hence the Cr!ptAES method remains the safest encryption mode):

**Plaintext | ECB | CBC**

![inline](r/msnet-criptaes/fig02a.gif) ![inline](r/msnet-criptaes/fig02b.gif) ![inline](r/msnet-criptaes/fig02c.gif)

Of course, if you encrypt the plaintext image file show above, with ECB, or CBC modes, it will not show like that, because the image format will be also encrypted, but if you were to encrypt only the pixel data, and put them back in the image format, then it would look similar.

[Cr!ptAes](#r/msnet-criptaes.md) | [Usage](#r/msnet-criptaes/usage.md) | [Encryption](#r/msnet-criptaes/encryption.md)