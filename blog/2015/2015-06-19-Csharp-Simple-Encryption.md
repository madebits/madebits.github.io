#C\# Simple Encryption

2015-06-19

<!--- tags: csharp encryption -->

Simple encryption code snippet in C# for `byte[]` and `string` to have around for AES in CBC mode either with authentication (HMACSHA256) (after encryption) or not. Different AES and MAC keys are generated from password (with different salt).

```cs
using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;

namespace Utils
{
    public static class Encryption
    {
        [Serializable]
        public class Error : ApplicationException 
        {
            public Error() : base() { }
            public Error(string m) : base(m) { }
            public Error(string m, Exception e) : base(m, e) { }
        }//EOIC

        public enum Mode { Encrypt, Decrypt }
        public enum KeySize { K128, K192, K256 }
        
        public class MacData
        {
            public Mode Mode { get; set; }
            public byte[] Data { get; set; }
            public string Password { get; set; }
            public int IterationCount { get; set; }

            public bool ModeBool 
            {
                get { return this.Mode == Encryption.Mode.Encrypt; }
                set { this.Mode = value ? Encryption.Mode.Encrypt : Encryption.Mode.Decrypt; }
            }

            public string DataStr 
            {
                get
                {
                    if (this.Data == null) return null;
                    return Encoding.UTF8.GetString(this.Data);
                }
                set 
                {
                    if (value == null) this.Data = null;
                    this.Data = Encoding.UTF8.GetBytes(value);
                }
            }

            public string DataBase64Str
            {
                get
                {
                    if (this.Data == null) return null;
                    return Convert.ToBase64String(this.Data);
                }
                set
                {
                    if (value == null) this.Data = null;
                    this.Data = Convert.FromBase64String(value);
                }
            }

            public virtual void Validate()
            {
                if (string.IsNullOrEmpty(this.Password)) throw new Error("Password");
                if (this.IterationCount < 1) this.IterationCount = 1;
            }
        }

        public class TransformData : MacData
        {
            public KeySize KeySize { get; set; }
            public TransformData() 
            {
                this.KeySize = Encryption.KeySize.K128;
                this.IterationCount = 1024 * 10;
            }

            public int KeySizeInBytes 
            {
                get 
                {
                    switch (this.KeySize) 
                    {
                        case Encryption.KeySize.K128: return 16;
                        case Encryption.KeySize.K192: return 24;
                        case Encryption.KeySize.K256: return 32;
                        default: throw new Error();
                    }
                }
            }

            public TransformData GetThinCopy()
            {
                return new TransformData
                {
                    Data = this.Data,
                    IterationCount = this.IterationCount,
                    Mode = this.Mode,
                    Password = this.Password,
                    KeySize = this.KeySize
                };
            }

        }//EOIC

        public static string Transform(Mode mode, string s, string password, bool useMac = false) 
        {
            if (s == null) return null;
            var p = new TransformData { Mode = mode, Password = password, KeySize = KeySize.K256 };
            TransformData r = null;
            switch (mode)
            {
                case Mode.Encrypt:
                    p.DataStr = s;
                    r = useMac ? TransformAE(p) : Transform(p);
                    return r.DataBase64Str;
                case Mode.Decrypt:
                    p.DataBase64Str = s;
                    r = useMac ? TransformAE(p) : Transform(p);
                    return r.DataStr;
                default:
                    throw new Error();
            }
        }

        public static TransformData TransformAE(TransformData p)
        {
            TransformData r = null;
            switch (p.Mode) 
            {
                case Mode.Encrypt:
                    r = Transform(p);
                    var rc = r.GetThinCopy();
                    rc.Mode = p.Mode;
                    r.Data = Mac(rc);
                    return r;
                case Mode.Decrypt:
                    r = p.GetThinCopy();
                    r.Data = Mac(r);
                    return Transform(r);
                default:
                    throw new Error();
            }
        }

        public static TransformData Transform(TransformData p)
        {
            if (p == null) throw new ArgumentNullException();
            if (p.Data == null) return null;
            p.Validate();
            var processData = Process((ms) => {
                byte[] res = null;
                var isEncrypt = p.ModeBool;
                var keySize = p.KeySizeInBytes;
                var salt = new byte[keySize];
                var iv = new byte[16];
                ms = Preprocess(p.Mode, p.Data, salt, iv);
                using (var aes = new RijndaelManaged())
                {
                    var key = GetKey(p.Password, salt, p.IterationCount, keySize);
                    try
                    {
                        aes.KeySize = keySize * 8;
                        aes.Mode = CipherMode.CBC;
                        var cryptoTransform = isEncrypt
                            ? aes.CreateEncryptor(key, iv)
                            : aes.CreateDecryptor(key, iv);
                        using (var cs = new CryptoStream(ms, cryptoTransform,
                            isEncrypt ? CryptoStreamMode.Write : CryptoStreamMode.Read))
                        {
                            if (isEncrypt)
                            {
                                cs.Write(p.Data, 0, p.Data.Length);
                                cs.FlushFinalBlock();
                                res = ms.ToArray();
                            }
                            else
                            {
                                var plain = new byte[p.Data.Length];
                                var count = cs.Read(plain, 0, plain.Length);
                                res = new byte[count];
                                Buffer.BlockCopy(plain, 0, res, 0, count);
                            }
                        }
                    }
                    finally 
                    {
                        Array.Clear(key, 0, key.Length);
                    }
                }
                return new Tuple<byte[], MemoryStream>(res, ms);
            });
            var pc = p.GetThinCopy();
            pc.Data = processData;
            pc.Mode = (p.Mode == Mode.Encrypt) ? Mode.Decrypt : Mode.Encrypt;
            return pc;
        }

        public static byte[] Mac(MacData p)
        {
            if (p == null) throw new ArgumentNullException();
            if (p.Data == null) return null;
            p.Validate();
            return Process((ms) =>
            {
                var mac = new byte[32];
                var salt = new byte[mac.Length / 2]; // to keep it short
                ms = Preprocess(p.Mode, p.Data, salt, mac);
                var key = GetKey(p.Password, salt, p.IterationCount, mac.Length);
                try
                {
                    using (var hmac = new HMACSHA256(key))
                    {
                        switch (p.Mode)
                        {
                            case Mode.Encrypt:
                                mac = hmac.ComputeHash(p.Data, 0, p.Data.Length);
                                ms.Seek((long)salt.Length, SeekOrigin.Begin);
                                ms.Write(mac, 0, mac.Length);
                                ms.Write(p.Data, 0, p.Data.Length);
                                return new Tuple<byte[], MemoryStream>(ms.ToArray(), ms);
                            case Mode.Decrypt:
                                var dataMac = hmac.ComputeHash(ms);
                                if (!SameHash(dataMac, mac))
                                {
                                    throw new ApplicationException();
                                }
                                var prefixLength = salt.Length + mac.Length;
                                ms.Seek((long)prefixLength, SeekOrigin.Begin);
                                var data = new byte[p.Data.Length - prefixLength];
                                if (ms.Read(data, 0, data.Length) != data.Length) throw new ApplicationException();
                                return new Tuple<byte[], MemoryStream>(data, ms);
                            default:
                                throw new Error();
                        }
                    }
                }
                finally
                {
                    Array.Clear(key, 0, key.Length);
                }
            });
        }
        
        private static RNGCryptoServiceProvider Rand = null;

        static Encryption()
        {
            Rand = new RNGCryptoServiceProvider();
        }

        private static byte[] Process(Func<MemoryStream, Tuple<byte[], MemoryStream>> f) 
        {
            byte[] res = null;
            MemoryStream ms = null;
            try
            {
                var temp = f(ms);
                res = temp.Item1;
                ms = temp.Item2;
            }
            catch (Exception ex)
            {
                throw new Error("Failed", ex);
            }
            finally
            {
                if (ms != null)
                {
                    try { ms.Close(); }
                    catch { }
                    ms = null;
                }
            }
            return res;
        }

        private static MemoryStream Preprocess(Mode mode, byte[] data, params byte[][] parts)
        {
            MemoryStream ms = null;
            switch (mode) 
            {
                case Mode.Encrypt:
                    ms = new MemoryStream();
                    foreach (var p in parts)
                    {
                        Rand.GetBytes(p);
                        ms.Write(p, 0, p.Length);
                    }
                    break;
                case Mode.Decrypt:
                    ms = new MemoryStream(data);
                    foreach (var p in parts)
                    {
                        if(ms.Read(p, 0, p.Length) != p.Length) throw new ApplicationException();
                    }
                    break;
                default:
                    throw new Error();
            }
            return ms;
        }

        private static byte[] GetKey(string password, byte[] salt, int icount, int keyLengthBytes)
        {
            // PasswordDeriveBytes(password, salt, "SHA256", icount)
            using (var pdb = new Rfc2898DeriveBytes(password, salt, icount))
            {
                return pdb.GetBytes(keyLengthBytes);
            }
        }

        private static bool SameHash(byte[] a1, byte[] a2)
        {
            if (a1 == a2) { return true; }
            if ((a1 != null) && (a2 != null))
            {
                if (a1.Length != a2.Length)
                {
                    return false;
                }
                for (int i = 0; i < a1.Length; i++)
                {
                    if (a1[i] != a2[i])
                    {
                        return false;
                    }
                }
                return true;
            }
            return false;
        }
    }//EOC
}//EON
```

Usage example:

```cs
var p = new Encryption.TransformData { DataStr = "abc", Password = "test" };
var encrypted = Encryption.Transform(p);
var decrypted = Encryption.Transform(encrypted);
```

After this code `encrypted.DataBase64` contain the encrypted data, and `decrypted.DataStr` is same as `p.DataStr`. Similarly, `Encryption.TransformAE` can be used to encrypt and MAC the data. 

To easy encrypt strings use:

```cs
var e = Encryption.Transform(Encryption.Mode.Encrypt, "abc", "test");
var d = Encryption.Transform(Encryption.Mode.Decrypt, e, "test");
```

Now `d` is `abc` and `e` is Base64 encrypted text.

<ins class='nfooter'><a id='fprev' href='#blog/2015/2015-06-21-Using-ProtonMail.md'>Using ProtonMail</a> <a id='fnext' href='#blog/2015/2015-06-09-Encrypting-Git-Home-Folder-on-Windows.md'>Encrypting Git Home Folder on Windows</a></ins>
