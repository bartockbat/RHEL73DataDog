
FROM registry.access.redhat.com/rhel7

LABEL name="rhel73/datadog" \
      vendor="Datadog" \
      version="" \
      release="" \
      summary="" \
      description="FTP app will do ....." \
### Required labels above - recommended below
      url="https://www.datadog.com" \
      run='docker run -tdi --name ${NAME} ${IMAGE}' \
      io.k8s.description=" ....." \
      io.k8s.display-name="" \
      io.openshift.expose-services="" \
      io.openshift.tags=""


COPY help.1 /help.1
RUN mkdir -p /licenses
COPY licenses /licenses

#Adding Datadog repo
COPY datadog.repo /etc/yum.repos.d/datadog.repo

#Adding EPEL Repo for software - pure-ftpd
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

### Add necessary Red Hat repos here
RUN REPOLIST=rhel-7-server-rpms,rhel-7-server-optional-rpms && \
### Add your package needs here
#    yum -y install --disablerepo "*" --enablerepo ${REPOLIST} --setopt=tsflags=nodocs && \
    yum -y update-minimal --disablerepo "*" --enablerepo ${REPOLIST} --setopt=tsflags=nodocs \
--security --sec-severity=Important --sec-severity=Critical

#Update repos here
RUN yum makecache
RUN yum -y remove datadog-agent-base
RUN yum -y install datadog-agent

COPY copyAPIKey.sh /copyAPIKey.sh
RUN ./copyAPIKey.sh

RUN yum clean all

#ENTRYPOINT ["/etc/init.d/datadog-agent", "restart"] 
ENV AGENTPATH="/opt/datadog-agent/agent/agent.py"
ENV AGENTCONF="/etc/dd-agent/datadog.conf"
ENV DOGSTATSDPATH="/opt/datadog-agent/agent/dogstatsd.py"
ENV KILL_PATH="/opt/datadog-agent/embedded/bin/kill"
ENV AGENTUSER="dd-agent"
ENV PIDPATH="/var/run/dd-agent/"
ENV PROG="datadog-agent"
ENV LOCKFILE=/var/lock/subsys/$PROG
ENV FORWARDERPATH="/opt/datadog-agent/agent/ddagent.py"
ENV TRACEAGENTPATH="/opt/datadog-agent/bin/trace-agent"
ENV SUPERVISORD_PATH="PATH=/opt/datadog-agent/embedded/bin:/opt/datadog-agent/bin:$PATH /opt/datadog-agent/bin/supervisord"
ENV SUPERVISORCTL_PATH="/opt/datadog-agent/bin/supervisorctl"
ENV SUPERVISOR_CONF="/etc/dd-agent/supervisor.conf"
ENV SUPERVISOR_SOCK="/opt/datadog-agent/run/datadog-supervisor.sock"
ENV SUPERVISOR_PIDFILE="/opt/datadog-agent/run/datadog-supervisord.pid"
ENV COLLECTOR_PIDFILE="/opt/datadog-agent/run/dd-agent.pid"

# Expose DogStatsD, supervisord and trace-agent ports
EXPOSE 8125/udp 9001/tcp 8126/tcp

#ENTRYPOINT["/etc/init.d/datadog-agent", "start"] 
CMD ["/opt/datadog-agent/bin/supervisord", "-n", "-c", "/etc/dd-agent/supervisor.conf"]
