# Build script for crun-krun

## Dependencies

- Docker
- Tar
- Gzip

## Build

This will build `crun-binary.tar.gz`:
```shell
git clone https://github.com/raphaelcoeffic/build-crun-krun.git
cd build-crun-krun
./build.sh
```

## Install

```shell
sudo tar xf crun-binary.tar.gz -C /usr/local
sudo ldconfig
```

## Using `krun` runtime

### Docker

Add the following to `/etc/docker/daemon.json`:
```json
{
    "runtimes": {
        "krun": {
            "path": "krun"
        }
    }
}
```

### Podman

The necessary configuration for `krun` is already included in newer Podman versions.
If it isn't in the version you are using, please refer to the
[Podman documentation](https://github.com/containers/common/blob/main/docs/containers.conf.5.md).
