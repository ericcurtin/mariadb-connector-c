FROM centos:7

ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy
ENV ftp_proxy=$ftp_proxy

RUN yum install -y epel-release &&\
    yum update -y &&\
    yum install -y cmake make gcc &&\
    yum clean all &&\
    rm -rf /tmp/* /var/tmp/* /var/cache/yum

