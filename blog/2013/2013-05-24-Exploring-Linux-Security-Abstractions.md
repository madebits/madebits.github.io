#Exploring Linux: Security Abstractions

2013-05-24

<!--- tags: linux -->

Several security related abstractions used in a Linux desktop (Ubuntu):

* **PAM (Pluggable Authentication Modules)** - a configurable library (`libpam`) to handle Authentication acquisition, Account management, Session management, Authentication updating in applications. An application must explicitly choose to use PAM and its functions to handle the above. The application passes to `libpam` its own name string. libpam's functionality is configurable per application name via `/etc/pam.d/` files that match the application passed string. If no file matches, other is used. The configuration files specify modules (other dynamically loaded libraries) that implement the actual functionality. Such modules can be chained for a given action. The kind of actual security implementation used can be configured like this for every application that uses PAM, per system, without having to change or recompile them. PAM is only a library, there is no associated daemon process. Examples of applications that use PAM are: `sudo`, `sshd`, `passwd`, `xscreensaver`, `polkit-1`.

* **ConsoleKit** - is a dbus daemon (`console-kit-daemon`) that creates and manages user security sessions. All applications in one session share user authentication and permissions. Usually the desktop GUI (session leader process) creates one ConsoleKit session for each PAM session. Each session gets a unique cookie (`echo $XDG_SESSION_COOKIE`). ConsoleKit distinguishes between remote (inactive) and local (active that control hardware) user sessions. ConsoleKit is used by login managers, system daemons, fast user switching, and polkit agents.

* **logind (systemd-logind)** - is alternative (replacement) for ConsoleKit, part of `systemd`. Several `systemd-logind` operations are protected via `polkit` rights. It can do multi-seat management (ConsoleKit supports multi-seat not fully yet). `polkit` can be used either with `logind` or ConsoleKit. `systemd-logind` is not used currently in Ubuntu.

* **polkit (Policy Kit) (polkit-1)** is a service (`polkitd`) that facilitates checking of application specific rights centrally. Rights are called 'MECHANISMS' and those are trying to access the rights are called 'SUBJECTS'. Common usage is to extend rights of limited users to run things they have normally no access to. All configuration files are processed ordered alphabetically by full path.

	For each *application* (or dbus server object) that provides sensitive limited access operations, there are a set of application specific rights with unique dbus ids. The application is responsible to list these rights in a `*.policy` file in `/usr/share/polkit-1/actions/`. The `*.policy` file(s) must be created as part of installation process of that application with default settings. Actions are usually grouped by application.

	For each *application right* to control, there is an action defined in the `*.policy` file that specifies what kind of security operation should take place when that right is needed. Basically, whether an operation is allowed or not or if authentication is required, - for remote (inactive), or local (active) users. Action additionally annotates the application (files, meta-actions, and users) on whom the rights are being specified.

	The `*.policy` files define system-wide actions for application specific rights. They can be overwritten for specific user and groups using `/etc/polkit-1/localauthority/50-local.d/*.pkla` files. In a similar way, one should decide what users (or groups) are administrators in each system, by editing `/etc/polkit-1/localauthority.conf.d/50-localauthority.conf`. Apart of the above `*.pkla` and `*.conf` configuration files, one can define more complex access rules, using script (JavaScript bindings around the polkit dbus interfaces) in `*.rules` files found in `/etc/polkit-1/rules.d` and / or `/usr/share/polkit-1/rules.d`.

	An application that uses polkit to manage its access rights, checks for every access to such right the polkit daemon via dbus, or `libpolkit-gobject-1`, or via `pkcheck` command. A 'SUBJECT' application may also use dbus, or `libpolkit-gobject-1`, or `pkcheck` to update its UI, or ask for a password if it plans to use a privileged operation in a protected application.

	`polkitd` asks an 'authentication agent' to authenticate users. A polkit agent, such as `polkit-gnome-authentication-agent-1` manages per desktop session the user passwords. The GUI agent is not available when connected via a console (e.g., ssh) - a text one must be started manually (`pkttyagent`). Normally, a polkit authentication agent is implemented using PAM and ConsoleKit.

* **D-Bus security** - polkit and consolekit, and most of the components polkit restricts are dbus components and dbus has its own security model too. dbus security is specified as part of `/etc/dbus-1/system.d/*.conf` files for dbus server objects (policy). Usually, the dbus security policy is a general one and it can be restricted further by polkit for components that use polkit. dbus supports also **SELinux** (Security Enhanced Linux) integration, but in Ubuntu SELinux is not used by default.

* **AppArmor** - implements a kernel LSM (Linux Security Module) used to enforce arbitrary access rules on existing applications (`/sys/module/apparmor`). Linux kernel invokes LSM operations (if a LSM is set) before doing stuff, such file or network access, and can deny those operations based on LSM operation call result. AppArmor rules are defined as an application profile file in `/etc/apparmor.d/` folder. A profile can contain sub-profiles if the the application has several executables. A profile is made or access rules that can define what folders, files and other executables an application is allowed to access, modify and invoke. Folders and files are identified by full paths (wild-cards can be used). General predefined capabilities such as `net_bind_service` can also be controlled. Network access types can also be controlled. Several command-line tools help with creating default application profiles. Logs are written to `/var/log/kern.log` as 'audit' entries. AppArmor relies on `securityfs` to be mounted on `/sys/kernel/security` (`mount -t securityfs none /sys/kernel/security`). Other Linux distributions use SELinux (another LSM implementation) instead of AppArmor.

**References**

* http://www.linux-pam.org/Linux-PAM-html/Linux-PAM_SAG.html
* https://www.digitalocean.com/community/articles/how-to-use-pam-to-configure-authentication-on-an-ubuntu-12-04-vps
* http://www.linuxjournal.com/article/2120
* http://www.freedesktop.org/wiki/Software/ConsoleKit/
* http://wiki.gentoo.org/wiki/ConsoleKit
* https://wiki.archlinux.org/index.php/ConsoleKit
* http://www.freedesktop.org/wiki/Software/systemd/logind/
* http://www.freedesktop.org/wiki/Software/systemd/multiseat/
* http://www.freedesktop.org/software/polkit/docs/latest/
* https://wiki.archlinux.org/index.php/PolicyKit
* http://ubuntuforums.org/showthread.php?t=1008906
* http://www.redhat.com/magazine/003jan05/features/dbus/

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-05-25-Liberty-Manipulation-in-Gimp.md'>Liberty Manipulation in Gimp</a> <a rel='next' id='fnext' href='#blog/2013/2013-05-23-Exploring-Linux-UDEV-in-Context.md'>Exploring Linux UDEV in Context</a></ins>
