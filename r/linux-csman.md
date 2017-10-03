2019

#CSMan

<!--- tags: linux -->

**CSMan** is a *bash* script around `cryptsetup` for Ubuntu.

## Installation

Download repository files and copy as root under `/usr/local/bin` the following files:

* `csman.sh` - main tool.
* `cskey.sh` - invoked by `csman.sh` for handling encryption keys.
* `aes` - a compiled copy of my [aes](#r/cpp-aes-tool.md) tool. If this tool if found next `cskey.sh` it is used. Alternately you can install `ccrypt` from Ubuntu repositories. 
* `argon2` - this is a own compiled copy of `argon2` from [official](https://github.com/P-H-C/phc-winner-argon2) repository ([my copy](https://github.com/madebits/phc-winner-argon2)). `argon2` can be found also in Ubuntu repositories. If this file is found next to `cskey.sh` this copy is used in place of the system copy.

## Usage

`csman.sh` and `cskey.sh` should be run always with `sudo`. 


