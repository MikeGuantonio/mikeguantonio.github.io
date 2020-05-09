---
layout: post
title: "Saving Some Time With docker-compose"
date: 2020-04-30 18:51:51 -0500
# categories: docker
# tags: docker
---
I'm still new to this world of running Docker as a container platform and working through the various issues around thinking in this new way. I had worked with Vagrant before and I've spun up my share of virtual machines for development and home lab work. Yet each time I learn a new technology I find that there is always more to learn and easier ways to work.

## My Fingers Were Getting Sore

This may not come to a surprise to any of you, but when working with docker and the ``` docker run ``` command you have to know a bunch of long command line options. Now to get around this I was putting all of the commands into a shell script and running the script when I wanted to start the server. To be honest, it worked fine but felt really hacky. Surely there is a better way? You would think that the team that came up with Docker wouldn't have just stopped there and said "Finger exercises are great! Let's go grab a coffee." So I did some digging.

For those of you that run Docker on Windows and Mac, you might realize that the docker package already comes with a little program called [``` docker-compose ```](https://docs.docker.com/compose/). This was a real game changer for me. On Ubuntu you have to install the package. Again this was as simple as running ```sudo snap install docker-compose``` to add it to my local snap repository.

 ``` docker-compose ``` allowed me to take what I had in my shell script and put that configuration in a yaml file. This meant that I could define the run-time definition of my container in a single, easy to edit file. I could put in all of the parameters and variables I needed and with a simple ``` docker-compose up ``` I was off to the races. Even better is that I could use the -d command (just like with the standard Docker) to run things in the background as a daemon process.

## It Really Is A Lot to Type

Let's have a refresher on the command that I was using to just start up my local container. 

``` bash
docker run \
--name=bat-cs-lib \
-e PUID=1000 \
-e PGID=1000 \
-e TZ=America/New York \
-p 8080:8080 \
-p 8081:8081 \
-v /home/mike/containers/calibre/computer_science_book_config:/config \
-v /home/mike/containers/calibre/computer_science_book_config/to_import:/books
--restart unless-stopped \
linuxserver/calibre
```

This is great if I were experimenting with a container or debugging an existing configuration that may go to Open Shift or another container orchestration engine. I could run those commands to mount volumes at file paths I expect or work with setting up my environment variables to match my target environment. For day to day operations, however, I would not want to type all of this out. If I had not touched this container for months I would also not want to have to reverse engineer my commands to figure out what I did. 

In the end my docker-compose file looked like this for the server
``` yaml
version: '3.3'
services:
bat-computer-science-lib:
container_name: bat-computer-science-lib
image: linuxserver/calibre
environment:
- PUID=1000
- PGID=1000
- TZ=America/New_York
ports:
- '9080:8080'
- '9081:9081'
volumes:
- '/home/mike/containers/calibre/computer_science_book_config:/config'
- '/home/mike/containers/calibre/computer_science_book_config/to_import:/books'
restart: unless-stopped
```

and this for the web server

``` yaml
version: "3.3"
services:
bat-web-cs-lib:
image: linuxserver/calibre-web
container_name: bat-web-cs-lib
environment:
- PUID=1000
- PGID=1000
- TZ=America/New_York
- DOCKER_MODS=linuxserver/calibre-web:calibre
volumes:
- '/home/mike/containers/calibre/computer_science_book_config:/config'
- '/home/mike/containers/calibre/computer_science_book_config/to_import:/books'
ports:
- 8083:8083
restart: unless-stopped
```

## Wait... Why Did You Create Two Files?

That's a good question disembodied voice. I could have very easily created this as a single file and either ran both or ran the individual server that I wanted by calling out its service name in the ```docker-compose up``` command. I wanted the freedom to try two different things

1. The ability to start different servers with the -f command
2. A separation of web browsing from server management.

This provided me with that separation and allowed me to learn more about the commands that I can later use in shell scripts or for other purposes. 

## Simplicity in Abstraction

Having the Docker files separated like this gives me exactly the level of control that I would want. I am unlikely to have to constantly import books to my server, but should the need arise I have the ability to start my servers without trying to memorize a ton of different commands. I think that while it is nice to know the Docker commands and how to maintain my local development environments using Docker, it is also something that I don't always have to be super aware of being up to date on. I can always look up these commands online or from the command line. I'm not yet running a cluster at scale and if that was the case I would probably manage something that the CNCF recommends whether that is Kubernetes or Open Shift. Also, if I were running this at scale I'm sure I would get all the command practice I needed while in the trenches.

In short I think I'll use the ```docker run``` and ```docker build``` commands when I'm testing an image that I'm curious about, but when it comes to working with something that I would like to memorialize I may move it a ```docker-compose``` file. docker-compose also allows me to do exactly the same things with easier syntax, so it could just be more of a situation of where I use to tool because I want to and focus on the real effort (writing code, running servers, building things). After all isn't the entire point of DevOps to automate the small stuff and focus on doing real work?