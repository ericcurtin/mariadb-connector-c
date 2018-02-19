FROM debian:9

ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy
ENV ftp_proxy=$ftp_proxy

RUN apt update -y &&\
    apt install -y init cmake g++ lsb-release &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

