FROM rockylinux/rockylinux:8

ENV COBBLER_RPM cobbler-3.3.3-1.el8.noarch.rpm
ENV DATA_VOLUMES "/var/lib/cobbler /var/www/cobbler /var/lib/dhcpd"

RUN (cd /lib/systemd/system/sysinit.target.wants/; \
  for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
  rm -f /lib/systemd/system/multi-user.target.wants/*;\
  rm -f /etc/systemd/system/*.wants/*;\
  rm -f /lib/systemd/system/local-fs.target.wants/*; \
  rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
  rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
  rm -f /lib/systemd/system/basic.target.wants/*;\
  rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

COPY $COBBLER_RPM /$COBBLER_RPM
RUN set -ex \
  # Use USTC mirror if necessary
  # && sed -e 's|^mirrorlist=|#mirrorlist=|g' \
  #   -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.ustc.edu.cn/rocky|g' \
  #   -i.bak \
  #   /etc/yum.repos.d/Rocky-AppStream.repo \
  #   /etc/yum.repos.d/Rocky-BaseOS.repo \
  #   /etc/yum.repos.d/Rocky-Extras.repo \
  #   /etc/yum.repos.d/Rocky-PowerTools.repo \
  && dnf install -y epel-release \
  && dnf install -y /$COBBLER_RPM \
  && dnf install -y dhcp-server pykickstart yum-utils debmirror git rsync-daemon \
          ipxe-bootimgs shim grub2-efi-x64-modules \
  # Fix the permission of shim-x64
  && chmod a+r -R /boot/efi/EFI \
  && dnf clean all \
  # fix debian repo support
  && sed -i "s/^@dists=/# @dists=/g" /etc/debmirror.conf \
  && sed -i "s/^@arches=/# @arches=/g" /etc/debmirror.conf \
  # backup data volumes
  && for v in $DATA_VOLUMES; do mv $v ${v}.save; done \
  # enable services
  && systemctl enable cobblerd httpd dhcpd tftp rsyncd

# DHCP Server
EXPOSE 67
# TFTP
EXPOSE 69
# Rsync
EXPOSE 873
# Web
EXPOSE 80
# Cobbler
EXPOSE 25151

VOLUME ["/var/lib/cobbler", "/var/www/cobbler", "/var/lib/dhcpd"]

COPY entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
