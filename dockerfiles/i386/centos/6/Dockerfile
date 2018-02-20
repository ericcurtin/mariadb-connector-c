FROM i386/centos:6

ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy
ENV ftp_proxy=$ftp_proxy

RUN printf "i686\n" > /etc/yum/vars/arch &&\
    printf "i386\n" > /etc/yum/vars/basearch &&\
    yum install -y epel-release &&\
    yum update -y &&\
    yum install -y upstart cmake make gcc &&\
    yum clean all &&\
    rm -rf /tmp/* /var/tmp/* /var/cache/yum

