# traefik-docker-multi-project

How to use [Traefik][traefik] to drive traffic to independent [docker-compose][dc] projects.

You are about to learn:
- How to run a static website using [Docker][docker] and [NGiNX][nginx]
- How to **run a reverse proxy** with [Traefik][traefik]
- How to setup a _custom newtwork_ in Docker
- How to attach containers to an existing _Docker network_

👉 Before you continue, make sure you go through the "[How to run a _Create React App_ development environment using Docker, Docker-Compose, and Traefik][tutorial1]" tutorial, for it covers the basics of setting up Traefik and we won't repeat it in here.

## Table Of Contents

- [Quick Start](#quick-start)
- [Project Structure](#projects-structure)
- [Run a Static Website on NGiNX](#run-a-static-website-on-nginx)
- [Forget the Ports, Let's use Labels Instead!](#forget-the-ports-lets-use-labels-instead)
- [Customize the Docker Network](#customize-the-docker-network)
- [Using Default Networks](#using-default-networks)

## Quick Start

1. Clone the repo:  
   `git clone git@github.com:marcopeg/traefik-docker-multi-project.git`
2. Open the project:  
   `cd traefik-docker-multi-project`
3. Start it:  
   `make start`
4. Test it on your browser:
  - http://app.project1.localhost
  - http://app.project2.localhost
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

## Forget the Ports, Let's use Labels Instead!

Following the same predicaments of the [Run CRA with Traefik][tutorial1] tutorial, you can remove the `ports` definition from your `docker-compose.yml` and use `labels` to configure a proxy via [Traefik][traefik] instead:

```yml
# /project1/docker-compose.yml
version: "3.8"
services:
  app:
    image: nginx
    volumes:
      - ./html:/usr/share/nginx/html/:ro
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app_project1.rule=Host(`app.project1.localhost`)"
```

> 🔥 When it comes to this configuration, you must be careful in providing **names that will be unique** across the entire set of projects that you want to expose via Traefik.

In this label, we use `app_p1` as router's name:  
`traefik.http.routers.app_p1.rule`

It is the combination of:  
`{container-name}_{project-name}`

> 😬 Most of the troubles I ran into while researching for this tutorial was about naming conflicts!

**IMPORTANT:** If you run your project now, it will work. But it **is not going to be visibile** from the browser as you removed the `ports` definition.

👉 The `labels` alone won't do much until you run the Traefik proxy!

## Run Traefik Proxy

The `/proxy/docker-compose.yml` is practically a copy/paste from the [Run CRA with Traefik][tutorial1] tutorial.

🙏 Please refer to that [documentation](https://github.com/marcopeg/cra-docker-traefik#add-the-reverse-proxy) 🙏

## Customize the Docker Network

We finally reach the interesting part of this tutorial: networking.

[Docker Networking](https://docs.docker.com/network/) is a rather complicated subject, expecially if you plan to use Docker in production.

Lukily for me, the scope of this tutorial is to use Docker to **improve your Development Experience**, and your local environment. So I'll keep it rather simple 😇.

When you run a Docker-Compose project, **Docker automagically creates a network that is private to such project**. Docker uses the project's folder name as network name.

Do far, our 3 projects run in 3 independent networks, therefore the containers are invisible to one another with the following consequences:

1. You can not make direct calls between containers
2. Traefik can't read labels from containers in different networks

Although we don't really use container-to-container calls in this tutorial, we do want point n.2 to work!

The solution is a 2 steps process:

1. Give an explicit configuration to Traefik's network
2. Tell our projects to use Traefik's network instead of creating their own

Open the `proxy/docker-compose.yml` and add the network configuration:

```yml
# Set a custom name for the Traefik's project network:
networks:
  default:
    name: traefik
```

Then do the same with the two projects, but use this time use the following code:

```yml
# Configure the project to use an external network:
networks:
  default:
    external: true
    name: traefik
```

Run the project (`make start`), and voilá 🎉!

## Using Default Networks

There is a way to use an even easier configuration.

You could try to remove the network configuration from the Traefik project, then change the project's config to:

```yml
# Configure the project to use an external network:
networks:
  default:
    external: true
    name: traefik_default
```

The network name `traefik_default` comes from `{project-name}_{network_name}`:

- Docker uses the folder's name as `project-name`
- Docker created a default network unless different configuration is given, and it calls it `default`

🔥 Although you could have saved a few lines of YML with this approach, I strongly vouch against it because you are never in control of folder's names when you distribute a project to a large team.

> Git repositories can be cloned into any folder name, and just this little detail can cause great headaches!

[tutorial1]: https://github.com/marcopeg/cra-docker-traefik#readme
[traefik]: https://traefik.io/
[dc]: https://docs.docker.com/compose/
[docker]: https://www.docker.com/get-started/
[nginx]: https://www.nginx.com/
[make]: https://www.gnu.org/software/make/