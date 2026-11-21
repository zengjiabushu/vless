FROM nginx:alpine
ARG XRAY_VER=26.11.9
RUN apk add --no-cache ca-certificates curl unzip \
 && curl -fsSL -o /tmp/x.zip https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VER}/Xray-linux-64.zip \
 && unzip /tmp/x.zip xray -d /usr/local/bin && chmod +x /usr/local/bin/xray && rm /tmp/x.zip
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENV PORT=8080
EXPOSE 8080
CMD ["/entrypoint.sh"]
