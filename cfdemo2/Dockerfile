FROM cfbaseos

COPY cf-res /res

WORKDIR /

# already in the cfbaseos
# RUN install_packages procps unzip

# install cf
RUN /res/software/ColdFusion_2016_WWEJ_linux64.bin -f /res/silent.properties;

# install hf4
RUN /opt/coldfusion2016/jre/bin/java -jar /res/software/hotfix-004-302561.jar -i silent;

# repair permissions
RUN mkdir /opt/coldfusion2016/cfusion/runtime/conf/Catalina/localhost/tmp; \
    chown nobody /opt/coldfusion2016/cfusion/runtime/conf/Catalina/localhost/tmp; \
    chgrp bin /opt/coldfusion2016/cfusion/runtime/conf/Catalina/localhost/tmp

# remove some stuff
RUN rm -f -r /opt/coldfusion2016/uninstall; \
    rm -f -r /opt/coldfusion2016/cfusion/db; \
    rm -f /opt/coldfusion2016/*.log

# install the mysql driver
RUN cp /res/software/mysql-connector-java-*.jar /opt/coldfusion2016/cfusion/lib/

# install certs
RUN echo Installing certificates...; \
    keytool=/opt/coldfusion2016/jre/bin/keytool; \
    cert_keystore=/opt/coldfusion2016/jre/lib/security/cacerts; \
    cert_storepass=changeit; \
    for cert in /res/certs/*.crt; do \
        ${keytool} -v -importcert -alias ${cert} -file ${cert} -keystore ${cert_keystore} -storepass ${cert_storepass} -noprompt 2>&1; \
    done

# other things you might do at this point is install a JDK and
# compile some Java components if you have any

#
# STAGE 2
#
# using multi-staged builds:
# https://docs.docker.com/engine/userguide/eng-image/multistage-build/#use-multi-stage-builds
#

FROM cfbaseos

# already in the cfbaseos
# RUN install_packages procps;

# copy the cf install from stage 0
COPY --from=0 /opt /opt

# inject cf config
COPY cf/adminconfig.xml /opt/coldfusion2016/cfusion/lib/adminconfig.xml
COPY cf/jvm.config /opt/coldfusion2016/cfusion/bin/jvm.config
COPY cf/server.xml /opt/coldfusion2016/cfusion/runtime/conf/server.xml
COPY cf/neo-*.xml /opt/coldfusion2016/cfusion/lib/
COPY cf/seed.properties /opt/coldfusion2016/cfusion/lib/seed.properties

# correct all the file permissions for the CF user (CF runs as 'nobody' by default)
# permissions get corrupted as part of the COPY from stage 0 operation above (may be a Windows only issue)
RUN chown -R nobody /opt/coldfusion2016; \
    chgrp -R bin /opt/coldfusion2016

# create web root (this corresponds to configuration in server.xml)
RUN mkdir /var/www

# inject the source code
COPY www /var/www

# make these ports available
EXPOSE 5005 8500 8577 8543

# optionally label the image
LABEL description='ColdFusion 2016 Server'

# container startup command (it's important this blocks so the container doesn't exit)
CMD /opt/coldfusion2016/cfusion/bin/coldfusion start; \
    tail -f /opt/coldfusion2016/cfusion/logs/coldfusion-out.log