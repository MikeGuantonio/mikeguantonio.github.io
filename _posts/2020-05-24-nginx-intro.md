---
layout: post
title:  "Embracing the Middleman Syndrome With Reverse Proxies"
date:   2020-04-26 13:51:51 -0500
categories: nginx
---
## Remembering Numbers and Names

I realized that I'm not getting any younger when I realized that I no longer knew my best friend's home phone number. Most people out there probably don't even have a home phone number anymore. We have moved to the age of cell phones and social media. People are still distilled into numbers and geographic locations but its not something that the end user has to remember anymore. Aside from my parent's home phone number, which has not changed as long as I've been alive, I don't try to commit phone numbers to memory. If I'm being honest I'm also terrible with committing names to memory. Its nothing personal, just not something I'm good at. I'm great at knowing who people are, just maybe not so great at knowing their names when I interact with them.

This is a tech blog afterall, so what is the point that I'm trying to drive home? Well I noticed that phone numbers are not the only numbers that I shouldn't have to memorize. Port numbers and IP addresses are also something that I never commit to memory. If I go to a website I usually use its names via a DNS lookup and it redirects to me some server in some cloud somewhere. So why... why should I have to do that with my own home network when running comtainers? Shouldn't I be able to go to ```casa.cs-books.com``` and be taken to the place where I host my computer science books? Shouldn't I have the ability to get somewhere by knowing the name (or rough idea) of what I'm looking for and type that in. If I have guests over and on my home network I'm sure that they would rather see ```casa.blog.com``` instead of ```192.168.0.222:6258``` when reading my new posts before I get the chance to publish them.

## So What's The Problem?

My main problem right now is that I have several containers set up since we last spoke. They contain many more libraries running ```calibre```. Its a real pain to remember what books map to what IP:PORT combinations. When I want to read some fiction books I know I've incorrectly put in the library for math books. When I want to read a PDF that I downloaded with recipies from a food blog, I know I've stumbled upon the container location for diy projects. Its confusing and its now how most people use the web. I would like all of the hosts on my network to leverage DNS and go to a local website I've set up with minimal fuss and hassle. I would like to leverage subdomains if possible and really abstract away the IP:PORT from the end user. 

I think this will also be a fun exersize because this is what systems like K8s does under the hood. I shouldn't have to know what the underlying IP address of my pod is but rather have a service that that knows that mapping and passes back to me something that I can use DNS with to resovle the address. Although this series will not be touching on container orchastration just yet we will be leveraging Docker again to run a system known as a reverse proxy in front of all other containers. This will remove my woes with my home network and will allow me to have a pattern in place should I ever want to add new services to my home domain. 

## What is a Reverse Proxy? 

Utilizing the words of nginx, which will be the web server platform that we use in this post, a [reverse proxy](https://www.nginx.com/resources/glossary/reverse-proxy-server/) is 

```bash 
# If markdown has it, use quote syntax instead
A proxy server is a go‑between or intermediary server that forwards requests for content from multiple clients to different servers across the Internet. A reverse proxy server is a type of proxy server that typically sits behind the firewall in a private network and directs client requests to the appropriate backend server. A reverse proxy provides an additional level of abstraction and control to ensure the smooth flow of network traffic between clients and servers.
```

In short we are going to create a system that will act as a middle layer between our systems. You can think of this reverse proxy system as the front end service that all networking clients will route requests to. This provides us with a few benefits as well:
- Simplify access control
- Reduces risk of leaking sensitive information
- Have a single source of truth for access
- Enable traffic forwarding and control between services on the network
- Enable load balancing 
- Security
- Aggregating Multiple Websites Into the Same URL Space

You can also think of a reverse proxy as a DNS version what already happens with your natted IP address. The outside world only sees the ip address attached to your modem which is only a single octect stream. Interally your network is subnetted to handle all devices on the network. It is through ip tables and the like that this mapping of internal ip is mapped to external ip and sent out to the internet. The same kind of translation will be happening as we work with reverse proxies. We will enable a single domain name that our clients will connect to, but internally we may redirect them to multiple backend services. 

## What Will This Post Series Accomplish

This series aims to get nginx setup on my local home network and to act like a reverse proxy for all of the containers that I wish to add in the future. I'll be walking you through how to create the container, how to configure nginx for the proxy and, if I remember, regale you with stories of problems that I faced along the way. There will be code in place that is relevant to my home network, but I want to also try to make this as simple as possible so that you can work along at home. Let's try to move into the 21st centry and get our home networks to act more like the internet that we are used to and less like the network we created for lab experiments. 