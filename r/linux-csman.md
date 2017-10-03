2019

# CSMan

<!--- tags: linux encryption -->

**CSMan** is a *bash* script around `cryptsetup` for Ubuntu.

## Introduction

CSMan enables using `cryptsetup` conveniently to encrypt disk file containers or disk data partitions. CSMan cannot be used (out of the box) to encrypt live partitions. The follow are some of the hard-coded settings of CSMan:

* Uses `cryptsetup` in *plain* mode with 512 byte keys.
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













