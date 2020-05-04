---
layout: post
title:  "Calibre, Docker, and My Nas -- A Tale of Two Locations"
date:   2020-04-30 18:51:51 -0500
# categories: docker
#   tags: docker
---

All is well and good on the homefront. I have access to my books and I have access to my management of those books. I really can't ask for anything more... Except, you see I have this NAS in my home. I love it. It stores all my files. And previously in my other posts I have just copied all the computer science books down to may local compter and created those files on the desktop to act as a server. But I would really like to have the computer be the server, but my nas to be... well a nas. So like I tell people in the Dojo and in my own personal life, lets break stuff and see what happens!

Linux provides a host of different ways to handle file mounts. You can configure it multiple ways using various protocols. I did some digging on the mount commnad and it looks like I'm going to have to use the cifs protocol to be able to handle this kind of file hosting. cifs is... 

The files will then look like this
``` bash
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

