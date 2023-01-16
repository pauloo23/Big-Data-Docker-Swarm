FROM ubuntu:18.04


##Install JAVA 
RUN apt-get update && apt-get install -y \
    software-properties-common
# Add the "JAVA" ppa
RUN add-apt-repository -y \
    ppa:webupd8team/java

# Install OpenJDK-8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get clean;

# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/oracle-jdk8-installer

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# Install Requirements
# Upgrade installed packages
RUN apt update && apt upgrade -y && apt clean

# install python 3.7.10 (or newer)
RUN apt update && \
    apt install --no-install-recommends -y build-essential software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt install --no-install-recommends -y python3.7 python3.7-dev python3.7-distutils && \
    apt clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y vim curl unzip nano

# Register the version in alternatives (and set higher priority to 3.7)
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2

# Upgrade pip to latest version
RUN curl -s https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3 get-pip.py --force-reinstall && \
    rm get-pip.py


# Install Spark
ENV SPARK_VERSION 3.3.1
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-hadoop2
ENV SPARK_HOME /usr/spark-${SPARK_VERSION}
ENV PYTHONPATH $SPARK_HOME/python/:$PYTHONPATH
ENV PATH = $PATH:$SPARK_HOME/bin
RUN curl -sL --retry 3 \
  "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
  | gunzip \
  | tar x -C /usr/ \
 && mv /usr/$SPARK_PACKAGE $SPARK_HOME \
 && chown -R root:root $SPARK_HOME

##Configure YARN
##ADD config/* /usr/local/hadoop/etc/hadoop/
##ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
##ENV YARN_CONF_DIR /usr/local/hadoop/etc/hadoop

##Add mongoDB conector
ADD jars/* ${SPARK_HOME}/jars/

##add costum config file
RUN chmod 777 -R ${SPARK_HOME}/conf/
ADD conf ${SPARK_HOME}/conf
RUN mkdir -p /opt/spark-events

# Install JupyterLab
RUN pip3 install --upgrade pip
RUN pip3 install pyarrow
RUN pip3 install --no-cache-dir jupyterlab
RUN mkdir $SPARK_HOME/work
RUN chmod -R 777 $SPARK_HOME/work
##Install pyspark for spark version
WORKDIR $SPARK_HOME/python/
RUN pip3 install -e .

##Expose ports 
EXPOSE 4040 8888 7077 6066 8080 18080 8081

## Initiate spark
WORKDIR $SPARK_HOME
