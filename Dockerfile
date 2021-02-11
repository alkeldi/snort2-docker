FROM ubuntu:18.04
RUN apt-get clean -y\
    && apt-get update -y\
    && apt-get upgrade -y\
    && apt-get install sudo -y\
    && apt-get install wget -y\
    && apt-get install vim -y\
    && sudo groupadd snort\
    && sudo useradd snort -m -r -c SNORT_IDS -g snort\
    && usermod -s /bin/bash -aG sudo snort\
    && echo 'root:toor' | chpasswd\
    && echo 'snort:snort' | chpasswd\
    && apt-get install net-tools -y\
    && apt-get install iputils-ping -y\
    && apt-get install -y build-essential autotools-dev libdumbnet-dev\
        libluajit-5.1-dev libpcap-dev libpcre3-dev zlib1g-dev pkg-config\
        libhwloc-dev bison flex zlib1g-dev liblzma-dev openssl libssl-dev\
        libnghttp2-dev cmake\
    && echo "post-up ethtool -K eth0 gro off" >> /etc/network/interfaces\
    && echo "post-up ethtool -K eth0 lro off" >> /etc/network/interfaces\
    && wget https://snort.org/downloads/snort/daq-2.0.7.tar.gz\
    && tar -xvzf daq-2.0.7.tar.gz\
    && cd daq-2.0.7\
    && ./configure && make && make install\
    && cd ..\
    && wget https://www.snort.org/downloads/snort/snort-2.9.17.tar.gz\
    && tar xvzf snort-2.9.17.tar.gz\
    && cd snort-2.9.17\
    && ./configure --enable-sourcefire && make && make install && ldconfig\
    && ln -s /usr/local/bin/snort /usr/sbin/snort\
    && mkdir /etc/snort /etc/snort/rules /etc/snort/rules/iplists\
        /etc/snort/preproc_rules /usr/local/lib/snort_dynamicrules\
        /etc/snort/so_rules /var/log/snort /var/log/snort/archived_logs\
    && touch /etc/snort/rules/iplists/black_list.rules\
        /etc/snort/rules/iplists/white_list.rules /etc/snort/rules/local.rules\
        /etc/snort/sid-msg.map\
    && chmod -R 5775 /etc/snort /var/log/snort /var/log/snort/archived_logs\
        /etc/snort/so_rules /usr/local/lib/snort_dynamicrules\
    && chown -R snort:snort /etc/snort /var/log/snort /usr/local/lib/snort_dynamicrules\
    && cd etc\
    && cp *.conf* /etc/snort && cp *.map /etc/snort && cp *.dtd /etc/snort\
    && cd ../src/dynamic-preprocessors/build/usr/local/lib/snort_dynamicpreprocessor\
    && cp * /usr/local/lib/snort_dynamicpreprocessor\
    && sed -i "s/include \$RULE\_PATH/#include \$RULE\_PATH/" /etc/snort/snort.conf\
    && sed -i "s/var RULE_PATH ..\/rules/var RULE_PATH \/etc\/snort\/rules/" /etc/snort/snort.conf\
    && sed -i "s/var SO_RULE_PATH ..\/rules/var SO_RULE_PATH \/etc\/snort\/so_rules/" /etc/snort/snort.conf\
    && sed -i "s/var PREPROC_RULE_PATH ..\/rules/var PREPROC_RULE_PATH \/etc\/snort\/preproc_rules/" /etc/snort/snort.conf\
    && sed -i "s/var WHITE_LIST_PATH ..\/rules/var WHITE_LIST_PATH \/etc\/snort\/rules\/iplists/" /etc/snort/snort.conf\
    && sed -i "s/var BLACK_LIST_PATH ..\/rules/var BLACK_LIST_PATH \/etc\/snort\/rules\/iplists/" /etc/snort/snort.conf\
    && sed -i "s/#include \$RULE\_PATH\/local.rules/include \$RULE\_PATH\/local.rules/" /etc/snort/snort.conf\
    && cd / && rm -rf daq-2.0.7  daq-2.0.7.tar.gz  snort-2.9.17  snort-2.9.17.tar.gz


