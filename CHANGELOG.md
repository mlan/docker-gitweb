# 1.1.0

- Allow env variable for the base URL.
- Allow env viarable for the site name.
- Enable gravatars.
- Enable modern theme.

# 1.0.5

- [github](.github/workflows/testimage.yml) Now use GitHub Actions to test image.
- [demo](demo/Makefile) Now depend on the docker-compose-plugin.
- [demo](demo/Makefile) Fix the broken `-diff` target.

# 1.0.4

- [test](test) Move all tests to separate folder.
- [docker](README.md) Fixed badges.

# 1.0.3

- [nginx](Dockerfile) Rebuild with new version.

# 1.0.2

- [docker](src/docker/bin/docker-entrypoint.sh) Now use entry.d and exit.d.

# 1.0.1

- Nginx is flooding the docker log, so setting `access_log off;`.

# 1.0.0

- Initial release.
- Honor environment variables PROJECTROOT and PROJECTS_LIST.
- Including a demo.
