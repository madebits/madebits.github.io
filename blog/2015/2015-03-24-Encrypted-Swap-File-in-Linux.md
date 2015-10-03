#Encrypted Swap File in Linux

2015-03-24

<!--- tags: encryption -->

To create an encrypted swap file in Linux, I followed the steps in [askubuntu](http://askubuntu.com/questions/248158/how-do-i-setup-an-encrypted-swap-file) and in [microhowto](http://www.microhowto.info/howto/create_an_encrypted_swap_area.html).

0. Install cryptsetup, on Ubuntu:

	```
	sudo apt-get install cryptsetup
	```
1. Create as root a file to keep the swap, you can use any size, location and filename (`/cryptswap`):

	```
	sudo truncate -s 4GiB /cryptswap
	sudo chmod 600 /cryptswap
	```

2. Edit `/etc/crypttab` and add this line:

	```
	cryptswap /cryptswap /dev/urandom swap
	```

	First column `cryptswap` is the name of mapped device (it can be any), the above file path, the password to use `/dev/urandom`, and `swap` runs `mkswap` on the mapped crypto device). Using `/dev/urandom` as password is secure enough, but it will not work with hibernation. If you want to support hibernation, use `none` in place of `/dev/urandom` and you will be asked at [startup](http://manpages.ubuntu.com/manpages/natty/man5/crypttab.5.html) for a password (if not figure out another way to pass the password via some file or key). A safer setting for swap options could be: `swap,cipher=aes-xts-plain64,size=512`.
3. Edit `/etc/fstab` and adding the following line (using the name of the mapped device above):

	```
	/dev/mapper/cryptswap none swap defaults 0 0
	```

	Sometimes, the swap may not be mounted on time during boot. Given that swap presence is not critical to very start of the system, if that happens, try adding `nobootwait` option in `/etc/fstab`:

	```
	/dev/mapper/cryptswap none swap sw,nobootwait 0 0
	```

	`/etc/fstab` approach may [not](https://unix.stackexchange.com/questions/64693/how-do-i-configure-systemd-to-activate-an-encrypted-swap-file) work all the time on systems that use `systemd` and you may get up and now an error `Failed to activate with key file '/dev/urandom': Operation not supported` and asked for a password during boot. `systemd` will generate a `dev-mapper-cryptswap.swap` file that will be required by `swap.target` dependent on `systemd-cryptsetup@cryptswap.service`. `dev-mapper-cryptswap.swap` will call `/sbin/swapon -o sw,nobootwait /dev/mapper/cryptswap`. The `-o` will ignore `nobootwait` as it is not a `swapon` option. The `systemd` generated file for `systemd-cryptsetup@cryptswap.service` does not detect the dependency on `/dev/urandom` properly. The [correct](https://lists.fedoraproject.org/pipermail/devel/2012-January/160917.html) way to solve this would be to create a custom `/etc/udev/rules.d/99-myrules.rules` file with the following content `KERNEL=="urandom", TAG+="systemd"`, and then add `dev-urandom.device` as dependency to `systemd-cryptsetup@cryptswap.service`.

	```
	sudo systemtctl edit systemd-cryptsetup@cryptswap.service
	``` 
	
	And add to the file:

	```
	[Unit]
	Wants=dev-urandom.device
	After=dev-urandom.device
	```

Restart the machine and verify the swap is active using `cat /proc/swaps` (`/dev/mapper/cryptswap` is linked to the `/dev` filename listed by `cat` command). Crypto settings used can be verified with `sudo cryptsetup status cryptswap`.



<ins class='nfooter'><a id='fprev' href='#blog/2015/2015-04-14-Evince-Fit-Keyboard-Shortcuts.md'>Evince Fit Keyboard Shortcuts</a> <a id='fnext' href='#blog/2015/2015-03-22-Installing-R-and-RStudio-in-Ubuntu-14.04.md'>Installing R and RStudio in Ubuntu 14.04</a></ins>
