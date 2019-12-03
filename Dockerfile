FROM debian:buster@sha256:79f0b1682af1a6a29ff63182c8103027f4de98b22d8fb50040e9c4bb13e3de78
COPY /buster_deps.sh /
RUN /buster_deps.sh
