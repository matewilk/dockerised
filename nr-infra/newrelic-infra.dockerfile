FROM newrelic/infrastructure-bundle:latest
COPY /nr-infra/newrelic-infra.yml /etc/newrelic-infra.yml
COPY /nri-varnish/varnish.params /etc/default/varnish.params
COPY /nri-varnish/varnish-config.yml /etc/newrelic-infra/integrations.d/varnish-config.yml
COPY /nri-varnish/varnish-definition.yml /var/db/newrelic-infra/newrelic-integrations/varnish-definition.yml

# add docker to be able to execute the below hack to talks to another container
RUN apk add docker
# copy varnishstat wrapper which calls "varnish" container (see varnishstat file in the dir)
COPY /nr-infra/varnishstat /usr/bin/varnishstat
# add appropriate privileges to the file
RUN chmod +x /usr/bin/varnishstat