# The `mlan/gitweb` repository

![travis-ci test](https://img.shields.io/travis/mlan/docker-gitweb.svg?label=build&style=flat-square&logo=travis)
![docker build](https://img.shields.io/docker/cloud/build/mlan/gitweb.svg?label=build&style=flat-square&logo=docker)
![image size](https://img.shields.io/docker/image-size/mlan/gitweb.svg?label=size&style=flat-square&logo=docker)
![docker stars](https://img.shields.io/docker/stars/mlan/gitweb.svg?label=stars&style=flat-square&logo=docker)
![docker pulls](https://img.shields.io/docker/pulls/mlan/gitweb.svg?label=pulls&style=flat-square&logo=docker)

This (non official) repository provides read only [gitweb](https://git-scm.com/docs/gitweb), which is used to browse git repositories.

## Features

Feature list follows below

- [gitweb](https://git-scm.com/docs/gitweb), read-only
- Makefile which can build images and do some management and testing
- Health check
- Small image size based on [Alpine Linux](https://alpinelinux.org/)
- Demo based on `docker-compose.yml` and `Makefile` files

## Tags

The MAJOR.MINOR.PATCH [SemVer](https://semver.org/)
is used. In addition to the three number version number you can use two or
one number versions numbers, which refers to the latest version of the sub series.
The tag `latest` references the build based on the latest commit to the repository.

To exemplify the usage of the tags, lets assume that the latest version is `1.0.0`. In this case `latest`, `1.0.0`, `1.0`, `1`, all identify the same image.

# Usage
```bash
docker run -d --name test-gitweb -v test-repo-data:/var/lib/git:ro -p 127.0.0.1:8080:80 mlan/gitweb
```

## Docker compose example
```yaml
version: '3'

services:
   repo:
    image: jgiannuzzi/gitolite
    ports:
      - "localhost:22:22"
    env_file:
      - .init.env
    volumes:
      - test-repo-data:/var/lib/git

  repo-gui:
    image: mlan/gitweb
    ports:
      - "localhost:8080:80"
    depends_on:
      - repo
    volumes:
      - test-repo-data:/var/lib/git:ro

volumes:
  test-repo-data:
```

## Environment variables

When you start the `mlan/gitweb` container, you can configure gitweb by passing one or more environment variables or arguments on the docker run command line.

#### `PROJECTROOT`

The directories where your projects are. Must not end with a slash.
Default: `PROJECTROOT=/var/lib/git/repositories`

#### `PROJECTS_LIST`

Define which file gitweb reads to learn the git projects. If set to empty string; gitweb simply scan the `PROJECTROOT` directory.
Default: `PROJECTS_LIST=/var/lib/git/projects.list`

## Persistent storage

By default, docker will store the configuration and run data within the container. This has the drawback that the configuration and data are lost together with the container should it be deleted. It can therefore be a good idea to use docker volumes and mount the configuration and data directories there so that the data will survive a container deletion.

Such volume can be shared by the container managing the git repositories and the `mlan/gitweb` container, see examples below.

### Gitolite configuration

We start by assuming that the volume `test-repo-data`, which will hold all git repository data, is mounted by the gitolite container at the flowing location: `test-repo-data:/var/lib/git`. This volume is now also mounted, read-only is sufficient, by the `mlan/gitweb` container. To allow gitweb to locate the repositories, the environment variables are set to: `PROJECTROOT=/var/lib/git/repositories` and `PROJECTS_LIST=/var/lib/git/projects.list`, see docker-compose file above and example below.

```bash
docker run -d --name test-gitweb -v test-repo-data:/var/lib/git:ro -e PROJECTROOT=/var/lib/git/repositories -e PROJECTS_LIST=/var/lib/git/projects.list -p 127.0.0.1:8080:80 mlan/gitweb
```
