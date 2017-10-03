2019

# CSMan

<!--- tags: linux encryption -->

**CSMan** is a Ubuntu *bash* script wrapper for `cryptsetup`.

<div id='toc'></div>

## Quick Start

Create a new container file (`-i e` or `-i echo` makes password entry visible):

```bash
# size can be in M (mega) or G (giga) bytes
csman.sh new container.bin -size 1M -ck -i e --

# of encrypt a non-boot partition, existing data will be lost
csman.sh new /dev/sdc1 -ck -i e --
```

Open a container, it gets a random *name* and it is mounted under `$HOME/mnt/csm-name` (or append `-name name`):

```bash
# append -exec to allow running executables from container, append -ro to mount read-only
csman.sh open container.bin -ck -i e -- -name one

# or block terminal till container is open, press Ctrl+C to close
csman.sh open container.bin -ck -i e -- -live
```

Close a container by name:

```bash
csman.sh close one

# or close all open containers
csman.sh closeAll
```

List all CSMan open containers:

```bash
csman.sh list
```

Change password:

```bash
csman.sh chp container.bin -ck -i e --
```

Backup and restore container key:

```bash
# backup: first 1024 bytes are copied to secret.bin
csman extract container.bin -s secret.bin

# optional, change password of backup
# csman.sh chp secret.bin -ck -i e --

# restore
csman embed container.bin -s secret.bin
```

## Introduction

CSMan is an opinionated bash script wrapper around `cryptsetup` to encrypt disk file containers or disk data partitions. CSMan cannot be used (out of the box) to encrypt live partitions. The following are some of the hard-coded choices of the script:

* Uses `cryptsetup` in *plain* mode with 512 byte passwords (`-s 512 -h sha512`).
* Supports only [EXT4](https://en.wikipedia.org/wiki/Ext4) volumes.
* Uses two nested *dm-crypt* mappers: (outer) *aes-xts-plain64* and (inner) *twofish-cbc-essiv:sha256*.
* Mounts container accessible for current user under: `$HOME/mnt/csm-*`.

### How it Works

CSMan uses a randomly generated 512 byte binary key (called **secret**) as password for a `cryptsetup` *plain* mode container (`-s 512 -h sha512`). The secret 512 bytes are stored in **secret files** encrypted with *AES* and protected with a user password (called **password**).

```
cryptsetup <= password <= password encrypted secret file (Argon / AES)
```

The secret file encryption password is hashed using `argon2` before passed to AES tool (which does also their own hashing). To open a container both the secret file and password must be known. By default, the secret file is embedded in the container (in a key **slot**).

```
container=slots(default 4)|encrypted data
```

Similar to LUKS, one can use same password safely to protect more than one secret file, or protect same secret in different files with different passwords. AES used to encrypt secret files is in CBC (`aes`) or CFB (`ccrypt`) mode, so using same password on same on different files containing same secret leads to different binary files. Similar to [non-detached](https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Encrypted_system_using_a_detached_LUKS_header) LUKS, user is responsible to store secret files separately from containers (maybe in another container) or have them embedded (default). Unlike LUKS headers, secret files used by CSMan (with default aes tool) look random.

### Terminology

Some overlapping terms explained:

```
1) password => sha512 => + <= optional key file headers (sha256 of: sha256 of max 1024 first bytes)
2) 32 bytes random salt | argon2 (id) =>
3) aes (PBKDF2 sha256) <= 512 bytes random secret =>
4) secret file=salt+aes encrypted secret+random pad => slot
```

* **secret** - randomly generated (or user specified) binary 512 bytes. Binary values are shown as *base64* in tool. Secret is used binary as `cryptsetup` password:
  * 256 bytes (binary) are used as password for outer *aes-xts-plain64* with 512 bits key (-s 512 -h sha512)
  * 256 bytes (binary) are used as password for inner *twofish-cbc-essiv:sha256* with 256 bit key (-s 256 -h sha512)
* **secret file** - binary file where *secret* is stored encrypted.
* **password** - user password (or pass-phrase) used to encrypt *secret file* (hashed with `argon2`).
* **key file** - user password can contain, additionally to the pass-phrase, one or more optional key files. The hashed header bytes content of key files is appended to the password. Order of specifying key files does not matter, but they have to be exact same files used during encryption and decryption. The same key file can be used more than once.
* **session** - optional state stored as part of current user session. There is by default no session, but it is possible to store passwords in named encrypted session slots in a *tmpfs* for current logged user and refer to them from there.
* **session password** - an optional password used additionally to temporary random session key to protect contents stored in *session*.
* **slot** - a 1024 byte section in the beginning of the container file where secret files can be embedded.

## Installation

Download repository files and copy as *root* under `/usr/local/bin` the following files:

* `csman.sh` - main tool.
* `cskey.sh` - is invoked by `csman.sh` for handling encryption and decryption of keys.
* `aes` - a compiled copy of my [aes](#r/cpp-aes-tool.md) tool. If this tool is found next to `cskey.sh` then it is used. Alternately, you can install `ccrypt` from Ubuntu repositories.
* `argon2` - this is a self-compiled copy of `argon2` from [official](https://github.com/P-H-C/phc-winner-argon2) repository without any changes ([my copy](https://github.com/madebits/phc-winner-argon2)). `argon2` can be found also in Ubuntu repositories. If found next to `cskey.sh`, this copy is used in place of the system copy.

When `csman.sh` is started without arguments, it prints prefix hashes of these files, if present:

```
50c9f28f5  /usr/local/bin/csman.sh
3ee208fb8  /usr/local/bin/cskey.sh
50be633f6  /usr/local/bin/aes
8d79a5339  /usr/local/bin/argon2
```

These hashes should normally be same unless a new version of files is copied.

## Usage

> `csman.sh` and `cskey.sh` should be run **always** with `sudo`. `csman.sh` will invoke `sudo` if started without it.

`csman.sh` is the main command to use. `csman.sh` delegates password and secret operations to `cskey.sh` (which uses `aes` and `argon2`). You may need to use `cskey.sh` directly for advanced key manipulation. Running both commands without options lists their command-line arguments, e.g.:

```
csman.sh
cskey.sh
```

The command-line arguments are a bit *peculiar* (because I thought that it is faster to specify options after the main arguments) and follow the scheme: *command file(s) options*.

### Secret Files

`csman.sh` creates and uses random *secret files* using `cskey.sh`. Secret files are binary. Use `base64` tool as needed to convert them to text.

Secret files are made of 32 random bytes of `argon2` salt, 512 random bytes of `cryptsetup` password encrypted, and are padded with random data to have random file lengths up to 1024 bytes. Due to encryption, the length of secret files is longer than 512 bytes, but is less than 1024.

It is not required to use `cskey.sh` directly most of the time, but knowing how to use it as shown in this section will make the `csman.sh` commands later clearer.

#### Using URandom

`cskey.sh` uses by default `/dev/urandom` to generate 480 bytes and `/dev/random` to generate 32 bytes of the total 512 secret bytes of outer layer; and 256 bytes using `/dev/urandom` for inner layer.

Using `-su` option when generating secrets uses only `/dev/urandom` which [faster](https://security.stackexchange.com/questions/3936/is-a-rand-from-dev-urandom-secure-for-a-login-key) and [better](https://www.2uo.de/myths-about-urandom/).

For all other operations where random data are needed `cskey.sh` uses `/dev/urandom`.

#### Creating Secret Files

To create a new *secret file* use:

```bash
sudo cskey.sh enc secret.bin -su
```

This command will generate a random secret and encrypt it with the password (combined with any key files) and store it as *secret.bin* file. You will be asked for:

1. `sudo` password
2. any key files to use. Key files can be specified in any order as paths one by one by pressing *Enter* key to confirm them. Use *Enter* key without a path to stop entering key files, or if you are not using key files press *Enter* key to skip entry (or use `-k` option not to be asked for key files).
3. password to encrypt the secret file. To have password visible append `-i e` option.

If `secret.bin` file exists, it will be overwritten, but not truncated. To truncate existing files append `-t` option.

To view back the used raw secret data (for the fun of it) use:

```bash
sudo cskey.sh dec secret.bin | base64 -w 0
```

You can combine the two commands if needed to change the password (or use `csman.sh chp` command which is easier):

```bash
sudo bash -c 'secret=$(cskey.sh dec secret.bin | base64 -w 0) && cskey.sh enc secret.bin -s <(echo -n "$secret")'
```

If *secret file* in *enc|dec* is specified as **?** it will read from command line.

#### Multiple Secret Files

Sometimes, you may want to quickly generate a lot of secret files at once using same password using backup `-b` option:

```bash
sudo cskey.sh enc secret.bin -b 3 -bs -su
```

This generates 4 files (*secret.bin*, *secret.bin.01*, *...*, *secret.bin.03*). All these files are encrypted with same password.

Without `-bs` option, same secret will be stored on each file (due to used AES mode files will be still binary different).

With `-bs` option, a new different secret is generated for each file. `-su` makes secret generation faster by using `/dev/urandom`.

`sudo cskey.sh rnd file -rb 5` command is similar, but it generates random files that look like secret files with no other use.

#### Password Options

If no password input options are specified, `cskey.sh` prompts to read password from command-line (same as `-i 0` option). Using `-i 1` or `-i e` reads password from console echoed (visible). Command-line help lists other `-i` options.

The password can also be read from first line in a file using `-p passwordFile`.

##### Key Files

Passwords used alone can be weak. Key files helps protect against weak passwords. You are asked by default to specify **key files** *before* entering the password.

Key files are part of the password. Up to 1024 first bytes are used from start of each key file hashed (SHA256) and appended to password string. Hashes are sorted, so order of specifying key files does not matter. Same file can used more than once. You can specify key files one by one, or press *Enter* key without a path to stop (or use *Enter* key without any key file to skip key file entering). `Tab` completion for file paths works in key file entry prompt.

If you do not want to be asked about key files use `-k` option. Key files can be specified also in command-line using one or more `-kf keyFile` options. Even if you use `-kf keyFile`, you will be still asked in command-line for any additional ones, unless you specify `-k`.

##### Sessions

It is possible to store passwords (but not key files) in a **session** for current logged user. Session makes use of named *@slots* to write and read passwords. To store a password that you are about to enter in slot `foo` use `-apo @foo` in command-line of `cskey.sh`. You can specify later the stored password by using `-ap @foo`. If combined with `-k and -kf` then no passwords are asked (apart of optional session password).

The session is created only if you make use of it as a `tmpfs` mounted volume in `$HOME/mnt/tmpcsm`. When you shutdown the system the temporary volume disappears (or use `cskey.sh x` or `csman.sh x` to clean session data). The session encrypts passwords using a session seed generated randomly in session volume (root access only). It is optional (press *Enter* key when asked to skip it), but it is recommended to also use a **session password**, which if specified, is used additionally to the seed to encrypt password data. You may use different session passwords for different slots. Each slot is stored as an encrypted file in session volume. If you do not want to be asked to provide a session password specify `-aa`.

Session slots can be also created directly using:

```bash
# store a password in session slot @foo
sudo cskey.sh ses @foo
# or, create / overwrite @foo slot
sudo cskey.sh enc secret.bin -su -apo @foo
# use foo slot via -ap
sudo cskey.sh dec secret.bin -ap @foo | base64 -w 0
```

##### Hashing

It is possible to overwrite default options used for `argon2` tool using ` -h -p 8 -m 14 -t 1000 -` (note `-` in the end is required). All options have to be specified and are passed verbatim to `argon2`. The defaults used, if not specified, are shown in command-line help when you run `sudo cskey.sh`.

If you specify `argon2` options during encrypt command (enc), you have to remember them and provide them same for decryption (dec) to work.

### Creating Containers

To create an encrypted container you need to specify the container file name (can be any) or device, the size and **secret** file (see [Creating Secret Files](#r/linux-csman.md#creating-secret-files)). Create command is `create`, or `new`, or `n`. Secret file will be created if it does not exist and by default it is also embedded into first container slot:

```bash
sudo csman.sh n container.bin -S 1M -s secret.bin -cf -T small -m 0 --
```

* The size (`-size` or `-S`) to use can be only in units of M or G (for MiB, GiB, as powers of 1024).

* Secret file is optional. If not specified, slot 1 of container is used to store secret file. If `-slots 0` then secret file is required. If specified and `-slots` > 0 then secret is written in secret file and secret file content is embedded also in slot 1 of container.
  * If secret file exists, you will be asked to reuse it or overwrite it (create it new). If secret file is `--` then per convention no secret file is used and encryption key is directly generated after hashing from password. This is ok for quick things up and now, but it is not possible to change the container password. With secret files, password change or using more than one password are possible.

* The `-cf ... --` can be used to pass EXT4 options for file system creation, such as, the number of *inodes* to use `-N 1000` (or `-T small`), or the EXT4 volume label `-L VOL1`. See `man mkfs.ext4`.

If container file exists, you be asked if you want to overwrite its data (in this case specified size will be ignored), or to just re-create the file system, or press *Enter* to abort and keep existing file data. You may choose to create only file system if file is already created with random data, or you plan to overwrite free space with zeros later from within the encrypted container once mounted.

The container file will be created, overwritten with random data, and formatted with a new EXT4 file system. You will asked to re-enter the password the first time encrypted container is opened for file-system creation.

Encrypting a device (disk partition) is similar:

```
sudo csman.sh /dev/sdc1 -oo
```

The size will be ignored, but if specified needs to be 0G (or 0M).

The `-oo` option tells `csman.sh` to only overwrite container data, but do nothing else. This option is useful if you do not want to wait for overwrite to finish. In this case, only free space will be overwritten with random data, but you can run same command later without `-oo` to create the encrypted file system. If `-oo` is used, the secret file is ignored if specified.

* `csman.sh` invokes `cskey.sh` to process *secret.bin* file (create it, ask for password), so you can use same password input and hash options as for `cskey.sh` using `-ck ... --` (or `@ ... @`). For example:

  ```bash
  sudo csman create /dev/sdc1 -s secret.bin -one -ck -ap @foo -i e -k --
  ```

  Here, session password will be echoed and user password for *secret.bin* will be read from session slot *@foo*. The `-one` option tells `csman.sh` to only use one (outer AES) encryption layer.

  As another example, we can embed the secret in slot 2 during creation (default is slot 1):

  ```bash
  sudo csman.sh create container.bin -S 1M -ck -i e -slot 2 --
  ```

Apart of `cryptsetup -s 512 -h sha512 --shared` options that are hard-coded, you can pass other `cryptsetup` options, such an offset (offset is specified in 512 byte units, e.g: `-o 2` for 1024 bytes) via `-co ... --` (outer layer) and `-ci ... --` (inner layer).

#### Embedding Secret

The `cryptsetup` options can be used if needed to embed secret file into the container. Assuming secret file is less than 1024 bytes long, the following commands create a container with offset and store secret there (more convenient commands follow, this is only an explanation):

```bash
sudo csman.sh n container.bin -S 1M -s secret.bin -cf -N 1000 -- -co -o 2 --
# to set or replace secret
dd conv=notrunc if=secret.bin of=container.bin

# to store more than one secret file use (-o 4)
# dd conv=notrunc seek=1 bs=1024 if=secret2.bin of=container.bin

# open container, container is also the secret now
sudo csman.sh o container.bin container.bin -co -o 2 --
```

The `-slots count` option is provided as convenience to create 1024 byte slots.

* If not set, it defaults to `-slots 4`. Using `-slots` overwrites `-co -o` (the number used with `-o` needs to be twice the number of slots). Use `-slots 0` if you need no slots, or if you do not want to overwrite `-co -o`. `-s0`  option is a shortcut for `-slots 0`. You need to remember `-slots` count used when container is created and use it also with open command, but you can use always same number. If slots is set bigger than `0`, then create command also embeds secret file in the first slot. If slots count is bigger than one and secret.bin.01, to secret.bin.03 files exists, they are also embedded in the other slots. Slots are not intended as a replacement for container file backups.

```bash
# these are same, but only second one embeds secret during create
sudo csman.sh n container.bin -S 1M -s secret.bin -co -o 8 --
sudo csman.sh n container.bin -S 1M -s secret.bin -slots 4

# these are also same, open
sudo csman.sh o container.bin -s secret.bin -co -o 8 --
sudo csman.sh o container.bin -s secret.bin -slots 4

# to create a secret and embed both in first two slots on create use
sudo csman.sh n container.bin -S 1M -s secret.bin -ck -b 1 -su --
# or backup key in all default 4 slots (creates or uses secret.bin, secret.bin.01, .., secret.bin.03)
sudo csman.sh n container.bin -S 1M -s secret.bin -ck -b 3 -su --
```

To extract secret file back from the container use:

```bash
dd if=container.bin of=secret.bin bs=1024 count=1

# or read secret from some other offset copy
# dd if=container.bin of=secret.bin bs=1024 count=1 skip=1
```

Two *convenience* commands (no `sudo` needed) are provided to embed (`e` or `embed`) and extract (`ex`) secret files from default 1024 byte offset slots. Default slot is 1 (byte offset 0) and can be changed via `-slot slot` option. We assume the container has been created with `-slots 4` option:

```bash
# cskey.sh enc secret.bin -b 3 -su
# embed, default -slot 1
csman e container.bin -s secret.bin
csman e container.bin -s secret.bin.01 -slot 2

# extract, will overwrite secret file if exists
csman ex container.bin -s secret.bin
csman ex container.bin -s secret.bin.01 -slot 2
```

Ideally, generate two secret files for same key using `cskey.sh`, so that they are not same. The `-s` option can be repeated for `e` command, in that case successive slots starting from the specified one are used for each secret. The `e` command is destructive, if the specified slot does not exist, the container file will be damaged.

`cskey.sh` knows to read secret from a default slot using `-slot` option, or from a byte offset using `-o` option:

```bash
# open container using slot 1
sudo csman.sh o container.bin -slots 2
sudo csman.sh o container.bin -slots 2 -ck -slot 1 --

# open container using slot 2
sudo csman.sh o container.bin -slots 2 -ck -slot 2 --
```

The `cskey.sh -slot` if not specified is 1. `cskey.sh enc` if a slot is specified pads secret to 1024 bytes using random data.

To remove a slot's data, overwrite it with random data using delete `-d` option of `e` command:

```bash
csman.sh e container.bin -d -slot 2
# or this will also do
cskey.sh rnd - -r 1024 | csman.sh e container.bin -s - -slot 2
```

If `-d` and one or more `-s` are used together for `embed` command, they operate on next slot based on order given, starting with specified `-slot`.

### Using Containers

`cryptsetup` requires names for devices and `csman.sh` follows same convention. The container names are prefixed with `csm-`. You can specify name in command and options either with `csm-` prefix, or without it. The name is used as part of mount folder. If you want to have a pre-known path to copy files consider specifying a name when opening the container using `-n name` option. If you specify no name, a random one is generated and printed out by *open* command.

The open command is `open` or `o`. Secret is specified via `-s` option, if not set it tries to read secret from container file slots:

```
sudo csman.sh o container.bin -s secret.bin -ck -i e -ao @foo -k -- -n n1
```

We are passing here some options to `cskey.sh` via `-ck ... --` and giving container a name via `-n`. The name will be `csm-n1`, mounted in `$HOME/mnt/csm-n1`.

If the ETX4 volume has no label `csman.sh` will try to give it a label based on filename. You can use `-sl label` option to specify a new EXT4 volume label with open.

It is possible to open the container, but leave it unmounted by passing `-u` to open command (e.g. if you want to `fsck` it). In this case you can use `sudo csman.sh mount name` later to mount the file system. Similarly, if a container is open and mounted `sudo csman.sh umount name` will unmount it only (but not close *dm-crypt* device).

#### Open Options

There are some additional options that can be specified with open command. `-r` to mount *read-only*, and `-l` to keep container open *live* - the open command does not exit in this case, it waits for you to press twice *Enter* key to close the container.

For these commands there are a few open command shortcuts: `o` *open*, `ol` *open ... -l* and `olr` *open ... -r -l*.

The `-e` option mounts container with `exec` option so that executable files inside can be run (default is `noexec`).

### Container Details

You can see a list of open containers using `list` or `l` command:

```bash
sudo csman.sh l
```

It will show also where containers are mounted under `%HOME/mnt/csm-name`. The folders under `%HOME/mnt/csm-*` are read / write to current logged user.

The above command also shows how much total and free space is present in each container. Adding `-lk` option dumps raw `cryptsetup` keys used for container. These keys (after `xxd -r -p > key.bin`) can be used to raw-open the containers directly via `cryptsetup --key-file=key.bin ...`.

To see a list of all devices in system use:

```bash
csman.sh d
```

### Live Resize

It is possible to increase the size of an open container file live.

If you enlarge the container file on your own you can run `sudo csman.sh resize name` to inform `cryptsetup` and EXT4 of added size.

Alternatively, use `sudo csman.sh increase name size`. The *size* is the delta size to add in *M* or *G* (same as with `create` command) and not the total final size.

### Closing Containers

The open command with `-l` option will close the container if user presses twice *Enter* key or *Ctrl+C*.

To close a container named *n1* (*csm-n1*) use `close` or `c` command:

```bash
sudo csman.sh c n1
```

The close command will try to undo all effects of open. It can be run more than once in case something does not work on first time. Any open applications accessing files in mounted volume will be killed.

To close all `csman.sh` open containers use `closeAll`, `ca`, or `x` command (the `x` command also removes session data if any):

```bash
sudo csman.sh x
```

`csman.sh` changes timestamps of open container files to fake them. Sometimes, this may leave system time unsynchronized. Use `sudo csman.sh synctime` to fix that. To manually change timestamps of files use `sudo csman.sh touch fileOrDir time`. The time format to use is documented in command-line options.

### Changing Password

Changing the password of a secret file can be done via:

```bash
# old file is left as is, a new file is created
sudo csman.sh chp secret.bin -out new-secret.bin -ck -i e --
```

* If `-out` is not specified *secret.bin* is modified in place.
* The `-ck ... --` is used to pass option to `cskey.sh` to decrypt the file and `-cko .. --` is used (if needed) to pass options to `cskey.sh` to encrypt the new output file.
* If `-cko` is not specified, then same `-ck` options are used also for encryption.

If you have more than one secret file using same password, you can make use of sessions to change password of several files at once unattended. I assume here there are no key files used (if key files are used, pass them using `-kf keyfile`):

```bash
# save old pass in session
sudo cskey.sh ses @old -i e -aa -k
# save new pass in session
sudo cskey.sh ses @new -i e -aa -k

# go over all key files and replace pass
sudo bash -c 'for f in *.bin; do csman.sh chp "${f}" -out "$new-{f}" -ck -ap @old -aa -k -- -cko -ap @new -aa -k --; done'

# remove session data explicitly
sudo cskey.sh x
```

If you have an existing secret file and want to replicate it for use with container slots, you can use this command:

```bash
sudo csman.sh chp secret.bin -out new-secret.bin -ck -i e -- -cko -i e -b 3 --
# or if secret is in some container slot use
sudo csman.sh chp container.bin -out new-secret.bin -ck -i e -slot 1 -- -cko -i e -b 3 --
# slots can then be replaced one by one with embed command
csman.sh e container.bin -s new-secret.bin -slot 2
# or all at once, replaces slots 1,2,3,4
csman.sh e container.bin -s new-secret.bin -s new-secret.bin.01 -s new-secret.bin.02 -s new-secret.bin.03 -slot 1
```

The following command changes the password of a slot in place:

```bash
sudo csman.sh chp container.bin -ck -slot 1 -- -out container.bin -cko -slot 1 --
# put same container secret of slot 1, in slot 2 using maybe a different or same pass
sudo csman.sh chp container.bin -ck -slot 1 -- -out container.bin -cko -slot 2 --
```

## File Tools

> These commands are intended to be run **without** `sudo`.

### List Disk Volumes

List disk volumes and block devices (no `sudo` is needed):

```bash
csman.sh disks
# same
csman.sh disk
csman.sh d
```

### Copy Folders

Two copy commands are provided to copy directories. First uses `tar` and `pv` and second invokes `rsync` with some parameters to improve progress reporting (and removes training slashes from input directories) (no `sudo` is needed):

```bash
# faster
csman.sh cp src dst
# a bit slower, but can be resumed
csman.sh rsync src dst
```

### Clean Disk Space

It is possible to overwrite free disk partition space using a directory in that partition using (no `sudo` is needed):

```bash
csman.sh dc .
# to start directly without reading information
# use any of these:
csman.sh dc . -q
# default current folder .
csman.sh dcq
```

The `dc` command is useful to overwrite disk space from *within* an encrypted container. The command creates a temporary folder `csm-zero-tmp` under the folder given as its first argument, where it writes `zero.*` files filled with `/dev/zero` till that disk partition runs out of free  disk space. If the command ever fails to clean the temporary `csm-zero-tmp` folder, it can be removed manually using `rm -rf csm-zero-tmp`.
