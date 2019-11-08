FROM debian:buster@sha256:41f76363fd83982e14f7644486e1fb04812b3894aa4e396137c3435eaf05de88
COPY /buster_deps.sh /
RUN /buster_deps.sh
