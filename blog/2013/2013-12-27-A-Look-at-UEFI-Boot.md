#A Look at UEFI Boot

2013-12-27 

Almost all new general purpose computers are starting to come with [UEFI](http://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface) instead of the old BIOS, so I decided to have a look at UEFI benefits and drawbacks for myself.

Unified Extensible Firmware Interface (UEFI) is hardware-specific logic that provides the first set of instructions that run during the [boot process](http://technet.microsoft.com/en-us/library/hh825095.aspx). UEFI is designed to allow only trusted components to run, this includes operating system loaders and hardware drivers.

UEFI detects allowed software based on public-key cryptography signatures. There is no central trusted authority for certificates, instead the keys must be put in the UEFI firmware by the OEM, or in theory by the user using some special interface. It is not possible for normal software to manipulate UEFI keys database. UEFI relies on Trusted Platform Module [TPM](http://technet.microsoft.com/library/jj131725.aspx), a hardware-based, security-related functions.

In order to run Window 8 in a UEFI machine, the public key part of the RSA key used by Microsoft to sign the Windows 8 files must be in the UEFI key database of the machine. UEFI has a also a Platform Key that controls who can add the keys. So Microsoft has to give its public RSA key part to each OEM vendor and ask them to add it UEFI key store before the machine is sold. Only a big software vendor, such as Microsoft, has the means to achieve that. Other OS providers should either forget about UEFI, or ask Microsoft to sign their files with Microsoft's private key part. This sound to me like regress for open generic purpose computing machines.


[Benefits](http://technet.microsoft.com/library/jj131725.aspx) of using UEFI:

* Only signed software can run. This includes OS and hardware drivers (secure boot). Most of pre-Windows 8 hardware drivers will not work with secure boot enabled.
* UEFI supports GUID Partition Table (GPT), that removes the current hard-disk size limitations (> 2TB partitions, etc). Some of existing hard-disk partitioning tools may not work with GPT as of now. It has to be mentioned that GPT does not necessary needs EFI, but Microsoft software [cannot](http://woshub.com/booting-windows-7-from-a-gpt-disk-using-bios-firmware-non-uefi/) boot on GPT disks without UEFI - this seems a deliberate decision to promote UEFI.
* Boot time is faster, given no traditional software boot loader needs to run. A separate signed boot loader can be used, or UEFI firmware in combination with newer CPUs can directly boot OSes that support it. A separate UEFI partition (instead of the old MBR) is needed to make this work.

Drawbacks of using UEFI:

* No more control over own hardware. In theory, users can add or replace the UEFI [keys](http://blog.hansenpartnership.com/the-meaning-of-all-the-uefi-keys/). The procedure to do so is not provided out of the box by most UEFI implementations. External tools should be used and there no warranty they will work as intended with all OEM hardware. Existing tools are also hard to use.
* Users have no more control over their software. In theory again, users that control own UEFI keys should be able to verify the signature of any software they own and also replace the software signature with one based on their own keys. This means when I buy a copy of Windows 8, I can verify its signature and replace it with my own one corresponding to one or my own UEFI keys. In practice, this is hard to impossible to achieve (Microsoft even [forbids](http://technet.microsoft.com/library/jj131725.aspx) OEMs from doing that).
* Users give up their right to control hardware and software and accept a parenting approach, where they can only run software OEM and major players support. So we are moving to trust model for both hardware and software. When it comes to security, trust - no matter on whom - is something to be avoided.
* UEFI firmware is bigger that the old legacy bios. The chances it has bugs, or that its state cannot be recovered once you manipulate its keys on your own is higher than that of legacy bios. Users run into the risk of corrupting their UEFI hardware in such ways, that OEM support will be required to repair.
* Power users and independent software development companies can no more offer own software alternatives to run on other people machines. This becomes too complex with UEFI.
* UEFI machines in combination with TPM keep a history of failed attempts, and enable remote control for support completely outside the user control. Anti-virus software can read the TPM data and remotely check them for [validity](http://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface). Some remote authority can know more about your machine than you can.
* UEFI needs an EFI partition. For SSD drives, there is no benefit in having such partition, or using GPT either. Most OEMs put a recovery partition before EFI one when they install Windows. This means even if you want to delete such partitions, you cannot easy reclaim that part of hard-disk space. Furthermore some OEM require a EFI partition for their UEFI to work, as they store firmware files there.
* Windows Preinstallation Environment (Windows PE) in combination with UEFI will store OEM Window 8 activation key in firmware. It cannot be reused in other machines. You buy a machine and pay for the cost of Windows 8 too. Then you cannot use that Windows 8 license to another machine. You repay for Windows 8 per each machine you buy.
* UEFI and TPM are complex to explain and to implement for OEMs and users. Microsoft is using this complexity to push UEFI related implementations on both hardware and software into the direction of their agenda - whatever that one is. For example, while only the boot loader should be signed as a minimum for UEFI, Microsoft is forcing Linux vendors to also sign the kernel. They can do this, as the Linux vendors need Microsoft key to sign their files.

As summary, I see no benefit on using UEFI for any of my machines. If I you cannot avoid getting a machine without UEFI then (a) first create a recovery media for it (you never know what will happen), and then (b) disable UEFI and re-install the software (deleting all existing partitions) in legacy mode.

<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-12-29-Updating-my-Laptop-to-a-SSD.md'>Updating my Laptop to a SSD</a> <a id='fnext' href='#blog/2013/2013-12-03-Script-to-Download-Bing-Image.md'>Script to Download Bing Image</a></ins>
