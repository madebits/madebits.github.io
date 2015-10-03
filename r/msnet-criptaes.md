2008

#Cr!ptAES Free Encryption Tool

<!--- tags: encryption -->

[Cr!ptAes](#r/msnet-criptaes.md) | [Usage](#r/msnet-criptaes/usage.md) | [Encryption](#r/msnet-criptaes/encryption.md)

Cr!ptAES (read Cript-AES) is a free and easy to use GUI tool to encrypt files. Cr!ptAES comes handy to send encrypted files over the Internet, or over a private network, or just to protect sensitive local files with a password. Cr!ptAES encrypts files as streams in CBC mode with one of the following encryption algorithms:

* AES - 128, 192, or 256 bit keys
* Blowfish - 128, 192, 256, or 448 bit keys
* Serpent - 128, 192, or 256 bit keys

Key generation is based on PKCS#5 and SHA256. PKCS#5 and SHA512 is used to generate keys for Blowfish 448 bit.

![](r/msnet-criptaes/t_criptAES.gif)

Cr!ptAES requires the Microsoft .NET Framework, and will run with any .NET version. This tool is old, but fine. I do not use it myself, so I do not maintain it anymore.

##History

* Version 1.2.8 - Minor GUI improvements.
* Version 1.2.7 - Minor improvements.
* Version 1.2.6 - Interface improvements.
* Version 1.2.5 - Bug fixes.
* Version 1.2.4 - Salt size changed to be equal to key size. Files encrypted with the old versions with keys bigger than 128 bits cannot be decrypted with this version. The old version is available for free upon request. Use the newer versions for new files. The encryption format is now stable and will not change any more.
* Version 1.2.3 - Bug fixes. Added support for Blowfish and Serpent.
* Version 1.2.2 - Bug fixes.
* Version 1.2.1 - Added support to change the default suffix.
* Version 1.2.0 - Bug fixes, added support for finger prints and file wipe.
* Version 1.1.0 - Improved interface functionality.
* Version 1.0.0

[Cr!ptAes](#r/msnet-criptaes.md) | [Usage](#r/msnet-criptaes/usage.md) | [Encryption](#r/msnet-criptaes/encryption.md)

