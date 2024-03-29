FROM "ghcr.io/typst/typst:v0.11.0"
RUN apk update && apk add git 
RUN apk --no-cache add msttcorefonts-installer fontconfig && \
    update-ms-fonts && \
    fc-cache -f