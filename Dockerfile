FROM python:3.7.6-slim

ARG AIRFLOW_VERSION=1.10.9
ARG AIRFLOW_USER_HOME=/var/lib/airflow

ENV AIRFLOW_HOME=$AIRFLOW_USER_HOME

RUN mkdir $AIRFLOW_USER_HOME && \
  buildDeps='freetds-dev libkrb5-dev libsasl2-dev libssl-dev libffi-dev libpq-dev' \
  apt-get update && \
  apt-get install -yqq --no-install-recommends $buildDeps build-essential default-libmysqlclient-dev && \
  pip install --no-cache-dir apache-airflow[crypto,kubernetes,postgres,gcp,sentry]==${AIRFLOW_VERSION} && \
  # SQLAlchemy fixed version due to https://github.com/apache/airflow/issues/8211
  pip install SQLAlchemy==1.3.15 && \
  apt-get purge --auto-remove -yqq $buildDeps && \
  apt-get autoremove -yqq --purge && \
  rm -rf /var/lib/apt/lists/* 


WORKDIR $AIRFLOW_USER_HOME

COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt --quiet

COPY dags/ ${AIRFLOW_HOME}/dags