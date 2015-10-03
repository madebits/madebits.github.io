#The New Docker

2017-05-16

<!--- tags: virtualization -->

Since [Docker](https://www.docker.com/) come out it was obvious that single containers without orchestration are limited in usability. It is groups of containers that make up applications. Docker is [evolving](https://docs.docker.com/get-started/) to have container orchestration build-in via `docker swarm` and ease deployments via `docker stack` and `docker deploy`.

##Swarms

A swarm is a collection of machines known as *cluster of nodes*. Nodes are uniform: they run Docker Engine and can run any container. A subset of nodes is called *managers* (managers can also be workers) and contain services to orchestrate the rest of *worker* nodes via *tasks*. Managers use <a href="https://en.wikipedia.org/wiki/Raft_(computer_science)">Raft</a> to reach consensus. 

A machine running Docker Engine can [join](https://docs.docker.com/engine/swarm/manage-nodes/) a swarm and be one of its nodes. Swarm offers node orchestration, deployment roll-up (via stacks and services), and network management via virtual [overlay](https://docs.docker.com/engine/swarm/networking/) networks.

##Networking

Swarms orchestrate nodes on the top of secure virtual overlay networking. The default overlay networking, called [ingress](https://docs.docker.com/engine/swarm/ingress/) manages a mesh gossip network where all nodes know about all service container nodes and can route transparency to them. Custom virtual overlay networks can be created by services.

##Services

A [service](https://docs.docker.com/engine/swarm/swarm-tutorial/deploy-service/) is a unit of orchestration. A service manages instances of one container in swarm cluster. Services can share overlay networks, where service containers can refer to each-other by DNS-SD names visible in the overlay network which handles also software-based load-balancing. This design decision is different from [Kubernetes](https://kubernetes.io/) where virtual network is shared by default by a Pod.

A service can be global. Global services run on each node in the cluster, such as, the `dockersamples/visualizer:stable` [service](https://github.com/dockersamples/docker-swarm-visualizer). Non-global services can be orchestrated to run in any sub-collection of nodes.

##Stacks

Docker documentation defines: *"A stack is a group of interrelated services that share dependencies, and can be orchestrated and scaled together."* Stack is an application made of several services. Stacks can currently share services, networks, and volumes, and are described together.

##Gluing Things Together

[Docker Compose](https://docs.docker.com/compose/overview/) offers the glue to keep things together. The compose files are being enhanced in version 3 to support swarm features. Given the tight connection of swarm in docker itself, it could be that Compose will be also merged into docker itself at some point. Configuration via *Secrets* is mapped as files into containers (container must be build to read configuration from such mapped files).

A compose [Yaml](https://en.wikipedia.org/wiki/YAML) file can define a stack made of services. Services can only refer to ready made containers. The experimental `docker deploy` feature (intended as cross `docker stack deploy`) can be used with [Distributed Application Bundles](https://blog.docker.com/2016/06/docker-app-bundle/), that are JSON files generated for Docker Compose yaml files. 

I am not sure what the motivation to introduce DAB format is. It could be the integration of Compose-like features into core Docker. This part of Docker is still fluent.

##Swarm Formation

Swarm nodes can be deployed on any data-center, to any infrastructure. Docker offers ready made templates for Azure, [AWS](https://stelligent.com/2017/02/21/docker-swarm-mode-on-aws/) [CloudFormation](https://console.aws.amazon.com/cloudformation/home), etc. These templates are nice to get started, but effort is needed to customize and maintain swarms in specific providers.

##New and Missing Features

*Docker Inc.* is working to expand on Docker Swarm and make it comparable to the more mature solutions such as [Kubernetes](https://kubernetes.io/). Recent [features](https://sreeninet.wordpress.com/2017/01/27/docker-1-13-experimental-features/), such as, orchestration of service logs, and node metrics compatibility with [Prometheus](https://prometheus.io/) enable re-using third-party Kubernetes tooling also for Docker Swarm.

What I would like to see in Docker Swarm (as well as in Kubernetes) is some form of service dependency management - something like a distributed [systemd](https://en.wikipedia.org/wiki/Systemd). You can specify node affinity, but full-fledged abstract dependency management has be to handled currently on your [own](https://www.docker.com/use-cases/cicd) in [CI/CD](https://en.wikipedia.org/wiki/CI/CD) level.

##Books

I found the following material useful on the topic:

[![@left@](blog/images/bco/db1.jpg)](https://www.packtpub.com/virtualization-and-cloud/docker-orchestration) **Docker Orchestration** 

Good introduction covering various aspects of Docker, Docker Swarm, and Kubernetes.

*(2017)*
<br clear="all">

[![@left@](blog/images/bco/db2.jpg)](https://www.packtpub.com/virtualization-and-cloud/getting-started-kubernetes)  **Getting Started with Kubernetes** 

Useful to get you started, but I had to also to read other sources to get a idea how K8i really works.

*(2015)*
<br clear="all">

[![@left@](blog/images/bco/db3.jpg)](https://www.packtpub.com/networking-and-servers/mastering-kvm-virtualization) **Mastering KVM Virtualization**

While not directly connected to the above, you may need to read this book, in case you need to setup your own local cluster for experimenting.

*(2016)*
<br clear="all">

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2017/2017-06-14-Docker-Machine-On-Windows.md'>Docker Machine On Windows</a> <a rel='next' id='fnext' href='#blog/2017/2017-05-09-Ubuntu-Block-Application-Internet-Access.md'>Ubuntu Block Application Internet Access</a></ins>
