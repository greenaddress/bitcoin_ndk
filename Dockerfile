FROM debian:stretch
COPY /stretch_deps.sh /
RUN /stretch_deps.sh
