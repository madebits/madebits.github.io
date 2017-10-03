2019

#CSMan

<!--- tags: linux -->

**CSMan** is a *bash* script around `cryptsetup` for Ubuntu.

## Introduction

CSMan enables using `cryptsetup` conveniently to encrypt disk file containers or disk data partitions. CSMan cannot be used to encrypt live partitions. The follow are some of hard-coded settings on CSMan:

* Uses `cryptsetup` in *plain* mode with 512 bit keys.
* Supports only *EXT4* volumes.
* Uses two nested *dm-crypt* mappers: *aes-xts-plain64* and *twofish-cbc-essiv:sha256*.
* Mounts for current user under `$HOME/mnt/cms-*`.

## Installation

Download repository files and copy as *root* under `/usr/local/bin` the following files:

* `csman.sh` - main tool.
* `cskey.sh` - invoked by `csman.sh` for handling encryption keys.
* `aes` - a compiled copy of my [aes](#r/cpp-aes-tool.md) tool. If this tool is found next to `cskey.sh` it is used. Alternately you can install `ccrypt` from Ubuntu repositories. 
* `argon2` - this is a own compiled copy of `argon2` from [official](https://github.com/P-H-C/phc-winner-argon2) repository ([my copy](https://github.com/madebits/phc-winner-argon2)). `argon2` can be found also in Ubuntu repositories. If this file is found next to `cskey.sh` this copy is used in place of the system copy.

## Usage

`csman.sh` and `cskey.sh` should be run always with `sudo`. 

`csman.sh` is the main command to use. `csman.sh` delegates password and key operations to `cskey.sh`. You may need to use `cskey.sh` directly for advanced key manipulation. Running both commands without options lists their command-line arguments, e.g.: `sudo csman.sh` or `sudo cskey.sh`.

The command-line argument of these tools are a bit *peculiar* because I thought that it is faster to specify options after the main arguments. The command-line arguments follow therefore this general scheme: *command file(s) options*.












