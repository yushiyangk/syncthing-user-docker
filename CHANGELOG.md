## Changelog

This project uses a three-part version-number, <var>x</var>.<var>y</var>.<var>z</var>.

The first two parts, <var>x</var>.<var>y</var>, corresponds to the version of the [Syncthing image on Docker Hub](https://hub.docker.com/r/syncthing/syncthing/tags), which usually also matches the first two parts of the Syncthing version.

The final part, <var>z</var>, is incremented when the contents of this Project is updated, and is reset to 0 when any of the preceding parts change.

### 1.29.1

- Fixed: service fails to start when the user's `docker_env` does not already exist

### 1.29.0

- Initial release, using Syncthing 1.29
