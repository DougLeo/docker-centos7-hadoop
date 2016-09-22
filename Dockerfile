FROM centos

MAINTAINER leodu

USER root

# install jdk 
ADD jdk-8u101-linux-x64.tar.gz /usr/local
RUN mv /usr/local/jdk1.8.0_101 /usr/local/jdk1.8

# install hadoop
ADD hadoop-2.6.0.tar.gz /usr/local
RUN mv /usr/local/hadoop-2.6.0 /usr/local/hadoop

# set environment variable
ENV JAVA_HOME=/usr/local/jdk1.8
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$JAVA_HOME/bin

# install ssh
RUN yum install -y openssh-server openssh-clients which
RUN echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
RUN sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
# RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
RUN mkdir /var/run/sshd
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key

RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

RUN sed -i 's/export JAVA_HOME.*$/export JAVA_HOME=\/usr\/local\/jdk1.8/g' /usr/local/hadoop/etc/hadoop/hadoop-env.sh

ADD ssh_config /etc/ssh/ssh_config
ADD hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
ADD core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
ADD mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
ADD yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
ADD slaves $HADOOP_HOME/etc/hadoop/slaves
ADD start-hadoop.sh /root/start-hadoop.sh
ADD run-wordcount.sh /root/run-wordcount.sh

RUN chmod +x /root/start-hadoop.sh && \
    chmod +x /root/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]

