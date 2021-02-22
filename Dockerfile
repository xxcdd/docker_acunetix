FROM debian:jessie
ARG version=210129162
# --build-arg version=210129162
LABEL maintainer="https://github.com/xxcdd/docker_acunetix" \
    name="acunetix_13:${version}" \
    description="acunetix_13:${version} login : admin@admin.com/Abcd1234" \
    docker.run.cmd="docker run -d -p 3443:3443 acunetix_13:${version}"
ENV DEBIAN_FRONTEND noninteractive
ENV acunetix_install = acunetix_13.0.${version}_x64.sh

RUN set -xe \
    && sed -i 's|security.debian.org/debian-security|mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list \
    && sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
    && apt-get update --fix-missing

# ssh
RUN apt-get -y install openssh-server curl \
    && mkdir -p /var/run/sshd \
    && sed -ri 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config \
    && echo "root:xxcdd" | chpasswd \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
# acunetix
ADD acunetix_13.0.${version}_x64.sh /tmp/acunetix_13.0.${version}_x64.sh
ADD wvsc /tmp/wvsc
ADD license_info.json /tmp/license_info.json
ADD install.expect /tmp/install.expect
WORKDIR /tmp
RUN apt-get -y install libgbm1 libxdamage1 libgtk-3-0 libasound2 libnss3 libxss1 sudo bzip2 wget expect libxdamage1 libgtk-3-0 libasound2 libnss3 libxss1 libx11-xcb1;\
    chmod +x /tmp/acunetix_13.0.${version}_x64.sh;\
    chmod +x /tmp/install.expect && expect /tmp/install.expect;\
    cp /home/acunetix/.acunetix/v_${version}/scanner/wvsc /tmp/wvsc.bak;\
    cp /tmp/wvsc /home/acunetix/.acunetix/v_${version}/scanner/;\
    cp /tmp/license_info.json /home/acunetix/.acunetix/data/license/
CMD /etc/init.d/ssh start; su -l acunetix -c /home/acunetix/.acunetix/start.sh
EXPOSE 3443 22