2019

# CSMan

<!--- tags: linux encryption -->

**CSMan** is a *bash* script around `cryptsetup` for Ubuntu.

<div id='toc'></div>

## Introduction

CSMan enables using `cryptsetup` conveniently to encrypt disk file containers or disk data partitions. CSMan cannot be used (out of the box) to encrypt live partitions. The follow are some of the hard-coded settings of the script:

* Uses `cryptsetup` in *plain* mode with 512 byte keys (`-s 512 -h sha512`).
* Supports only [EXT4](https://en.wikipedia.org/wiki/Ext4) volumes.
* Uses two nested *dm-crypt* mappers: (outer) *aes-xts-plain64* and (inner) *twofish-cbc-essiv:sha256*.
* Mounts container accessible for current user under: `$HOME/mnt/csm-*`.

### How it Works

CSMan uses randomly generated 512 byte binary keys (called **secret**) to with `cryptsetup` *plain* mode containers. The 512 byte passwords are stored in **secret files** encrypted with *AES* and protected with a user password (called **password**). The file encryption password is hashed using `argon2` before passed to AES tools (which do also their own hashing). To open a container both the secret file and password must be known. Similar to LUKS, one can use same password safely to protect more than one secret file, or protect same secret in different files with different passwords (AES used is in CBC (`aes`) or CFB (`ccrypt`) mode, so using same password on same on different files containing same secret, leads to different binary files). On difference from LUKS, user is responsible to store secret files separately from containers (maybe in another container).

### Terminology

Some overlapping terms explained:

* **secret** - randomly generated (or user specified) 512 bytes (binary). Binary values are shown as *base64*. Secret is used as `cryptsetup` password.
* **secret file** - file where *secret* is stored encrypted.
* **password** - user password used to encrypt *secret file*.
* **key file** - user password can contain additionally to the paraphrase one or more optional key files. Their header bytes hashed content is added to the password. Order of specifying key files does not matter, but they have to be exact same files used during encryption and decryption.
* **session** - optional state stored as part of current user session. There is by default no session, but it is possible to store passwords in named encrypted session slots in *tmpfs* and refer to them from there.
* **session password** - an optional password used to protect contents stored in *session*.

## Installation

Download repository files and copy as *root* under `/usr/local/bin` the following files:

* `csman.sh` - main tool.
* `cskey.sh` - is invoked by `csman.sh` for handling encryption and decryption of keys.
* `aes` - a compiled copy of my [aes](#r/cpp-aes-tool.md) tool. If this tool is found next to `cskey.sh` it is used. Alternately you can install `ccrypt` from Ubuntu repositories. 
* `argon2` - this is a self-compiled copy of `argon2` from [official](https://github.com/P-H-C/phc-winner-argon2) repository ([my copy](https://github.com/madebits/phc-winner-argon2)). `argon2` can be found also in Ubuntu repositories. If found next to `cskey.sh`, this copy is used in place of the system copy.

Every time `csman.sh` starts, it prints prefix hashes of these files if present:

```
1233e72ca  /usr/local/bin/csman.sh
a479365e9  /usr/local/bin/cskey.sh
37d86519f  /usr/local/bin/aes
8d79a5339  /usr/local/bin/argon2
```

These hashes should normally not change unless a new version of files is copied and can be ignored.

## Usage

> `csman.sh` and `cskey.sh` should be run always with `sudo`. 

`csman.sh` is the main command to use. `csman.sh` delegates password and secret operations to `cskey.sh` (which uses `aes` and `argon2`). You may need to use `cskey.sh` directly for advanced key manipulation. Running both commands without options lists their command-line arguments, e.g.: 

```
sudo csman.sh
sudo cskey.sh
```

The command-line arguments are a bit *peculiar* (because I thought that it is faster to specify options after the main arguments) and follow the scheme: *command file(s) options*.

### Secret Files

`csman.sh` creates and uses random read *secret files* using `cskey.sh`. Secret files are binary. Use `base64` tool as needed to convert them to text.

It is not required to use `cskey.sh` directly most of the time, but knowing how to use it as shown in this section will make the later `csman.sh` commands clear.

#### Using URandom

`cskey.sh` uses by default `/dev/urandom` to generate 480 bytes and `/dev/random` to generate 32 bytes of the total 512 secret bytes. 

Using `-su` option when generating secrets uses only `/dev/urandom` which [faster](https://security.stackexchange.com/questions/3936/is-a-rand-from-dev-urandom-secure-for-a-login-key) and [better](https://www.2uo.de/myths-about-urandom/). 

For all other operations where random data are needed `cskey.sh` uses `/dev/urandom`.  

#### Creating Secret Files

To create a new *secret file*:

```bash
sudo cskey.sh enc secret.bin -su
```

This command will generate a random secret and encrypt it with the password (combined with any key files) and store it as *secret.bin* file. You will be asked for: 

* `sudo` password
* for any key files to use. Key files can be specified in any order as paths one by one by pressing *Enter* key to confirm them. Use *Enter* key without a path to stop entering key files, or if you are not using key files press *Enter* key to skip entry (or use `-k` option not to be asked for key files). 
* password to encrypt the secret file.

To view back the used raw secret data (for fun) use:

```bash
sudo cskey.sh dec secret.bin | base64 -w 0
```

You can combine the two commands if needed to change the password (or use `csman.sh chp` command which is easier):

```bash
sudo bash -c 'secret=$(cskey.sh dec d.txt | base64 -w 0) && cskey.sh enc d.txt -s <(echo -n "$secret") -d'
```

#### Creating Multiple Secret Files

Sometimes, you may want to quickly generate a lot of secret files at once using same password using backup `-b` option:

```bash
sudo cskey.sh enc secret.bin -b 3 -bs -su
```

This generates 3 files (*secret.bin*, *secret.bin.01*, *...*, *secret.bin.03*). All these files are encrypted with same password. 

Without `-bs` option, same secret will be stored on each file (due to AES mode files will be still binary different).

With `-bs` option, a new different secret is generated for each file. `-su` makes secret generation faster by using `/dev/urandom`.

`sudo cskey.sh rnd file -rb 5` command is similar, but it generates just random files that only look like secret files.

#### Password Options

If no password input options are specified, `cskey.sh` prompts to read password from command-line (same as `-i 0` option). Using `-i 1` or `-i e` reads password from console echoed (visible). Command-line help lists other `-i` options.

The password can also be read from first line in a file using `-p passwordFile`.

##### Key Files

You are asked by default about any **key files** before entering the password. Key files are part of the password and up to 1024 first bytes are used from each key file hashed (SHA256) and appended to password. Hashed are sorted, so order of specifying key files does not matter. You can specify key files one by one, or press *Enter* key without a path to stop. If you do not want to be asked about key files use `-k` option. Key files can be specified also in command-line using one or more `-kf keyFile` options. Even if you use `kf keyFile` you will be still asked in command-line for any additional ones, unless you specify `-k`.

##### Using Sessions

It is possible to store passwords (but not key files) in a **session** for current logged user. Session makes use of named *@slots* to write and read passwords. To store a password that you are about to enter in slot `foo` use `-apo @foo` in command-line. You can specify later the stored password by using `-ap @foo`. If combined with `-k and -kf` then this means no passwords are asked (apart of optional session password).

The session is created only if you make use of it as a `tmpfs` mounted volume in `$HOME/mnt/tmpcsm`. When you shutdown the temporary volume disappears (or use `cskey.sh x` or when using `csman.sh x`). The session encrypts passwords using a session seed generated randomly in session volume (root access only). It is optional (press *Enter* key when asked to skip it), but it is recommended to also use a **session password**, which if specified is used additionally to the seed to encrypt password data. You may use different session passwords for different slots. Each slot is stored as an encrypted file in session volume. If you do not want to be asked to provide a session password specify `-aa`.

Session slots can be also create directly using:

```bash
# store a password in session slot @foo
sudo cskey.sh ses @foo
# or, overwrite @foo slot
sudo cskey.sh enc secret.bin -su -apo @foo
# use foo slot via -ap
sudo cskey.sg dec secret.bin -ap @foo | base64 -w 0
```

##### Password Hashing

It is possible to overwrite default options used for `argon2` tool using ` -h -p 8 -m 14 -t 1000 --` (note `--` in the end is required). All options have to be specified and are passed verbatim to `argon2`. The defaults used, if not specified, are shown in command-line help when you run `sudo cskey.sh`. 

If you specify `argon2` options during encrypt command (enc), you have to remember them and provide them same for decryption (dec) to work.

### Creating Containers

To create a container you need to specify container file or device, secret file and the size (create command is `create` or `n`):

```bash
sudo csman.sh n container.bin secret.bin 1M -cf -N 1000 ---
```

The `-cf ... ---` can be used to pass EXT4 options for file system creation, such as, the number of *inodes* to use `-N`, or the EXT4 volume label `-L` (see `man mkfs.ext4`).

The size to use can be only in units of M or G (for MiB, GiB, as powers of 1024).

If file exists, you be asked if you want to overwrite its data (in this case specified size will be ignored), or to just re-create the file system, or press *Enter* to abort and keep existing file data. You may choose to create only file system if file is already created with random data, or you plan to overwrite free space with zeros from within the encrypted container once mounted.

The file will be created, overwritten with random data, and formated with a new file system. You will asked to re-enter the password the first time encrypted container is opened for file-system creation.

Encrypting a device (disk partition) is similar:

```
sudo cskey /dev/sdc1 secret.bin 0G -oo
```

The size will be ignored, but has to be specified as 0G (or 0M). If non-zero `csman.sh` will assume a mistake (you wanted to create a file, but passed a device) and fail.

The `-oo` option tells `csman.sh` to only overwrite data, but do nothing else. This option is useful if you do not want to wait for overwrite to finish. In this case, only free space will be overwritten with random data, but you can run same command later without `-oo` to create the encrypted file system.

`csman.sh` invokes `cskey.sh` to process *secret.bin* file (create it, ask for password), so you can use same password input and hash options as for `cskey.sh` using `-ck ... ---`. For example:

```bash
sudo csman create /dev/sdc1 secret.bin -c -ck -ap @foo -i e -k ---
```

In this example, session password will be echoed and user password for *secret.bin* will be read from session slot *@foo*. The `-c` option clears the terminal screen after password entry (after `cskey.sh` invocation).

Apart of `cryptsetup -s 512 -h sha512` options that are hard-coded, you can pass other `cryptsetup` options via `-co ... ---` (outer layer) and `-ci ... ---` (inner layer). The `-s` option tells `csman.sh` to only use one (outer AES) encryption layer.

### Using Containers

`cryptsetup` requires names for devices and `csman.sh` follows same convention. The container names are prefixed with `csm-`. You can specify names in command and options either with `csm-` prefix, or without it. The name is used as part of mount folder. If you want to have a pre-known path to copy files consider specifying a name when opening the container using `-n name` option. If you specify no name, a random one one is generated and printed out by *open* command. 

The open command is `open` or `o`:

```
sudo csman.sh o container.bin secret.bin -ck -i e -ao @foo -k --- -n n1
```

We are passing here some options to `cskey.sh` via `-ck ... ---` and giving container a name via `-n`.

If the ETX4 volume has no label `csman.sh` will try to give it a label based on filename. You can use `-sl label` option to specify a new EXT4 volume label with open.

It is possible to open the container, but leave it unmounted by passing `-u` to open command. In this case you can use `sudo csman.sh mount name` later to mount the file system. Similarly, if a container is open and mounted `sudo csman.sh umount name` will unmount it only (but not close *dm-crypt*).

#### Open Options

There are some additional options that can be specified with open command. `-r` to mount read-only, and `-l` to keep container open live - the open command does not exit in this case, it waits for you to press twice *Enter* key to close the container. 

For these commands there are a few open command shortcuts: `o` *open*, `ol` *open ... -l* and `olr` *open ... -r -l*.

### Container Details

You can see a list of open containers using `list` or `l` command:

```bash
sudo csman.sh l
```

It will show also where containers are mounted under `%HOME/mnt/csm-name`. The folders under `%HOME/mnt/csm-*` are read / write to current logged user.

The above command also shows how much total and free space is present in each container. The `-lk` option dumps raw `cryptsetup` keys used for container. These keys can be used to raw-open the containers directly via `cryptsetup`.

### Live Resize

It is possible to increase the size of an open container file live. 

If you enlarge the container file on your own you can run `sudo csman.sh resize name` to inform `cryptsetup` and EXT4 of added size.

Alternatively, use `sudo csman.sh increase name size`. The *size* is the delta size to add in M or G (same as with create command) and not the total final size.

### Closing Containers

The open command with `-l` option will close the container if user presses twice *Enter* key.

To close a container named *n1* (*csm-n1*) use `close` or `c` command:

```bash
sudo csman.sh c n1
```

The close command will try to undo all effects of open. It can be run more than once in case something does work on first time.

To close all `csman.sh` open containers use `closeAll`, `ca` or `x`:

```bash
sudo csman.sh x
```

`csman.sh` changes timestamps of open container files to fake them. Sometimes, this may leave system time unsynchronized. Use `sudo csman.sh synctime` to fix that. To manually change timestamps of files use `sudo csman.sh touch fileOrDir time`. The time format to use is documented in command-line options.

### Changing Secret File Password

Changing the password of a secret file can be done via:

```bash
sudo csman.sh chp secret.bin -ck -i e ---
```

The `-ck` is used to pass option to `cskey.sh` to decrypt the file and `-cko` is used if needed to pass options to `cskey.sh` to encrypt the new output file.

By default, *secret.bin* is modified in place, which can be risky. To create a new copy use:

```bash
sudo csman.sh chp secret.bin new-secret.bin -ck -i e ---
```


























