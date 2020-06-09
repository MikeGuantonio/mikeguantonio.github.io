---
layout: post
title:  "Getting Ready To Use Nginx"
date:   2020-04-26 13:51:51 -0500
categories: nginx
---

## Speak Friend and Enter

Having a network of Docker containers can be a boon or a burden depending on what your outcome is. When I first started I wanted the ability to spin up servers on demand on my local host and interact with them through a common network interface. I thought that was simple enough. Sure I would have to memorize a port number and maybe an ip address but that could just be the cost of doing business. As I got more into the hobby of working with Docker however I realized that it really wasn't feasible to memorize all of those things at once. It would be far easier if I only had to hit one port number and one IP address and the server serving the containers could be smart enough to direct me to the right container. Much like how a network switch directs traffic across a network. The end computer doesn't need to know anything about the network, it only needs to send the request and its up to the switch (and other networking technologies) to make all of the decisions.

So I decided that I needed a metaphorical front door to all of my services and I was going to leverage nginx to do so. I had used nginx back in my Ruby days and decided that I would like to get back to configuring web servers with it. A nominal plus is the fact that I am also able to run the whole thing in a container which means that once I can get this working, I'm free to move it to anywhere else on my network. Treating machines like cattle makes the networking and configuration a bit more fun in my opinon. 

## Building Out The Front Door

Since I knew that I would like to keep this container up and running I opted to start with a ```docker-compose``` file instead of the standard ```Dockerfile```. I was hoping that I would be able to just use this file as I wouldn't need to make any changes to the base layers. I wasn't building a brand new image but rather utilizing one that was already present and just attaching my own personal configuration to it. Dockerfiles are great when you want to add funtionality to a base image due to their tree-like nature of base and build images.  

I started off pretty simply with the [nginx base image](https://hub.docker.com/_/nginx) from docker hub and put it into a compose file.

``` yaml
version: '3.5'
services:
    bat-front-door:
        container_name: bat-front-door
        image: nginx
        ports: 
            - 8080:80
        environment: 
            - NGINX_PORT=80
        restart: unless-stopped
```
With that I have the start of a simple entryway into my home network. I'm able to navigate to localhost:8080 and see the nginx welcome screen. (put welcome screen in the blog). 

## Its All About Baby Steps

For now I'm okay with this. I have the container runing on my network. I can direct it to the port that I want to work with and I can build that configuration out further. I think that is good enough for today. The next step will be to set up a domain name and then to start routing traffic all through my home network. I don't know about you, but I am excited for the possibilities that this will provide.
