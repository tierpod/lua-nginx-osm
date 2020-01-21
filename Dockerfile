FROM centos:7

COPY misc/centos7-install.sh /root/
RUN /root/centos7-install.sh \
    && yum clean all

ENV LUA=/usr/local/openresty/luajit/bin/luajit

CMD ["/bin/sh"]
