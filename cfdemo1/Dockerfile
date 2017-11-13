# base os
FROM bitnami/minideb:latest

# shortcut for apt-get, installs utilities required by cf
RUN install_packages procps unzip

# copy resources
COPY . /res

# install cf
RUN /res/ColdFusion_2016_WWEJ_linux64.bin -f /res/silent.properties

# inject source code
COPY index.cfm /opt/coldfusion2016/cfusion/wwwroot/index.cfm

# expose ports for debugging, http, websockets, secure websockets
EXPOSE 5005 8500 8577 8543

# container startup command
# it's important this blocks so the container doesn't exit
CMD /opt/coldfusion2016/cfusion/bin/coldfusion start; \
    tail -f /opt/coldfusion2016/cfusion/logs/coldfusion-out.log