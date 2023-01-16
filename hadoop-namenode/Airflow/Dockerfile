FROM  pauloo23/pyspark-notebook:3.3.1
LABEL maintainer="paulobarbosaa23@gmail.com"


ENV DEBIAN_FRONTEND=noninteractive

RUN  apt-get update &&  apt-get install -y --no-install-recommends \
        apt-utils \
        freetds-bin \
        ldap-utils \
        libffi6 \
        libsasl2-2 \
        libsasl2-modules \
        libsasl2-dev \
        libsasl2-modules-gssapi-mit \
        libssl1.1 \
        locales  \
        lsb-release \
        sqlite3 \
        unixodbc \
        python3.6-dev \
        libpq-dev \
        build-essential \
        autoconf \
        libtool \
        pkg-config \
        python3-opengl \
        python3-pil \
        python-pyrex \
        python3-pyside.qtopengl \
        idle-python3.6 \
        qt4-dev-tools \
        qt4-designer \
        libqtgui4 \
        libqtcore4 \
        libqt4-xml \
        libqt4-test \
        libqt4-script \
        libqt4-network \
        libqt4-dbus \
        python3-pyqt4 \
        libgle3 \
        libssl-dev 
        
        

RUN pip3 install --no-cache-dir --upgrade pip

ENV AIRFLOW_VERSION=2.5.0
ENV SLUGIFY_USES_TEXT_UNIDECODE=yes
RUN pip3 install "apache-airflow[crypto,celery,postgres,hive,jdbc]==${AIRFLOW_VERSION}" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.5.0/constraints-3.7.txt"
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN pip3 install \
        pandas \
        psycopg2-binary \
        apache-airflow-providers-apache-spark \
        pip-conflict-checker \
        pandas \
        ndg-httpsclient \
        python-decouple 



RUN addgroup --gid 1000 airflow
RUN adduser --uid 1000 --gid 1000 --disabled-password --gecos "Airflow" airflow
RUN usermod -L airflow

ENV AIRFLOW_HOME=/home/airflow
RUN mkdir -p ${AIRFLOW_HOME}
WORKDIR ${AIRFLOW_HOME}
COPY sh sh
RUN chown -R airflow:airflow ${AIRFLOW_HOME}
USER airflow