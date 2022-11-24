FROM pauloo23/hadoop:2.7.4

MAINTAINER Paulo <paulobarbosaa23@mail.com>

USER root

# Install Apche Hive
ENV HIVE_VER 2.3.3

RUN wget -O apache-hive.tar.gz https://archive.apache.org/dist/hive/hive-$HIVE_VER/apache-hive-$HIVE_VER-bin.tar.gz && \
tar -xzf apache-hive.tar.gz -C /usr/local/ && rm apache-hive.tar.gz

RUN ln -s /usr/local/apache-hive-$HIVE_VER-bin /usr/local/hive

ENV HIVE_HOME /usr/local/hive
ENV PATH $PATH:$HIVE_HOME/bin

RUN rm -f /usr/local/hadoop-2.7.4/share/hadoop/common/lib/slf4j-log4j12-1.7.10.jar
#ADD mysql-connector-java-5.1.44-bin.jar $HIVE_HOME/lib
RUN wget -P $HIVE_HOME/lib/ https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.44/mysql-connector-java-5.1.44.jar

ADD conf/hive-site.xml $HIVE_HOME/conf

ADD bootstrap.sh /etc/bootstrap.sh

EXPOSE 10000
EXPOSE 1001
EXPOSE 1002
WORKDIR $HIVE_HOME

CMD ["/etc/bootstrap.sh", "-d"]
