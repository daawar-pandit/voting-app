FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && \
    apt-get install -y wget tar && \
    apt-get clean


RUN wget https://github.com/prometheus/prometheus/releases/download/v2.54.1/prometheus-2.54.1.linux-amd64.tar.gz && \
    tar -xvf prometheus-2.54.1.linux-amd64.tar.gz && \
    mv prometheus-2.54.1.linux-amd64 /opt/prometheus && \
    rm prometheus-2.54.1.linux-amd64.tar.gz


WORKDIR /opt/prometheus


COPY prometheus.yml /opt/prometheus/prometheus.yml


RUN mkdir -p /opt/prometheus/data


EXPOSE 9090


ENTRYPOINT ["/opt/prometheus/prometheus"]
CMD ["--config.file=/opt/prometheus/prometheus.yml", "--storage.tsdb.path=/opt/prometheus/data"]
