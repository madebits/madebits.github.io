2019

# CSMan

<!--- tags: linux encryption -->

**CSMan** is a *bash* script around `cryptsetup` for Ubuntu.

<div id='toc'></div>

## Introduction

CSMan enables using `cryptsetup` conveniently to encrypt disk file containers or disk data partitions. CSMan cannot be used (out of the box) to encrypt live partitions. The follow are some of the hard-coded settings of CSMan:

* Uses `cryptsetup` in *plain* mode with 512 byte keys (`-s 512 -h sha512`).
* Supports only [EXT4](https://en.wikipedia.org/wiki/Ext4) volumes.
* Uses two nested *dm-crypt* mappers: *aes-xts-plain64* and *twofish-cbc-essiv:sha256*.
* Mounts for current user under: `$HOME/mnt/csm-*`.

### How it Works

CSMan use randomly generated 512 byte passwords (called **secret** in CSMan documentation) to with `cryptsetup` *plain* mode containers. The 512 byte passwords are stored in **secret files** encrypted with *AES* and protected with a user password (called **password** in CSMan documentation). The file encryption password is hashed using `argon2` before passed to AES tools (which do also their own hashing). To open a container both the secret file and password must be known. Similar to LUKS, one can use same password to protect more than one secret file, or protect secret in different files with different passwords (AES used is in CBC (`aes`) or CFB (`ccrypt`) mode, so using same password on same on different files containing same secret, leads to different binary files). On difference from LUKS, user is responsible to store secret files separately from containers (maybe in another container).

### Terminology

Some overlapping terms are used more that once:

* **secret** - randomly generated (or user specified) 512 bytes (binary). Binary values are shown as *base64*.
* **secret file** - file where secret is stored encrypted.
* **password** - user password used to encrypt secret file.
* **key file** - user password can contain additionally to a paraphrase one or more optional key files. Their header hashed content is added to the password. Order of specifying key files does not matter, but they have to be same files.
* **session** - optional state stored as part of user session. There is by default no session, but it is possible to store passwords in named encrypted session slots in *tmpfs* and refer to them from there.
* **session password** - an optional password used to protect contents stored in session.

## Installation

Download repository files and copy as *root* under `/usr/local/bin` the following files:

* `csman.sh` - main tool.
* `cskey.sh` - invoked by `csman.sh` for handling encryption keys.
* `aes` - a compiled copy of my [aes](#r/cpp-aes-tool.md) tool. If this tool is found next to `cskey.sh` it is used. Alternately you can install `ccrypt` from Ubuntu repositories. 
* `argon2` - this is a self-compiled copy of `argon2` from [official](https://github.com/P-H-C/phc-winner-argon2) repository ([my copy](https://github.com/madebits/phc-winner-argon2)). `argon2` can be found also in Ubuntu repositories. If found next to `cskey.sh`, this copy is used in place of the system copy.

## Usage

> `csman.sh` and `cskey.sh` should be run always with `sudo`. 

`csman.sh` is the main command to use. `csman.sh` delegates password and key operations to `cskey.sh` (which uses `aes` and `argon2`). You may need to use `cskey.sh` directly for advanced key manipulation. Running both commands without options lists their command-line arguments, e.g.: `sudo csman.sh` or `sudo cskey.sh`.

The command-line arguments of these tools are a bit *peculiar* (because I thought that it is faster to specify options after the main arguments). The command-line arguments follow the scheme: *command file(s) options*.

### Secret Files (cskey.sh)

`csman.sh` creates and uses random read secret files using `cskey.sh`. It is not required to use `cskey.sh` directly, but knowing how to use it directly as shown in this section will make the later `csman.sh` commands clear.

#### Using /dev/urandom (-su)

`cskey.sh` uses by default `/dev/urandom` to generate 480 bytes and `/dev/random` to generate 32 bytes of the total 512 secret bytes. Using `-su` option when generating secrets uses only `/dev/urandom` which [faster](https://security.stackexchange.com/questions/3936/is-a-rand-from-dev-urandom-secure-for-a-login-key) and [better](https://www.2uo.de/myths-about-urandom/). For all other operations where random data are needed `cskey.sh` uses `/dev/urandom`.  Secret files are binary. Use `base64` tool as needed to convert them to text.

#### Creating Secret Files (enc | dec)

To create a new secret file:

```bash
sudo cskey.sh enc secret.bin
```

You will be asked for: a) `sudo` password, b) for any key files to use (key files can be specified as paths one by one by pressing Enter, use Enter without a path to stop entering of key files - if you are not using key files, just press Enter key), c) password to encrypt the secret file.

To get back the raw secret data use:

```bash
sudo cskey.sh dec secret.bin | base64 -w 0
```

This means you can combine the two commands if needed as shown to change password (or use `csman.sh chp` command which is easier):

```bash
sudo bash -c 'secret=$(cskey.sh dec d.txt | base64 -w 0) && cskey.sh enc d.txt -s <(echo -n "$secret") -d'
```

Sometimes, you may want to quickly generate a lot of secret files at once using same password using backup `-b` option:

```bash
sudo cskey.sh enc secret.bin -b 5 -bs -su
```

This generates 6 files (*secret.bin*, *secret.bin.01*, *...*, *secret.bin.06*). All these files are encrypted with same password. Without `-bs` same secret will be stored on each file (due to AES mode files will be still binary different). With `-bs` a new different secret is generated for each file. `-su` makes secret generation faster by using `/dev/urandom`.

`sudo cskey.sh rnd file -rb 5` command is similar, but it generates just random files that only look like secret files.

#### Password Input Options

If no password input options are specified, `cskey.sh` prompts to read password from command-line, this is same as `-i 0` option. Using `-i 1` or `-i e` read password from console echoed (visible). Command-line help lists other `-i` options.

The password can also be read from first line in a file using `-p passwordFile`.

You are asked by default about any **key files**, and specify them one by one, or press Enter without a path to stop. If you do not want to be asked about key files use `-k` option. Key files can be specified also in command-line using one or more `-kf keyFile` options. Even if you use `kf keyFile` you will be still asked in command-line for any more, unless you specify `-k`. Up to 1024 first bytes are used from each key file hashed (SHA256) and appended to password.

It is possible to store passwords in a **session** for current logged user.  Session make use of name *@slots* to write and read passwords. To store the password you will input is slot `foo` use `-apo @foo`. You specifiy later same password by using `-ap @foo`. If combined with `-k and -kf` then this means no passwords are asked (apart of session password).

The session is created only if you make use of it as a `tmpfs` mounted volume in `$HOME/mnt/tmpcsm`. When you shutdown the temporary volume disappears (or use `cskey.sh x` or when using `csman.sh x`). The session encrypts passwords using a session seed generated randomly in session volume. It is optional, but it is recommended to also use a **session password**, which if specified is used additionally to seed to encrypt password data. You may use different session passwords for different slot. Each slot is an encrypted file in session volume. If you do not want to be asked to provide a session password specify `-aa`.

Session slots can be also create directly using:

```bash
sudo cskey.sh ses @foo
```

#### Password Hash Options

It is possible to overwrite default options used for `argon2` tool using ` -h -p 8 -m 14 -t 1000 --` (note `--` in the end is required). All options have to be specified and are passed verbatim to `argon2`. The defaults used if not specified are shown in command-line help when you run `sudo cskey.sh`. If you specify `argon2` options during encrypt (enc), you have to remember them and provide them same for decryption (dec) to work.
























