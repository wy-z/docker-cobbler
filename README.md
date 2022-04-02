# Cobbler container image

A Cobbler container image. Up-to-date, easy to maintain and easy to use.

## Version

3.3.2

## How to build

`docker build -t cobbler:3.3.2 .`

## How to use

`docker run -v $PWD/lib:/var/lib/cobbler -v $PWD/www:/var/www/cobbler -v $PWD/dhcpd:/var/lib/dhcpd cobbler:3.3.2`

### Custom settings

`-v path/to/settings.d:/etc/cobbler/settings.d:ro`

### Custom dhcp template

`-v path/to/dhcp.template:/etc/cobbler/dhcp.template:ro`
