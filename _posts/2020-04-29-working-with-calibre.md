---
layout: post
title: "Moving to the Container Future with Calibre"
date: 2020-04-26 13:51:51 -0500
# categories: docker
# tags: docker
---
## Library Liberation

Recently I have had a bit of time on my hands. I figured it would be best not to waste that time and instead focus on some of my personal technical debt. One of the things that I have been trying to get a handle on is the organization my massive e-book library. At one point in my life I thought it would be a great idea to buy a bunch of books (yes... computer related books) for my personal library to read on my Kindle. Well the funny thing about books is that it is far easier to buy ones with interesting titles during sales then it is to read them. This lead me to have a massive library that was organized by folders on a hard drive. And by "organized" I mean it in the most broad of senses. If the book mentioned C++ it went into a **Programming** folder. If the book was about Algorithms I put it in a folder marked **Computer Science**. Real sophisticated stuff. But now that I look back on that organization strategy I feel like it was missing something rather important -- organization.

So with some time to my self and and ever growing interest in using Docker both in a Dojo and out, I set out to run a container with [Calibre](https://calibre-ebook.com/) installed so I can finally get a handle on all of these books. This is what this series of posts is about: what I learned about Docker and how I applied using containers to real problems I faced at home. This may not have been the right way of doing this at all and I fully recognize that. But I believe that in order to learn how something works or why something is useful you have try and see what works. *Failure is always an option*.

## Getting Lost In A Good Book(s)

Getting Docker up and running on my main Linux box running Ubuntu 18.04 wasn't that hard at all. I opted to go for the [snappy version](https://snapcraft.io/docker) of Docker instead of the one from the apt-get repository. This was mainly because I liked the way the package manager mirrored how containers package both the runtime and the source code in one place but I wanted to use this as an opportunity to try something else new.

Installation was a "snap"! All I had to do was run ```> sudo snap install docker ```. This installed the docker runtime agent on my computer and also created a folder in my snap directory that contained all of the files needed to run the command line version of Docker. It was thrilling.

The next step was to try to find a docker image that allowed me to run a docker container of Calibre. This again was not hard at all because Calibre was already in the docker registry from multiple providers. I went with the version from the [LinuxServer.io](https://hub.docker.com/r/linuxserver/calibre) team because it was the first one that I found for my search results. Maybe another time I'll play around with creating my own image or even run this image against [Anchore](https://anchore.com/opensource/) for vulnerabilities, but for now time was of the essence! These books were gathering digital dust and were not going be gathering metadata about themselves!

## Building the Library

Pulling the images down didn't take any time at all. I'm quite glad and the total image size was only 1.11 GB. I think that the large image size came mostly from the use of the [Apache Guacamole](https://guacamole.apache.org/) embedded server contained in the image. This is really neat because it allows me to have RDP access to the running process inside the container. This meant that it was a lot like using a virtual machine or like connecting to a remote desktop server.

Once I had my image pulled and ready I could invoke the docker run command and allow me enjoy the peace of mind afforded by the creation of a digital library.

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

This command was rather simple. Let me break it down:

- ``` docker run ``` allowed me to invoke docker to run my container
- ``` -e PUID ``` is the user id that will be worked with for the guacamole server
- ``` -e PGID ``` is the group id for that same server
- ``` -p 8080:8080 ``` this bound my local port {8080} with the container port {8080}
- ``` -v /home/mike/containers/calibre/computer_science_book_config:/config \ ``` This bound my local config directory with the container's directory. This is where the books will be housed
- ``` -v /home/mike/containers/calibre/computer_science_book_config/to_import:/books ``` This contains the directory of the books that I want to import to calibre
- ``` --restart unless-stopped ``` This allowed my container to restart itself if there was a failure or if anything else had happened I did not initiate.
- ``` linuxserver/calibre ``` This is the container image that I am currently pulling down from docker-hub.

There is a rather important thing to note with this setup and Calibre in general. Calibre will take full control of your books for you and separate them out by the author that has written the book. Calibre derives this information by using its own metadata gathering algorithm. This is great for those of you that can't do library management yourself or, if you are like me, not trained in the subtle art of being that meticulous about book locations. Keep in mind that this is creating a secondary copy of all of your books that you are loading into the new container which is just another location on your hard drive. You can run out of disk space if don't plan this correctly.

Just like that I had my first library set up and ready for me to load and consume content. When I started up the container and ran my import using the "Add Books" function everything worked as expected! I could take some time now and push all my books in the various shelves as if it were a real library (even better because I could add the same book to different shelves). All was right with the world.

## Ending This Chapter

I learned a bit about Docker running this little exercise. It was incredibly easy to get up and running on my local computer. I had a server configured in about 4 minutes with what I needed and the full import only took 2 hours. I think that's the whole point with this container craze. It should be easy for me to be able to run things on my home computer with minimal install procedures and minimal configuration. I should be able to spin up a container for any task so that I can focus on the more important things such as writing code or the organizing of very unorganized book collection. I am excited to learn more about containers and more all of their possibilities as I continue on this learning journey. I've overcome the first hurdle of learning something new which is just trying and experimenting to see what works. Plus this is the kind of story I can tell the teams I mentor as they start their container journey. My head is swirling with project ideas that can allow me to spin up a container as my base system instead of muddying my machine custom installs and extra software. This also may finally be my time to go a little deeper on Linux and know exactly what is happening under the hood because containers are made to be broken. But, that's future Mike's problem. For now I'm going to brew a cup of tea and curl up with a good book.
