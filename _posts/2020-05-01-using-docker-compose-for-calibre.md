---
layout: post
title:  "Saving Some Time With docker-compose"
date:   2020-04-30 18:51:51 -0500
# categories: docker
#   tags: docker
---
I'm still new to this world of running docker as a container platform and working through the various issues around thinking in this new way. I had worked with Vagrant before and I've spun up my share of virtual machines for development work and homelab work. Each time I realize that when I learn something great there are often greater things on the horizon. 

## My Fingers Were Getting Sore

This may not come to a surprise to any of you, but when working with docker and the ``` docker run ``` command you have to know a bunch of long command line options. Now to get around this I was putting all of the commands into a .sh file and running the script when I wanted to start the server. To be honest, it worked fine but felt really hacky. Surely there is a better way? You would think that the team that came up with docker wouldn't have just stopped there and said "Finger exercizes are great! Let's go grab a coffee." So I did some digging.

For those of you that run docker on Windows and MacOs realize that the docker package already comes with a little program called ``` docker-compose ```. This was a real game changer for me. ``` docker-compose `` allowed me to take what I had in my shell script and put that configuration in a .yml file that I could use to control how docker would execute my container. I could put in all of the parameters and variables I needed and with a simple ``` docker-compose up ``` I was off to the races. Even better is that I could use the -d command (just like with the standard docker) to run things in the background as a daemon process. 

In the end my docker-compose file looked like this for the server
``` yaml
# Please note that this server must have a local mount on the host. If the host does not
# have said mount it will try to create it and it will fail. Run this first
# mkdir bat-book-mount && sudo mount -t cifs -o nobrl,username=admin,password={password},uid=1000,gid=1000,rw //192.168.1.13/books/computer_science bat-book-mount

# The above will create a local network filemount that will be used by the server.

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
            - './bat-book-mount/config:/config'
        #    - './bat-book-sort:/new_books'
        restart: unless-stopped
```

and this for the web server

``` yaml
# Please note that this server must have a local mount on the host. If the host does not
# have said mount it will try to create it and it will fail. Run this first
# mkdir bat-book-mount && sudo mount -t cifs -o nobrl,username=admin,password={password},uid=1000,gid=1000,rw //192.168.1.13/books/computer_science bat-book-mount

# The above will create a local network filemount that will be used by the server. 

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
      - './bat-book-mount/web-config:/config'
      - './bat-book-mount/config/Calibre Library:/books'
    ports:
      - 8083:8083
    restart: unless-stopped
```
Having the docker files seperated like this gives me exactly the level of control that I would want. I am unlikely to have to constantly import books to my server, but should the need arise I have the ability without trying to memorize a ton of different commands. This leads me to thinking that while it is nice to know the docker commands and how to maintain my local development enviroments using docker, it is also something that I don't always have to be super cognicent of being up to date on. I'm not yet running a cluster at scale and if that was the case I would probably manage something that the CNCF recommends wether that is kubernetes or Open Shift. In short I think I'll use the docker run and docker build commands when I'm testing an image that I'm curious about, but when it comes to working with something that I would like to memorialize I may move it a docker-compose file. That being said, docker-compose also allows me to do exactly the same things with easier syntax, so it could just be more of a situation of where I use to tool because I want to and focus on the real effort (writing code, running servers, building things) because afterall isn't that the entire point of DevOps? 