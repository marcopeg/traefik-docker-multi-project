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

## Quick Start

1. Clone the repo:  
   ```git clone git@github.com:marcopeg/traefik-docker-multi-project.git```
2. Start it:  
   ```make start```
3. Test it on your browser:
  - http://app.p1.localhost
  - http://app.p2.localhost
  - http://traefik.localhost


[traefik]: https://traefik.io/
[dc]: https://docs.docker.com/compose/
[docker]: https://www.docker.com/get-started/
[nginx]: https://www.nginx.com/