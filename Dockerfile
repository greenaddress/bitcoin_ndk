FROM debian:stretch@sha256:58a80e0b6aa4d960ee2a5452b0230c406c47ed30a66555ba753c8e1710a434f5
COPY /stretch_deps.sh /
RUN /stretch_deps.sh
