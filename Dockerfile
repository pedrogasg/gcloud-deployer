FROM alpine:3.6 as build
MAINTAINER Pedro Fillastre pedrogas_g@hotmail.com


ARG GCLOUD_VERSION="189.0.0"

ARG HELM_VERSION="v2.8.1"

ENV FILENAME="helm-${HELM_VERSION}-linux-amd64.tar.gz"


RUN apk add --update ca-certificates \
    && apk add --update -t deps curl tar gzip \
    && apk add bash 

RUN curl -L https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz | tar xvz -C /tmp

RUN curl -L http://storage.googleapis.com/kubernetes-helm/${FILENAME} | tar zxv -C /tmp



FROM docker:latest

COPY --from=build /tmp/google-cloud-sdk /bin/google-cloud-sdk

COPY --from=build /tmp/linux-amd64/helm /bin/helm

RUN apk add --update ca-certificates openssl python\
    && apk add bash

RUN /bin/google-cloud-sdk/install.sh --usage-reporting=false --path-update=true \
    && /bin/google-cloud-sdk/bin/gcloud --quiet components update \
    && /bin/google-cloud-sdk//bin/gcloud --quiet components install kubectl

CMD bash