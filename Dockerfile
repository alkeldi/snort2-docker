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
    && cd / && rm -rf daq-2.0.7  daq-2.0.7.tar.gz  snort-2.9.17  snort-2.9.17.tar.gz\
    && apt-get install -y libcrypt-ssleay-perl liblwp-useragent-determined-perl\
    && wget https://github.com/shirkdog/pulledpork/archive/master.tar.gz -O pulledpork-master.tar.gz\
    && tar xzvf pulledpork-master.tar.gz\
    && cd pulledpork-master\
    && sudo cp pulledpork.pl /usr/local/bin\
    && sudo chmod +x /usr/local/bin/pulledpork.pl\
    && sudo cp etc/*.conf /etc/snort\
    && cd .. && rm -rf pulledpork-master pulledpork-master.tar.gz\
    && sed -i "s/rule_path=\/usr\/local\/etc\/snort\/rules\/snort.rules/rule_path\=\/etc\/snort\/rules\/snort.rules/"  /etc/snort/pulledpork.conf\
    && sed -i "s/local_rules\=\/usr\/local\/etc\/snort\/rules\/local.rules/local_rules\=\/etc\/snort\/rules\/local.rules/"  /etc/snort/pulledpork.conf\
    && sed -i "s/sid_msg\=\/usr\/local\/etc\/snort\/sid-msg.map/sid_msg=\/etc\/snort\/sid-msg.map/"  /etc/snort/pulledpork.conf\
    && sed -i "s/sid_msg_version=1/sid_msg_version=2/"  /etc/snort/pulledpork.conf\
    && sed -i "s/config_path\=\/usr\/local\/etc\/snort\/snort.conf/config_path\=\/etc\/snort\/snort.conf/"  /etc/snort/pulledpork.conf\
    && sed -i "s/distro=FreeBSD-12/distro=Ubuntu-18-4/"  /etc/snort/pulledpork.conf\
    && sed -i "s/block_list=\/usr\/local\/etc\/snort\/rules\/iplists\/default.blocklist/black_list=\/etc\/snort\/rules\/iplists\/black_list.rules/"  /etc/snort/pulledpork.conf\
    && sed -i "s/IPRVersion=\/usr\/local\/etc\/snort\/rules\/iplists/IPRVersion=\/etc\/snort\/rules\/iplists/"  /etc/snort/pulledpork.conf\
    && sed -i "s/include \$RULE_PATH\/local.rules/include \$RULE_PATH\/local.rules\ninclude \$RULE_PATH\/snort.rules/"  /etc/snort/snort.conf

