# The `mlan/gitweb` repository

![travis-ci test](https://img.shields.io/travis/mlan/docker-gitweb.svg?label=build&style=popout-square&logo=travis)
![image size](https://img.shields.io/microbadger/image-size/mlan/gitweb.svg?label=size&style=popout-square&logo=docker)
![docker stars](https://img.shields.io/docker/stars/mlan/gitweb.svg?label=stars&style=popout-square&logo=docker)
![docker pulls](https://img.shields.io/docker/pulls/mlan/gitweb.svg?label=pulls&style=popout-square&logo=docker)

This (non official) repository provides read only [gitweb](https://git-scm.com/docs/gitweb)

## Features

Feature list follows below

- [gitweb](https://git-scm.com/docs/gitweb)

## Tags

The breaking.feature.fix [semantic versioning](https://semver.org/)
used. In addition to the three number version number you can use two or
one number versions numbers, which refers to the latest version of the 
sub series. The tag `latest` references the build based on the latest commit to the repository.

The `mlan/gitweb` repository contains a multi staged built. You select which build using the appropriate tag from `base` and `full`.

To exemplify the usage of the tags, lets assume that the latest version is `1.0.0`. In this case `latest`, `1.0.0`, `1.0`, `1`, `full`, `full-1.0.0`, `full-1.0` and `full-1` all identify the same image.

# Usage


```bash
docker run -d --name test-gitweb -v test-repo-data:/var/lib/git:ro -p 127.0.0.1:8080:80 mlan/gitweb
```

## Docker compose example


```yaml
version: '3.7'

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
File with project list; by default, simply scan the projectroot dir.
Default: `PROJECTS_LIST=/var/lib/git/projects.list`

## Persistent storage

By default, docker will store the configuration and run data within the container. This has the drawback that the configurations and queued and quarantined mail are lost together with the container should it be deleted. It can therefore be a good idea to use docker volumes and mount the run directories and/or the configuration directories there so that the data will survive a container deletion.

To facilitate such approach, to achieve persistent storage, the configuration and run directories of the services has been consolidated to `/srv/etc` and `/srv/var` respectively.  So if you to have chosen to use both persistent configuration and run data you can run the container like this:

```
docker run -d --name mail-mta -v mail-mta:/srv -p 127.0.0.1:25:25 mlan/postfix-amavis
```
