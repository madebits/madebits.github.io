#Docker Machine On Windows

2017-06-14

<!--- tags: virtualization docker -->

[Docker Machine](https://docs.docker.com/machine/overview/) offers a way to run Docker under a virtual machine (VM) in Windows. For more control, you can always create a Linux virtual machine with `docker` on your own and use it without Docker Machine. Docker Machine makes some things easier (such as, setting up a host-only network in VirtualBox), and is a handy tool to use with different drivers.

To [install](https://docs.docker.com/machine/install-machine/) Docker Machine in Windows is easy, assuming you have Git with Git bash and VirtualBox (5+) already installed. [Installation](https://docs.docker.com/machine/install-machine/) documentation lists the following command: 

```
$ if [[ ! -d "$HOME/bin" ]]; then mkdir -p "$HOME/bin"; fi && \
curl -L https://github.com/docker/machine/releases/download/v0.12.0/docker-machine-Windows-x86_64.exe > "$HOME/bin/docker-machine.exe" && \
chmod +x "$HOME/bin/docker-machine.exe"
```

This command will download and install Docker Machine in `$HOME/bin` folder (`$HOME` is by default, your Windows user folder: `%HOMEPATH%`). You may want to append `$HOME/bin` to `$PATH`. If you have Windows firewall active, allow network access to `docker-machine.exe`.

Docker Machine keeps its data files under `$HOME/.docker` folder. The files location can be [changed](https://stackoverflow.com/questions/33933107/change-docker-machine-location-windows) via `MACHINE_STORAGE_PATH` environment variable. The parent folder of $HOME (i.e., `C:\Users`) is shared read/write in VM as `/c/Users`. In theory, this folder could be used with persistent `docker -v` volumes, but due to `vboxsf` issues not all software may work with it. To disable automatic bug reports run:

```
mkdir -p ~/.docker/machine && touch ~/.docker/machine/no-error-report
```

After installation, to create Docker Engine VM, use:

```
$ docker-machine create --driver virtualbox default
```

This will create a VM named `default` with default parameters (~20GB dynamic disk and 1GB RAM) based on [boot2docker](https://stackoverflow.com/questions/28733940/how-to-install-nano-on-boot2docker) image. Check [documentation](https://docs.docker.com/machine/drivers/virtualbox/) to fine-tune disk size and other VM [parameters](https://github.com/docker/machine/blob/8f82b762749bb8dcf52c6dd0774b927510c5e885/docs/reference/create.md). Several Docker Machine commands expect `default` as default VM name, so it is good idea to keep it like that.

For `docker-machine` to be able to communicate with the VM, some environment variables have to be set (they can be unset using `docker-machine env -u`).

```
$ docker-machine env default
$ eval $("docker-machine" env default)
```

Once the environment is setup, we can check VM is there:

```
$ docker-machine ls
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS
default   *        virtualbox   Running   tcp://192.168.99.100:2376           v17.05.0-ce

$ docker-machine ip
192.168.99.100
```

To connect to VM shell and use `docker` we can `ssh` to it using:

```
$ docker-machine ssh
```

Given Docker Machine `ssh` command supports `ssh` arguments, we can directly run `docker` commands. It is useful to define a bash *alias* (assuming `$HOME/bin` is part of `$PATH`):

```
$ alias docker='docker-machine ssh default docker'
```

This alias will work with most commands (apart of `docker exec -it some-container bash` and some others), and we can use it directly from Git bash:

```
$ docker --version
Docker version 17.05.0-ce, build 89658be
```

When done with `docker`, we can stop VM using (`docker-machine` will list all [available](https://docs.docker.com/machine/reference/) commands):

```
$ docker-machine stop
```

A common case for `docker` containers is to be able to access some service from outside of Docker Engine VM in Windows host ([port forwarding](https://stackoverflow.com/questions/36286305/how-do-i-forward-a-docker-machine-port-to-my-host-port-on-osx) in VM is needed to access ports outside the host or as `localhost`). Host-only access is already handled by VM (given VM is accessible in the host), as the following [example](https://docs.docker.com/machine/get-started/#run-containers-and-experiment-with-machine-commands) from documentation shows:

```
$ docker run -d -p 8000:80 nginx
$ curl $(docker-machine ip):8000
```

Docker machine mounts root `/` folder as `tmpfs` and the VM hard disk is in `/mnt/sda1/`. To keep permanent data in VM disk outside container store them at `/mnt/sda1/`.

```
docker@default:~$ mount
tmpfs on / type tmpfs (rw,relatime,size=917692k)
...
/dev/sda1 on /mnt/sda1 type ext4 (rw,relatime,data=ordered)  
...
c/Users on /c/Users type vboxsf (rw,nodev,relatime)
...                                                    
```

As another example, we can access the RabbitMQ web [management plugin](https://docs.docker.com/samples/rabbitmq/#management-plugin) from host as `http://192.168.99.100:15672` [using](https://hub.docker.com/r/library/rabbitmq/tags/) default *guest / guest* credentials:

```
$ docker pull rabbitmq:management
$ docker run --restart always -d --hostname my-rabbit -p 5672:5672 -p 15672:15672 -v /mnt/sda1/data/rabbitmq:/var/lib/rabbitmq/mnesia/rabbit\@my-rabbit --name my-rabbit rabbitmq:management

$ docker-machine ip
192.168.99.100
```

A last example, we can run MongoDB as follows:

```
$ sudo mkdir -p /mnt/sda1/data/mongo/
$ sudo touch /mnt/sda1/data/mongo/m.conf
$ docker run --restart always -d -p 27017:27017 -v /mnt/sda1/data/mongo:/data/db --name my-mongo mongo -f /data/db/m.conf
```

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2017/2017-08-10-Product-Definition-Life-Cycle.md'>Product Definition Life Cycle</a> <a rel='next' id='fnext' href='#blog/2017/2017-05-16-The-New-Docker.md'>The New Docker</a></ins>
