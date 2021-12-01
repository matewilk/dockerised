# Dockerised NR dev env
This repo contains dockerised New Relic dev environment setup for OHI (on host integration)
testing and development.

The [docker-compose](/docker-compose.yaml) file contains an example of how any NR OHI can be mounted to a docker container
build from `newrelic/infrastructure-bundle:latest` image.

This particular repo shows how you can test (and modify) `nri-varnish` New Relic [varnish integration](https://github.com/newrelic/nri-varnish).
But you can mount any other available New Relic OHI (like PostgreSQL, MySQL, Nagios, Kafka an many more, you can find the full list [here](https://docs.newrelic.com/docs/infrastructure/host-integrations/host-integrations-list/))

### Environment
Docker-compose file in this repo creates the following architecture:

![docker-compose-diagram](https://user-images.githubusercontent.com/6328360/144242659-7ba8005f-c2e8-445f-afa3-e7467b6f04cc.png)

The most important part of the above diagram is the `New Relic Infrastructure` agent container and the mounted `nri-varnish`. 
The OHI (`nri-varnish`) is mounted from your local machine, you need to have the repo downloaded to your local machine and this is how it's mounted in the `docker-compose.yaml`:

```yaml
...
privileged: true
volumes:
  - "/:/host:ro"
  - "/var/run/docker.sock:/var/run/docker.sock"
  # Mount local binary
  - "../../nri-varnish/bin/nri-varnish:/var/db/newrelic-infra/newrelic-integrations/bin/nri-varnish"
...
```
The last volume is the cloned github `nri-varnish` repo in a different directory on your local machine (in this case, two directories up).
Note that the `nri-varnish/bin/nri-varnish` binary file is being mounted at `/var/db/newrelic-infra/newrelic-integrations/bin/nri-varnish`

You can modify a local (on your machine) version of any OHI mounted and see whether it works as expected.

### POC

Other components on the diagram like `Varnish` and `HTTP Server` are here to prove the viability of this POC.
In short, there is the `Varnish` instance in front of the `HTTP Server` which redirects all the requests from port `8080` to port `8000` if there is cache miss.

`New Relic Infra` agent with `nri-varnish` integration, run `varnishstat -j` command against the `Varnish` container and send data to New Relic.

Bear in mind, there are certain configuration files which are specific to this use case. 
If you decide to use it with other OHIs there will have to be certain amendments made based on the use case and OHI.