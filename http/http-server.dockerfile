FROM ubuntu:20.04

# check if python exists
RUN apt update
RUN apt install -y python
RUN python --version

EXPOSE 8000

CMD python -m SimpleHTTPServer 8000