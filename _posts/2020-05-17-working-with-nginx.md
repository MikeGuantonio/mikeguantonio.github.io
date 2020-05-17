Notes: 
Describe the end state of the networks using the picture taken on 05-17-2020
Call out that you don't want to hardcode the ip addresses of the container and pefer to use the service names
Call out you know that a diffrerent container project exists for doing this kind of thing, but you wanted to learn how this kind of thing was done and having that project in place robbed you of the magic. 


# Post Series: 
## Intro and Idea 
High level stuff to serve as notes and reminders when I write the post

Problem: I had several containers up now for my calibre library. I lied... I have books other than computer science. It was a real pain to remember all of those stupid port numbers and the ip address of the server. There has got to be a better way to manage all of this and make it so people visiting my network can connect and do some cool stuff. Enter nginx reverse proxy

What is a reverse proxy. 
no code, just a high level idea of what reverse proxies are and why I want one

## Reverse Proxy setup via container 
Why are you using docker? 
I liked the idea of having a docker container that could act like the sole entrance to my home network and so that I didn't have to manage many ports
simple post with how this is setup 

## Referring to research 
Problems: 
Well... my containers can't speak to each other!
* this is because of how docker-compose work and how it creates a diffrent network for each set of containers
* learned a new thing that this allows me to communicate through service name instead of ip address
* good to know for container orchastraion later. 

Okay so I got that connected finally by creating the bat-cave network and sharing it
Potential problem here: my containers now need to know about this network before starting
This means that my self documenting infrastructure is no longer self documenting! Leave that as a question for now because I don't have a solution

all examples I am seeing have the docker-compose network include the proxy. Don't want this due to having to maintain too many proxies. Can't they know about each other? Yes they can. 

## Binding services to container ports on the reverse proxy
I want to do sub domains but I want to see if this will work first. This means I need to bind all ports of the reverse proxy with an entry in the reverse proxy configuration. Meaning I have to know more than I want to know... 

## Binding via subdomain name
Moving forward... 
This is great... but I need to now mount each port in my docker compose file. Dang. That's not at all what I wanted. I want to utilize all sorts of things the cool kids are doing a create an internal domain name and an internal sub domain for each thing I care about
* leave out the part that if this is not present then I can't do anything. 
* make sure to include that you have to make sure the name of the upstream server matches the proxy name and not the service name you are trying to create with the sub domain. 







Got that set up... great!
Wait... Now when I go to 8080 port I get to see.. the main page, but it has no idea what to do with the subdomain... That was the main issue. So I had to edit my etc/hosts file to make things work and set up the two DNS names there to allow the redirection to the reverse proxy. This is because the reverse proxy is just a process that I'm proxying to another machine. It is only linked thorugh port. Had I built a server that allowed for this off the bat I would not have this issue. 


How do I create a domain name on local network

## Binding via pihole and network dns to make sure all devices can see this
And... wait... I want my phone to be able to use this url I created... 
This portion is setting up the DNS names in pihole and redirecting to the remote server I have set up that is hosting the container. 

Will probably move the remote proxy to nas (bc you can do that) but it would break until I bring in docker swarm
Good to bring up Open Shift and K8s to solve this issue. 

## Future NGINX problems. 

Future Problems: 
If the service is down... oh no! Can't bring it back up. 
* Using WOL to wake the server
* But if the service is down I'm out of luck
* Go back to the main ideas here to see if I can take an action on the nginx server is something is not up to start it for me
* This would very much be like kubernetes, but not quite like kubernetes. 