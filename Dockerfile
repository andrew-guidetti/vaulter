FROM gliderlabs/alpine:latest
RUN apk-install bash curl
ADD ./send2vault.sh /send2vault.sh
ENTRYPOINT ["/send2vault.sh"]

