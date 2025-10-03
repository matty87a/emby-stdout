FROM emby/embyserver:latest

COPY tail-logs.sh /usr/local/bin/tail-logs.sh
RUN chmod +x /usr/local/bin/tail-logs.sh

COPY emby-run-with-logs.sh /etc/s6/services/emby-server/run
RUN chmod +x /etc/s6/services/emby-server/run
