#Docker Machine On Windows

2017-06-14

<!--- tags: virtualization -->

[Docker Machine](https://docs.docker.com/machine/overview/) offers a way to run Docker under a VM in Windows. To [install](https://docs.docker.com/machine/install-machine/) Docker Machine in Windows is easy, assuming you have Git with Git bash and VirtualBox (5+) already installed. [Installation](https://docs.docker.com/machine/install-machine/) documentation lists the following command: 

```
$ if [[ ! -d "$HOME/bin" ]]; then mkdir -p "$HOME/bin"; fi && \
curl -L https://github.com/docker/machine/releases/download/v0.12.0/docker-machine-Windows-x86_64.exe > "$HOME/bin/docker-machine.exe" && \
chmod +x "$HOME/bin/docker-machine.exe"
```

This command will download and install Docker Machine in `$HOME/bin` folder (`$HOME` is by default, your Windows user folder). Docker Machine keeps its data files under `$HOME/.docker` folder.

After installation, to create Docker Engine VM, use:

```
$ docker-machine create --driver virtualbox default
```

This will create a VM named `default` with default parameters (~20GB dynamic disk and 1GB RAM). Check [documentation](https://docs.docker.com/machine/drivers/virtualbox/) if you like to fine-tune disk size and other VM parameters. Several Docker Machine commands expect `default` as default VM name, so it is good idea to keep it like that.

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

Given Docker Machine `ssh` command supports `ssh` arguments, we can directly run `docker` commands. It is useful to define an alias (assuming `$HOME/bin` is part of `$PATH`):

```
$ alias docker='docker-machine ssh default docker'
```

And use it directly from Git bash:

```
$ docker --version
Docker version 17.05.0-ce, build 89658be
```

Once done with `docker` we can stop the machine using (`docker-machine` will list all [available](https://docs.docker.com/machine/reference/) commands):

```
$ docker-machine stop
```

A common case for `docker` images is to be able to access them from outside of Docker Engine VM in Windows host. This is already handled by VM NAT (VM is accessible in the host), as the following example from documentation shows:

```
$ docker run -d -p 8000:80 nginx
$ curl $(docker-machine ip):8000
```

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2017/2017-05-16-The-New-Docker.md'>The New Docker</a></ins>
