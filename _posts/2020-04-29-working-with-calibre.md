---
layout: post
title:  "Moving to the Container Future with Calibre"
date:   2020-04-26 13:51:51 -0500
# categories: docker
#   tags: docker
---
Recently I have had a bit of time on my hands and to not waste that extra time I figured I would take some time to work on some of my personal technical debt. One of the things that I have been trying to get a handle on is my massive ebook library. At one point in my life I thought it would be a great idea to buy a bunch of books (yes... computer related books) for my personal library to read on my Kindle. Well the funny thing about books is that it is far easier to buy ones with interesting titles during sales then it is to read them. This lead me to have a massive library that was organized by folders on a hard drive. And by "organized" I am talking about large strokes, if the book mentioned C++ it went into a C++ folder. If the book was about Algorithms I put it in a folder marked "Computer Science". Real sophificated stuff. But now that I look back on that organization stratgey I feel like it was missing something rather important -- organization.

So with some time to my self and and ever growing interest in using Docker both in a Dojo and out, I set my self to running a container with Calibre installed so I can finally get a handle on all of these books. This is what this series of posts is about: what I learned about Docker and how I applied using containers to real problems I faced at home. This may not have been the right way of doing this at all and I fully recognized that. But I believe that in order to learn how something works or why something is useful you have to fail... a lot.

Getting Docker up and running on my Linux box (Ubuntu 18.04) wasn't that hard at all. I opted to go for the snap version of Docker instead of the one from the apt-get repository. This was mainly because I liked the new idea of running a container in another container but I also like the portability that snaps provided. If you want to read more on snaps please follow [].

Installation was a "snap"! All I had to do was run ``` bash sudo snap install docker ```. This installed the docker program on my Linux box and allowed me to run docker through the command line. It was thrilling.

The next step was to try to find a docker image that allowed me to run a docker container of calibre. This again was not hard at all because calibre was already in the docker registry. I went with the version from the LinuxServer.io team because it was the first one that I found for my search result. Maybe another time I'll play around with creating my own image or even run this image against anchore for vulnerabilities, but for now time was of the essence! These books would not be gathering metadata about themselves! [https://hub.docker.com/r/linuxserver/calibre]


Pulling the images down didn't take any time at all. I'm quite glad and the total image size was only 1.11 GB. While I'm sure there are smaller images out there I think that the real cause for size is the fact that this image is running an embedded guacamole server. {guacamole}.
Once I had my image pulled and ready to do I could invoke the docker run command and allow me to with my e-book library.

``` bash
docker run  \
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
- ``` linuxserver/calibre ``` This is the container image that I am currently pulling down from dockerhub.

There is a rather important thing to note with this setup and calibre in general. Calibre will take full control of your books for you and separate them out by the author that has written the book using its own metadata gathering algorithm. This is great for those of you that can't do library management yourself, just keep in mind that this is creating a secondary copy of all of your books on the same hard drive where your actual books are. 

When I started up the container and ran my import using the "Add Books" function everything worked as expected! I could take some time now and push all my books in the various shelves as if it were a real library (even better because I could add multiple books to the same shelf). All was right with the world. 

I learned a bit about Docker running this little exercise. It was incredibly easy to get up and running on my local computer. I had a server configured in about 4 minutes with what I needed and the full import only took 2 hours. I think that's the whole point with this container craze. It should be easy for me to be able to run things on my home computer with minimal install procedures and minimal configuration. I should be able to spin up a container for my general purpose tasks and even my programming task so that I can focus on the more important things such as writing code or organizing of very unorganized bookshelf. I am excited to learn more about containers and more all of their possibilities. This may turn into true love.


Notes: 
Add headings for each section
