2008

# AES Encryption Tool

<!--- tags: cpp encryption -->

AES tool is a free command-line tool that encrypts / decrypts one file at a time using a password. I wanted a small encryption tool to have around for casual encryption of files, that meets my expectations:

* Self-contained, only dependant on standard C library.
* Cross-platform. C source code available (GPL). Easy to compile on your own on any platform.
* Secure by design:
   * AES 256 bit in CBC mode. CBC encryption is a time-proven secure mode in this context. Most threats against disk-based or SSL-based CBC do not apply if you encrypt few files fully one at at a time.
   * Additional authenticated encryption (AE) with HMAC-SHA256 around data CBC stream. Stream speed is not an issue in this use case. Both AE salt (used with PBKDF2 to generate initial HMAC block) and final HMAC hash are also encrypted as part of CBC stream.
   * Key generation is based on PBKDF2 with HMAC-SHA256 with a *sensible* default iteration count of 1.000.000 (configurable), which is ok for encrypting few files.
   * PBKDF2, HMAC-SHA256, AES implementations are from http://xyssl.org/. I only wrote the glue code.
* No information leaks. The encrypted files have no identifying bytes. Apart of file length that is a multiple of 16, data look fully random.
* Pipe friendly. A tool like this should be easy to combine with other tools in command-line.

## Usage

AES tool encrypts / decrypts one file at a time:

* To encrypt:

  ```bash
  ./aes -i file.txt -o file.bin -p password
  ```

* To decrypt:

  ```bash
  ./aes -d -i file.bin -o file.txt -p password
  ```

If the input (`-i file`) is not specified, or `-i -` then `stdin` is used. If the output (`-o file`) is not specified, or `-o -` then `stdout` is used. If the output file exists it will be overwritten!

The password is specified as string on command-line via `-p`, which is usually convenient, but it be can be unsafe, or via a file using `-f` (reads at most 1024 bytes from first line in file). If you like to type in the password safely in Bash shell use:

 ```bash
 read -p "Password: " -s pass && ./aes -i file.txt -o file.bin -f <(echo -n "$pass")

 read -s pass && ./aes -d -i file.bin -o file.txt -f <(echo -n "$pass")
 ```

## Using Pipes

`aes` tool supports reading input from stdin and writing to stdout. For example, the following command should print `0` on Linux:

```
./aes -p test < test.txt | ./aes -d -p test > test1.txt ; [ -z "$(diff test.txt test1.txt)" ] ; echo $?
```

In a similar way, this command outputs "abc":

```bash
echo -n "abc" | ./aes -p "t" | base64 | base64 -d | ./aes -d -p "t"

# or

read -s pass && echo abc | aes -f <(echo -n "$pass") | aes -d -f <(echo -n "$pass")
```

The `base64 | base64 -d` part in example above is not really needed. I put it there to show how to encrypt as printable text, if you ever need that.

## Advanced Usage Examples

On Linux, */dev/urandom* is used as default source for IV, salt data. The file source to read random data can be set also via `-r /dev/urandom` option during encryption.

* If */dev/urandom* is not found and `-r file` is not set, or not enough data to read in the specified `-r file`, then the C `rand()` is used, which is *weak*. Salt and IV only need to be different for each encryption, not really random.
* The `-r file` can also be used for testing, to have reproducible encryption tests (e.g., using `-r /dev/zero`).

An example using `tar` on Linux to compress a folder `./pictures` (a similar command can be used to backup whole $HOME folder):

* To archive `./pictures` folder compressed and then encrypt it as `data.bin` use:

   ```bash
   tar -cvzpf - ./pictures/ | ./aes -p t -r /dev/urandom -o data.bin
   ```

* To decrypt `data.bin` and then uncompress and unarchive it as `./pictures` use:

   ```bash
   ./aes -d -p t -i data.bin | tar -zxv
   ```

Use passwords with more than 20 random numbers letters and special characters. To create a good random password of length 45 you can use for example:

   ```bash
   head -c 45 /dev/urandom | base64 -w 0

   # or

   dd if=/dev/urandom bs=45 count=1 | base64 -w 0
   ```

The iteration count is by default *1.000.000*. It can be changed via `-c 1024` option.

Some of less useful `aes` tool options *weaken* the default settings, but are useful up and now for variability:

* `-k  256` to specify AES 128, 192, or 256 bit (256 bit is default).
* `-a` use non-authenticated encryption, by default authenticated encryption is used.
* `-m` to use PBKDF1 for `-c interationCount` (default is PBKDF2). The `-m` option makes sense only if `-a` is also specified and it is ignored otherwise.
* `-s` use 16 byte salt for CBC. By default, the CBC salt length is same as `-k` size. AE salt is always 32 bytes.

The `-p`, `-k`, `-a`, `-m`, `-s`, `-c` options must specified **same** during decryption, otherwise you cannot access your data.

It is possible to encrypt same data more than once in a chain:

```bash
echo "abc" | ./aes -p p1 -k 256 | ./aes -p p2 -k 128 | ./aes -d -p p2 -k 128 | ./aes -d -p p1 -k 256
```

We first encrypt twice with password `p1` and then `p2` with different AES key sizes (-k); and then we decrypt (`-d`) the pipe result twice with same data in reverse. The output is `abc`. Encrypting more than once is safer, but slower.

To have an infinite *pseudo-random* data stream use:

```bash
cat /dev/zero | ./aes -a -m -p t -c 1024

# or as text

cat /dev/zero | ./aes -a -m -p t -c 1024 | base64 -w 0
```

Use `aes -?` to view help.

## Encrypted File format

The encrypted files have no identifying bytes and have this layout:

```
encrypted file = iv (16 bytes), salt (same bytes as AES key size), CBC encrypted data
```

Inside *CBC encrypted data*, the authenticated encryption (AE) information is stored encrypted as part of CBC stream:

```
CBC encrypted data = ae salt (32 bytes), plain text data padded, ae hmac of plain text data padded (32 bytes)
```

If `-a` option is used  *CBC encrypted data* does not contain AE data.
