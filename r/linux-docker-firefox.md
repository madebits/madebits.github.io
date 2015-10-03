2014

#Linux Docker Isolated Firefox

<!--- tags: linux docker -->

A [docker](https://www.docker.com/) file based on [nuxeo-blog](http://www.nuxeo.com/blog/development/2014/01/docker-containers-nuxeo-part-2-add-vnc-openbox/) to create an isolated Ubuntu based container with Firefox browser. Firefox instance is completely isolated (cannot see host X11 events) and runs under a normal user account.

![](r/linux-docker-firefox/docker.png)

To create run from within docker-firefox folder:

```
docker build --rm=true -t "vasian/gui" .
```

You can replace the container tag "vasian/gui" with something own.

By default, the created user has the name and password `user:password`. Edit the Dockerfile if you want to use something else. The screen resolution to use is by default 1366x768x24. Edit startXvfb.sh to change it.

To start the container, use:

```
docker run --rm -P -it --name temp1 -u user vasian/gui
```

If you want to map your `/tmp` folder to be visible as `/host` inside the container use:

```
docker run -v /tmp:/host --rm -P -it --name temp1 -u user vasian/gui
```

The created docker image is generic. It will start Firefox by default and a terminal. You can also pass as command line arguments other commands inside the container to run. Default command line is: `/startXvfb.sh xterm firefox`.

Then use vncviewer to connect (`sudo apt-get install xtightvncviewer`):

```
vncviewer localhost:$(docker port temp1 5900 | cut -d : -f 2)
```
