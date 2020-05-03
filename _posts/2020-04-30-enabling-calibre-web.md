---
layout: post
title:  "Enabling Web Server Access To Calibre"
date:   2020-04-30 18:51:51 -0500
# categories: docker
#   tags: docker
---
All was not right with the world. 

I had this solution that worked great on my local desktop. I can manage my e-book collection to my heart's content. But... I'm not often at my desktop when I'm at home. I do somethings when I want to sit down and focus on building a new piece of content or trying to figure out something new for a team. Its a place of work and I'm not too inclined to sit at my desk all day long trying to find a book to read. The more I think about it I'm either reading on my phone or on my Kindle. What ever will I do? 

Solve the problem with contianers! That's what! So the calibre interface within my current container is running the full desktop version that I would normally have on my computer. This is great, I can have my volume mounts on my host machine and have the running program somewhere else. A real nice seperation of form and function. The downside is that its a heavy service being that its replicating all my actions via RDP and the interface isn't as modern as I'm used to. Call it an aestic problem, but its my home network and I'll have my opinions as I wish. 

So to solve this problem I went back to docker hub to find if there was a web version of calibre that I could use to serve my books. Turns out there is! Its calibre-web. This provides me a set of nice seggregation from me as the end user and book viewer to the me that is the book maintainer and book classifier. Installation was again a snap. All I had to do was run 

```
docker create \
  --name=calibre-web \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e DOCKER_MODS=linuxserver/calibre-web:calibre \
  -p 8083:8083 \
  -v path to data:/config \
  -v path to calibre library:/books \
  --restart unless-stopped \
  linuxserver/calibre-web
  ```

  This created another new container that I could then send to my local network and allow my phone and other computers to connect to to pull a copy from the original library configured by calibre. How cool is that? 

  The beauty of this is that calibre-web is a front end interface to the calibre container. Now I don't have to worry about having duplicated copied of a book around, I can use calibre-web to view everything that I had stored and not have to worry about reuploading the same book over and over. 

  That's the real beauty of containers. Everything is always just a command line away from having a running application. When I no longer want to run the server I can just spin down the instance. I no longer have to worry if my server is up to date all the time or if I'm missing operating system patches or if the data is being stored correctly on my machine or the virtual machine I'm calling home for this application. This provides a better seperation on my network for applications that I use all the time and gives me the full control of making certain what I'm spinning up is actually what I want. 

  This will be another thing I'll be able to bring up in the Dojo. I can allow teams to think more abstractly and have less fear because I'm advocating something that I'm starting to use all of the time. 