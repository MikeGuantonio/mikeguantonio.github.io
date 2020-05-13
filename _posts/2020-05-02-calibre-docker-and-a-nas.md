---
layout: post
title:  "Calibre, Docker, and My Nas -- A Tale of Two Locations"
date:   2020-04-30 18:51:51 -0500
# categories: docker
#   tags: docker
---

All is well and good on the homefront. I have access to my books and I have access to my management of those books. I really can't ask for anything more... Except, you see I have this NAS in my home. I love it. It stores all my files. Previously in my other posts I have just copied all the computer science books down to my local compter and created those files on the desktop to act as a server. But I would really like to have the computer be the server, but my nas to be... well a nas. So like I tell people in the Dojo and in my own personal life, lets break stuff and see what happens!

Linux provides a host of different ways to handle file mounts. You can configure it multiple ways using various protocols. I did some digging on the ```mount ``` command and it looks like I'm going to have to use the [Common Internet File System](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/performance_tuning_guide/s-cifs) (CIFS) protocol to be able to handle this kind of file hosting.

CIFS is a common protocol used by Samba (SMB) to share files over a network. This kind of file sharing natively works with Windows and Linux which is great for my cause as I may one day use a Windows machine on my local network. If the day ever happens I'll be prepared. I also want to make sure that this is reflected in my docker-compose file as I've grown quite fond of the way it is managing my containers for me. 

Let's review the last state of the computer science library docker-compose file.

``` bash
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
            - './config:/config'
            - './books:/new_books'
        restart: unless-stopped
```

This is great as I can utilize the relative path of where I'm storing my docker-compose file so that I don't have to use those messy absolute paths. I call this a win because it gives me the ability to have some portability in place should I ever want to move around where I store these configurations. As long as I have the folders in the right location it should more or less work as expected. 

## Now for Some Bad News

Well not bad news just something I haven't figured out how to do yet. This may be part of another post but as I was doing my research for this command I noticed that what I wanted to have happen was that the NAS folder should be able to be accessed via its IP address or hostname like everything else that I do when working with my NAS. Try as I might I could not get this to work.

Another thing that I was not able to get working is setting up some kind of init configuration for the docker-compose file. What I need is the ability to mount the network share directly to my host's file system and then access it through the file mount. After reading about the Linux ```mount``` command a bit more I was able to figure out the right command line arguments to make it connect. 

```
# First I had to create the folder
mkdir bat-book-mount

# Then I had to run the mount command with the cifs option
sudo mount -t cifs -o username=mountUser,password={password},uid=1000,gid=1000,rw //192.168.1.48/books/computer_science bat-book-mount
```

This created a directory under the root directory of where my docker-compose file was and connected directly to the network location of where my books were located. I was able to double click and see all of the books that I really needed to import into my library. This was nothing too fancy, but still made me feel good. 

## Attaching the container to the mount

This portion was a bit more complex but still very simple. In the volume section all I needed to do was point to the newly created directory in the docker-compose file. I created another mount called ```bat-book-sort``` for some new books that I was going to be importing once I got this up and running. My configuration now looks like this within my docker-compose file.

``` bash
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
            - './bat-book-sort:/new_books'
        restart: unless-stopped
```

A simple docker-compose up was all I needed to do to make this process **FAIL**. Epically.

## Missing A Key Statement

Now when attaching the mounted directory through CIFS on my host machine I was able to make things work as expected. Docker for some reason could not connect at all. I scoured for hours to try to find what was different between what docker was expecting when it was connecting to the remote file file and what I needed to supply. It turns out that what I was missing was ```nobrl``` as part of my argument to the CIFS command. This was great I was able to connect once I put this in but what is [```nobrl```](https://linux.die.net/man/8/mount.cifs)?

``` text
nobrl
Do not send byte range lock requests to the server. This is necessary for certain applications that break with cifs style mandatory byte range locks (and most cifs servers do not yet support requesting advisory byte range locks).
```

What it looks like happens is that docker does not know how to request an advisory byte range lock. What I believe this means is that docker was trying to put a file lock on the file location on the NAS but did not know how to remove the lock once the read has finished. Due to this being part of a running application howerver I didn't want it to close the NAS connect. I wanted it to stay open so I could pipe things in an out. By adding ```nobrl``` as part of the mount request for CIFS I was able to bypass this issue. 

The now full command for the ```mount``` statement is

```
# Then I had to run the mount command with the cifs option
sudo mount -t cifs -o nobrl,username=mountUser,password={password},uid=1000,gid=1000,rw //192.168.1.48/books/computer_science bat-book-mount
```

and for the docker-compose file for the web

``` bash
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

Once I was able to submit my password for this file on my command line, I had a locally mounted folder in place that pointed directly to the folder of interest. This allowed my calibre containers to start up on my local host and allow me to query for that inforamtion on the nas. 

This all sounds so needlessly complex for my homelab, doesn't it? But that is the good thing about having a homelab. You can experiment and try new things out. I know on my average everday job I'll be helping teams to mount NAS mounted storage from a local network mount. While they may do something a little more sophificated by way of utilizing a secrets management solution or enabiling the NAS to be mounted via other protocol,  this has other use cases. I think this is something that I was able to really dig down deep and learn about a file protocol that I haven't had a chance to really play with. It was also interesting that the docker mount command allows for the user to use the same kind of interface that the standard Linux mount command allows for. This is great because it leads me to assume that docker administration is must like Linux administration. 

