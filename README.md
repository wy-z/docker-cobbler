# Cobbler container image

A Cobbler container image. Up-to-date, easy to maintain, and easy to use.

## Version

3.3.2

## Docker hub

[weiyang/docker-cobbler:3.3.2](https://hub.docker.com/r/weiyang/docker-cobbler)

## How to build

```
docker build -t cobbler:3.3.2 .
```

## How to use

```sh
docker run --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	-e SERVER_IP_V4=127.0.0.1 -e ROOT_PASSWORD=Password \
	-v $PWD/lib:/var/lib/cobbler -v $PWD/www:/var/www/cobbler -v $PWD/dhcpd:/var/lib/dhcpd \
	cobbler:3.3.2
```

### Environments

- SERVER_IP_V4: Cobbler server v4 ip
- SERVER_IP_V6: Cobbler server v6 ip
- SERVER: Cobbler server ip or hostname, required, default $SERVER_IP_V4
- ROOT_PASSWORD: Installation (root) password, required

### Custom settings

```sh
-v path/to/settings.d:/etc/cobbler/settings.d:ro
```

### Custom dhcp template

```sh
-v path/to/dhcp.template:/etc/cobbler/dhcp.template:ro
```
