# The `mlan/gitweb` repository

![github action ci](https://img.shields.io/github/actions/workflow/status/mlan/docker-gitweb/testimage.yml?label=build&style=flat-square&logo=github)
![docker version](https://img.shields.io/docker/v/mlan/gitweb?label=version&style=flat-square&logo=docker)
![image size](https://img.shields.io/docker/image-size/mlan/gitweb/latest.svg?label=size&style=flat-square&logo=docker)
![docker pulls](https://img.shields.io/docker/pulls/mlan/gitweb.svg?label=pulls&style=flat-square&logo=docker)
![docker stars](https://img.shields.io/docker/stars/mlan/gitweb.svg?label=stars&style=flat-square&logo=docker)
![github stars](https://img.shields.io/github/stars/mlan/docker-gitweb.svg?label=stars&style=flat-square&logo=github)

Provides a [Gitweb](https://git-scm.com/docs/gitweb) — a Git web interface (web frontend to Git repositories) — docker image (non official).

## Features

- [Gitweb](https://git-scm.com/docs/gitweb), read access only
- Small image size based on [Alpine Linux](https://alpinelinux.org/)
- Health check
- Demo based on `docker-compose.yml` and `Makefile` files

## Tags

The MAJOR.MINOR.PATCH [SemVer](https://semver.org/)
is used. In addition to the three number version number you can use two or
one number versions numbers, which refers to the latest version of the sub series.
The tag `latest` references the build based on the latest commit to the repository.

The `mlan/gitweb` repository contains a multi staged built. You select which build using the appropriate tag from `base` and `full` . The image with the tag `base` contains Gitweb.
The `full` tag also include support for highlighting.

To exemplify the usage of the tags, lets assume that the latest version is `1.0.0`. In this case `latest`, `1.0.0`, `1.0`, `1`, all identify the same image.

# Usage

You can start a `mlan/gitweb` container from the command line. The example below assumes that you are in a git directory and will start a web server that can be accessed on http://localhost:8080.

```bash
docker run -d --name repoweb -e PROJECTS_LIST= -v $(pwd)/.git:/var/lib/git:ro -p 127.0.0.1:8080:80 mlan/gitweb
```

You can also try out the [demo](#demo) that comes with the [github](https://github.com/mlan/docker-gitweb) repository.

## Docker compose example

Using docker compose, the following `docker-compose.yml` file will start a [Gitolite](https://gitolite.com/gitolite/) server and Gitweb server.

```yaml
name: demo

services:
   repo:
    image: jgiannuzzi/gitolite
    ports:
      - "22:22"
    volumes:
      - repo-data:/var/lib/git

  repo-gui:
    image: mlan/gitweb
    ports:
      - "8080:80"
    depends_on:
      - repo
    volumes:
      - repo-data:/var/lib/git:ro

volumes:
  repo-data:
```

For the above example to produce anything interesting the volume `repo-data` must include at least one git repository.

## Demo

This repository contains a `demo` directory which hold the `docker-compose.yml` file as well as a `Makefile` which might come handy. To run the demo first clone the [github](https://github.com/mlan/docker-asterisk) repository.

```bash
git clone https://github.com/mlan/docker-github.git
```

From within the `demo` directory you can start the container simply by typing:

```bash
make up
```

The you can connect to the Gitweb server by typing

```bash
make web
```

When you are done testing you can destroy the test container by typing

```bash
make destroy
```

## Environment variables

When you start the `mlan/gitweb` container, you can configure Gitweb by passing one or more environment variables or arguments on the docker run command line.

#### `PROJECTROOT`

The directories where your projects are. *Must not end with a slash.*
Default: `PROJECTROOT=/var/lib/git/repositories`

#### `PROJECTS_LIST`

Define which file Gitweb reads to learn the git projects. If set to empty string; Gitweb simply scan the `PROJECTROOT` directory.
Default: `PROJECTS_LIST=/var/lib/git/projects.list`

#### `SERVER_NAME`

The nginx [server_name](https://nginx.org/en/docs/http/server_names.html) directive and determine which server block is used for a given request. Since there only one block in this application the server_name is not important and can be anyting but empty.

With gitweb the Nginx server_name is displayed in the browser tab. And since it can be chosen freely, it can be seen to have a decorative function.

## Gitolite

If you have [Gitolie](https://gitolite.com/gitolite/) and Gitweb running on the same machine, you will be able to browse the Gitolite repositories simply by having the services sharing file systems. The [docker compose example](#docker-compose-example) above is doing exactly that.

The volume `repo-data` allow the containers share files. The volume has similar mount point in both containers, `repo-data:/var/lib/git`. The only difference is that it is sufficient to mount it read-only on the Gitweb container. The default values of both environment variables; `PROJECTROOT` and `PROJECTS_LIST` are adequate.

It is of cause also possible to start the Gitweb container using the docker command:

```bash
docker run -d --name repo-gui -v repo-data:/var/lib/git:ro -p 127.0.0.1:8080:80 mlan/gitweb
```

# Implementation

Here some implementation details are presented.

## Container init scheme

When the container is started, execution is handed over to the script [`docker-entrypoint.sh`](src/docker/bin/docker-entrypoint.sh). It has 2 stages; 1) *run* all entry scripts in `/etc/docker/entry.d/`, 2) *execute* command in `CMD ["nginx", "-g", "daemon off;"]`.

The entry scripts are responsible for tasks like, generate configurations, and spawning processes.

## Build assembly

The entry scripts, discussed above, as well as other utility scrips are copied to the image during the build phase. The source file tree was designed to facilitate simple scanning, using wild-card matching, of source-module directories for files that should be copied to image. Directory names indicate its file types so they can be copied to the correct locations. The code snippet in the `Dockerfile` which achieves this is show below.

```dockerfile
COPY	src/*/bin $DOCKER_BIN_DIR/
COPY	src/*/entry.d $DOCKER_ENTRY_DIR/
COPY	src/*/envsubst $DOCKER_ENVSUBST_DIR/
```
