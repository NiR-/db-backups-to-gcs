FROM mysql:5.7.25 as base

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      python \
      wget \
    && \
    wget -O /tmp/gcloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-241.0.0-linux-x86_64.tar.gz && \
    tar zxvf /tmp/gcloud-sdk.tar.gz && \
    /google-cloud-sdk/install.sh \
      --usage-reporting false \
      --quiet \
    && \
    ln -s /google-cloud-sdk/bin/gcloud /usr/bin/gcloud && \
    ln -s /google-cloud-sdk/bin/gsutil /usr/bin/gsutil && \
    rm -rf /var/lib/apt/lists/*

############

FROM base as dump

COPY ./backup /usr/sbin/backup

ARG IMAGE_VERSION
ENV IMAGE_VERSION ${IMAGE_VERSION}

CMD ["backup"]

############

FROM base as restore

COPY ./restore /usr/sbin/restore

ARG IMAGE_VERSION
ENV IMAGE_VERSION ${IMAGE_VERSION}

ENTRYPOINT ["restore"]
