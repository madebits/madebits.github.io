#Minimal Graphical Ubuntu Install in Docker

2014-04-10

<!--- tags: linux docker -->

I created a minimal graphical [Docker](https://www.docker.io/) based Ubuntu installation based on [nuxeo blog](http://www.nuxeo.com/blog/development/2014/01/docker-containers-nuxeo-part-2-add-vnc-openbox/) instructions. You can find the final Dockerfile [here](#r/linux-docker-firefox.md).

In all Docker examples I have found, including the one above, people use a Dockerfile for configuration. I think this method can be take too long for a trial and error approach, so I decided to run the commands manually. I started fresh using Ubuntu 13.10 image from the Docker repository:
```
$ docker pull ubuntu:13.10
$ docker run -v /tmp:/host -i -t --name test1 ubuntu:13.10 /bin/bash
```

As you can see, I mapped my `/tmp` folder to be visible as /host folder in the docker container, gave the container the name test1 and start an iterative bash shell (#). Once in the container bash shell, I ran the following commands (you can write them in a shell file that you put in the `/tmp` folder and access and run it via `/host` mapped folder inside the container - or copy and paste them one by one in the terminal window):

```
locale-gen --no-purge en_US.UTF-8
LC_ALL=en_US.UTF-8
apt-get update

#fuse trick, fuse is not really needed in my case, but it not hurt to have it
apt-get -y install fuse || true
rm -rf /var/lib/dpkg/info/fuse.postinst
apt-get -y install fuse

apt-get install -y xvfb x11vnc openbox firefox
apt-get install -y nano xterm

mkdir /.vnc
# replace testpassword with your vnc password
x11vnc -storepasswd testpassword ~/.vnc/passwd

# I created this file in my /tmp folder
cp /host/startXvfb.sh /
```

`startXvfb.sh` shown above, I created in my temp folder with this content:
```
#!/bin/bash
Xvfb :1 -extension GLX -screen 0 800x600x24& DISPLAY=:1 /usr/bin/openbox-session&
x11vnc -usepw -display :1
 
exit 0
```
Once I ran these commands, I exited the container shell with exit, and committed the container state to a new image vasian/test1:
```
$ docker commit test1 vasian/test1
```
Now everything is ready to test. In one terminal tab I ran:
```
$ docker run --rm --expose 5900 -P -it --name temp1 vasian/test1 /startXvfb.sh
```
Then in another terminal tab, I ran (the shown port 49153 will change on each run):
```
$ docker port temp1 5900
0.0.0.0:49153
$ vncviewer localhost:49153
```
Use `sudo apt-get install xtightvncviewer` to install `vncviewer` in the host machine if you do not have it. Of course, you can automate the last two steps as follows:
```
vncviewer localhost:$(docker port temp1 5900 | cut -d : -f 2)
```

![](r/linux-docker-firefox/docker.png)


This is how my docker images look like:
```
$ docker images --tree
Warning: '--tree' is deprecated, it will be removed soon. See usage.
└─511136ea3c5a Virtual Size: 0 B
  └─1c7f181e78b9 Virtual Size: 0 B
    └─d0732e6ce563 Virtual Size: 182.1 MB
      └─25593492b938 Virtual Size: 192.7 MB Tags: ubuntu:13.10
        └─fc80b941d2aa Virtual Size: 486.7 MB Tags: vasian/test1:latest
```        
My `/var/lib/docker` folder size after this test is now 783 MB. To run the image detached (and be able to do more changes) use:

```
$ docker run -d --expose 5900 -P -it --name temp1 vasian/test1 /startXvfb.sh
```

I was happy with what I achieved so far, but I was not happy that the container was running as root. If you can see from the above screenshot, the xterm has a root `#` prompt, and I looked and found out that firefox was creating its temporary folder under /. To be able to have a non-root user container some more steps were needed.

I started docker on last image running bash:
```
$ docker run --expose 5900 -P -it --name work vasian/test1 /bin/bash
```

The bash runs as root `#`. There, I ran the commands below to create a user named 'user' with some password:
```
useradd -m -d /home/user user
passwd user
adduser user sudo
chsh -s /bin/bash user
```
I exited the docker container shell and saved the work container as a new image:
```
$ docker commit work vasian/test2
$ docker rm work
```
Then I ran a container with bash shell as user 'user' using the latest image (`HOME` has to be set):
```
$ docker run --expose 5900 -P -it --name work -u user -w /home/user -e "HOME=/home/user" vasian/test2 /bin/bash
```
In the container, I tried the commands of `startXvfb.sh` one by one (display `:0` should also work, but I did not try it out yet):
```
Xvfb :1 -extension GLX -screen 0 800x600x24&
DISPLAY=:1 /usr/bin/openbox-session&
x11vnc -usepw -display :1
```

`x11vnc` asked for a password and offered to save in `/home/user/.vnc/passwd`, which I did. Then I exited the container and committed it again:
```
$ docker commit work vasian/test3
$ docker rm work
```

Finally, I ran:

```
$ docker run --rm --expose 5900 -P -it --name temp1 -u user -w /home/user -e "HOME=/home/user" vasian/test3 /startXvfb.sh
```

And same as before in another terminal tab, I ran:
```
$ vncviewer localhost:$(docker port temp1 5900 | cut -d : -f 2)
```
![](blog/images/docker2.png)

As you can see from the new screenshot, the xterm is now no more for #root, but for a normal $user. Everything seems to work as expected.

`/var/lib/docker` folder after cleaning all temporary containers is now only 495MB for this setup. I could have never achieved a similar setup using so few disk space using a normal virtual machine. The container also allocates memory as needed, unlike a virtualbox vm, where I have to allocate all the memory upfront and docker runs under a vm too.


With Docker we do not have a full blow Ubuntu. We have as running only the processes we have explicitly started, in an [isolated](http://debian-handbook.info/browse/stable/sect.virtualization.html#sect.lxc) container environment, as shown by running `pstree` (from `psmisc` package) in the container `xterm`:

```
$ pstree -ap
startXvfb.sh,1 /startXvfb.sh
  |-Xvfb,7 :1 -extension GLX -screen 0 1366x768x24
  |-openbox,8 --startup /usr/lib/x86_64-linux-gnu/openbox-autostart OPENBOX
  |   `-xterm,21
  |       `-bash,25
  |           `-pstree,264 -ap
  `-x11vnc,9 -usepw -display :1
 ``` 

 This is nice to exercise building up a variety of small Linuxes :).

If we wish, we can pass arguments to the `/startXvfb.sh` bash script when started via docker run command. We can then process those arguments in our script to decide, for example, what processes to start automatically at container startup, and build up our own logic. To test that I ran again bash on the last image:

```
$ docker run -it --name work vasian/test3 /bin/bash
```
Then I edited startXvfb.sh (using `sudo nano startXvfb.sh`) to look as follows:
```
#!/bin/bash
Xvfb :1 -extension GLX -screen 0 1366x768x24& DISPLAY=:1 /usr/bin/openbox-session&

for var in "$@"
do
  eval $var &
done

x11vnc -usepw -display :1
 
exit 0
```
Saved it, exited bash, and committed the container:
```
$ docker commit work vasian/test4
```

I can start some programs at start up, by supplying them as arguments:
```
$ docker run --rm --expose 5900 -P -it --name temp1 -u user -w /home/user -e "HOME=/home/user" vasian/test4 /startXvfb.sh "DISPLAY=:1 xterm" "DISPLAY=:1 firefox"
```

When I connect via `vncviewer` these two programs are then already open in the desktop.

I put all final commands I used in a [Dockerfile](#r/linux-docker-firefox.md). This Dockerfile creates properly the image more or less same as above. I have modified `startXvfb.sh` a bit to make it more robust.

One drawback of the Dockerfile compared to the manual approach, it that despite of `build --rm=true` it creates more temporary containers in the image hierarchy (depending on the number of Dockerfile commands).

```
$ docker images --tree
└─511136ea3c5a Virtual Size: 0 B
  └─5e66087f3ffe Virtual Size: 192.5 MB
    └─4d26dd3ebc1c Virtual Size: 192.7 MB
      └─d4010efcfd86 Virtual Size: 192.7 MB
        └─99ec81b80c55 Virtual Size: 266 MB Tags: ubuntu:14.04, ubuntu:latest, ubuntu:trusty
          └─7234d4f09bda Virtual Size: 266 MB
            └─682891c832b1 Virtual Size: 267.6 MB
              └─df7d54a6fee7 Virtual Size: 267.6 MB
                └─503ad6c20169 Virtual Size: 342.2 MB
                  └─bc3000afdf76 Virtual Size: 343.7 MB
                    └─f1931c863eea Virtual Size: 343.7 MB
                      └─10805eabc9f8 Virtual Size: 344.4 MB
                        └─ebe5d1d20969 Virtual Size: 691.3 MB
                          └─46c1ddd021da Virtual Size: 691.3 MB
                            └─f7d423080a0c Virtual Size: 691.6 MB
                              └─f2b7f22ff795 Virtual Size: 691.6 MB
                                └─ea8f05253d35 Virtual Size: 691.6 MB
                                  └─5ef28b20fb52 Virtual Size: 691.6 MB
                                    └─67e16a782088 Virtual Size: 691.6 MB
                                      └─c58e99b6c013 Virtual Size: 691.6 MB
                                        └─2b977d180028 Virtual Size: 691.6 MB
                                          └─4c4eaf704373 Virtual Size: 691.6 MB
                                            └─79dd225b4826 Virtual Size: 691.6 MB
                                              └─14e8b449a04f Virtual Size: 691.6 MB
                                                └─7aca2ea23309 Virtual Size: 691.6 MB
                                                  └─e7cd997b0201 Virtual Size: 691.6 MB
                                                    └─559f24c18970 Virtual Size: 691.6 MB
                                                      └─4d5b1afe9b16 Virtual Size: 691.6 MB Tags: vasian/gui:latest
```

I showed above how the processes tree looks inside the container. Interesting is that same process tree is visible outside the container in the host machine:

```
...
  ├─sh -e /proc/self/fd/9
  │   └─docker.io -d -g /data/docker
  │       ├─sh -c /startXvfb.sh xterm firefox
  │       │   └─startXvfb.sh /startXvfb.sh xterm firefox
  │       │       ├─Xvfb :0 -auth /home/user/Xvfb-0.auth -extension GLX -screen 0 1366x768x24
  │       │       ├─openbox --startup /usr/lib/x86_64-linux-gnu/openbox-autostart OPENBOX
  │       │       ├─startXvfb.sh /startXvfb.sh xterm firefox
  │       │       │   └─xterm
  │       │       │       └─bash
  │       │       ├─startXvfb.sh /startXvfb.sh xterm firefox
  │       │       │   └─firefox
  │       │       │       └─33*[{firefox}]
  │       │       └─x11vnc -auth /home/user/Xvfb-0.auth -usepw -display :0
  │       └─8*[{docker.io}]
...
```

Here, we see the docker.io daemon in Lubuntu 14.04, running the image generated from the Dockerfile above.

Docker is still in beta. Currently, image layers tree created as shown above cannot be [flattened](http://3ofcoins.net/2013/09/22/flat-docker-images/) and there is a [limit](https://github.com/dotcloud/docker/issues/332) on how many image layers can be created on top of each other, making Docker somehow limited for a long term vm replacement toy.


<ins class='nfooter'><a id='fprev' href='#blog/2014/2014-04-18-Upgrading-Lubuntu-13.10-to-Lubuntu-14.04.md'>Upgrading Lubuntu 13.10 to Lubuntu 14.04</a> <a id='fnext' href='#blog/2014/2014-03-29-Linux-Command-Line-like-Game-Bandit.md'>Linux Command Line like Game Bandit</a></ins>
