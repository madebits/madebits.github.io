#Docker's Black Hole Like Behavior

2019-01-24

<!--- tags: devops -->

We have MongoDB running within a Docker container in a Linux machine. The MongoDB storage folder and configuration are mounted (using `-v` option) in disk folders outside the container, and the container does not write data in internal `/var/log`.

All so good until the day we found `/var/lib/docker/overlay2` folder was consuming 14GB for a DB server that had around 5GB data (the size of DB data in disk folder mounted outside container was 5GB). A quick login within the container revealed that from within used space was reported to around 6GB (externally mounted data folder included).

So, we discovered this massive container [black-hole](https://en.wikipedia.org/wiki/Black_hole) of *14GB* mass wrapping our disk space-time, but within the container black-hole horizon, we experience a normal space metric, as predicted by common physics.

We are not [alone](https://forums.docker.com/t/some-way-to-clean-up-identify-contents-of-var-lib-docker-overlay/30604/11 ). This is related to the way the overlay file system works. The deltas in container state are preserved. Normally, if you map data folders outside and the deltas are small, it is hard to notice the grow in overlay in short time. However, if you have system where you generate a lot of changes over time and you have no clue what files are added / removed, then the overlay storage will grow, accumulating all those deltas.

Ideally, a compact process would happen as deltas are added, so that the effect of a sequence of *+delta*, followed by a *-delta* will annihilate each-other at some point. However, this is tricky to program and properly deal with that order. While there are some reported bugs around this behavior, common consensus is to just buy more disk space.

If one can afford container instance downtime and all your import data are mounted outside container, then there is easy workaround. Bring container down, *prune* unused containers and recreate them. This will free the space (alternatively starting container with `run --rm` may achieve same when they are down). It could be that use-cases like our MongoDB container are rare, but the problem is present. In long term, when there are many log running containers, one has to deal with disappearing space in automated ways.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2019/2019-01-23-Installing-Ubuntu-18.10.md'>Installing Ubuntu 18.10</a></ins>
