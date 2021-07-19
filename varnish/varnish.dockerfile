FROM ubuntu:20.04

# install necessary modules
RUN apt update
RUN apt install sudo
RUN apt install -y gnupg2
RUN apt install -y curl
RUN apt install -y tar
RUN apt install -y wget
RUN apt install -y systemd

# install NR infra agent
#RUN curl -Ls https://raw.githubusercontent.com/newrelic/newrelic-cli/master/scripts/install.sh | bash && sudo NEW_RELIC_API_KEY=NRAK-BQLYWXKV8HEUHK7Y24Z661XVNDV NEW_RELIC_ACCOUNT_ID=2674886 NEW_RELIC_REGION=EU /usr/local/bin/newrelic install --skipIntegrations --skipLoggingInstall --skipApm
# Add the New Relic Infrastructure Agent gpg key \
#   RUN curl -s https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | sudo apt-key add -
# Create a configuration file and add your license key \
#   RUN echo "license_key: " | sudo tee -a /etc/newrelic-infra.yml
# Create the agent’s yum repository \
#   RUN printf "deb [arch=amd64] https://download.newrelic.com/infrastructure_agent/linux/apt focal main" | sudo tee -a /etc/apt/sources.list.d/newrelic-infra.list
# Update your apt cache \
#   RUN sudo apt update
# Run the installation script \
#   RUN sudo apt install newrelic-infra -y

# RUN curl -OJ https://download.newrelic.com/infrastructure_agent/binaries/linux/amd64/newrelic-infra_linux_1.9.7_amd64.tar.gz
# RUN tar -xf newrelic-infra_linux_1.9.7_amd64.tar.gz
# RUN cp ./newrelic-infra/etc/init_scripts/systemd/newrelic-infra.service /etc/systemd/system/newrelic-infra.service
# ADD newrelic-infra.yml /etc/newrelic-infra.yml

# install GO lang
RUN apt install -y gcc make
RUN DEBIAN_FRONTEND=noninteractive apt-get install -qq golang-go
RUN go version

# install varnish
RUN apt install -y varnish
# copy vanish config file
COPY /varnish/default.vcl /etc/varnish

# install OHI nri-varnish
RUN apt install -y git
RUN git clone https://github.com/newrelic/nri-varnish
# config file seems to do nothing as it tries to pick up default varnisg.params location
COPY /nri-varnish/varnish-config.yml /nri-varnish/varnish-config.yml
# /etc/default/varnish should be a dir (accoring to NR docs) but it's a file
# RUN cp /etc/default/varnish /etc/default/varnish.params
# RUN cp /nri-varnish/src/testdata/varnish.params /etc/default/varnish.params
COPY /nri-varnish/varnish.params /etc/default/varnish.params
# removing varnish file to make it a dir as /bin executable requires
RUN rm -rf /etc/default/varnish
# crating a directory instead of the abouve file
RUN mkdir /etc/default/varnish
# placing varnish.params in that directory (as executable requires?)
RUN cp /etc/default/varnish.params /etc/default/varnish/varnish.params

RUN cd nri-varnish && make clean && make compile

EXPOSE 8080

# CMD sudo /etc/init.d/varnish start

CMD /usr/sbin/varnishd -f /etc/varnish/default.vcl -s malloc,1G -T 127.0.0.1:2000 -a 0.0.0.0:8080 -F && /nri-varnish/bin/nri-varnish -instance_name TestVarnishInstance