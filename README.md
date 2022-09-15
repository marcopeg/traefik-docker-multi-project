# traefik-docker-multi-project

How to use [Traefik][traefik] to drive traffic to independent [docker-compose][dc] projects.

You are about to learn:
- How to run a static website using [Docker][docker] and [NGiNX][nginx]
- How to **run a reverse proxy** with [Traefik][traefik]
- How to setup a _custom newtwork_ in Docker
- How to attach containers to an existing _Docker network_

👉 Before you continue, make sure you go through the "[How to run a _Create React App_ development environment using Docker, Docker-Compose, and Traefik](https://github.com/marcopeg/cra-docker-traefik#readme)" tutorial, for it covers the basics of setting up Traefik and we won't repeat it in here.

## Table Of Contents

- [Quick Start](#quick-start)
- [Project Structure](#projects-structure)
- [Run a Static Website on NGiNX](#run-a-static-website-on-nginx)

## Quick Start

1. Clone the repo:  
   `git clone git@github.com:marcopeg/traefik-docker-multi-project.git`
2. Open the project:  
   `cd traefik-docker-multi-project`
2. Start it:  
   `make start`
3. Test it on your browser:
  - http://app.p1.localhost
  - http://app.p2.localhost
  - http://traefik.localhost

> **NOTE:** You need [Docker-Compose][dc] running on your laptop, and port `80` to be available.

> 😫 In case you are **working on a Windows machine** (I feel sorry for you) and can't enjoy [Make][make], try one of the following steps:
> 
> - Use [git bash](https://www.atlassian.com/git/tutorials/> git-bash) to execute the commands
> - Run it under [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install)
> - Read the Docker-Compose command from the `Makefile` and execute it yourself from each project's terminal session

## Projects Structure

This Git project simulates 3 different Docker-Compose projects, each is hosted in its own project folder:

- `/project1` runs a static website on [NGiNX][nginx]
- `/project2` runs a static website on [NGiNX][nginx]
- `/proxy` runs the Traefik instance

In each project you can open and read the relative `docker-compose.yml`.

👉 Project1 and Project2 are extremely simple examples, the point here is simply to drive traffic to them, not to make them complicated 👈

## Run a Static Website on NGiNX

> Skip this part if you know how to use Docker already, this is basic (but useful) stuff!

Running [NGiNX][nginx] on [Docker][docker] allows for the easiest possible way I can imagine for running static websites.

Firts, you should create an `/html` folder with your website inside. In this example, I've created a basic `index.html` that NGiNX is going to use as default entry point.

Second, you can run in with a simple `docker-compose.yml` by mapping your `html` folder inside the container's:

```yml
# docker-compose.yml
version: "3.8"
services:
  app:
    image: nginx
    volumes:
      - ./html:/usr/share/nginx/html/:ro
    ports:
      - "8080:80"
```

👉 This is the approach we take in `/project1`

You can also try a different angle, and **build a custom Docker Image** that contains your website.

You still need to create an `/html` folder and place your website in there.

Then, you can write your `Dockerfile` that is the receipt to build your custom image:

```Dockerfile
# Dockerfile
FROM nginx
ADD html /usr/share/nginx/html
```

At last, you can run this image directly via Docker:

```bash
# Build the image:
docker build -t myweb .

# Run the container:
docker run -p 8080:80 myweb
```

Or via Docker-Compose:

```yml
# docker-compose.yml
version: "3.8"
services:
  app:
    build: .
    ports:
      - "8080:80"
```

[traefik]: https://traefik.io/
[dc]: https://docs.docker.com/compose/
[docker]: https://www.docker.com/get-started/
[nginx]: https://www.nginx.com/
[make]: https://www.gnu.org/software/make/