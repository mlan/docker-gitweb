# 1.0.2

- [docker](src/docker/bin/docker-entrypoint.sh) Now use entry.d and exit.d.

# 1.0.1

- Nginx is flooding the docker log, so setting `access_log off;`.

# 1.0.0

- Initial release.
- Honor environment variables PROJECTROOT and PROJECTS_LIST.
- Including a demo.
