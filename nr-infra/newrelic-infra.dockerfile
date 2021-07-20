FROM newrelic/infrastructure-bundle:latest
COPY /nr-infra/newrelic-infra.yml /etc/newrelic-infra.yml
COPY /nri-varnish/varnish.params /etc/default/varnish.params
COPY /nri-varnish/varnish-config.yml /etc/newrelic-infra/integrations.d/varnish-config.yml