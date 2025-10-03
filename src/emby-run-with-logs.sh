#!/usr/bin/with-contenv sh

# Set up permissions
if [ "$(ls -nd /config | tr -s '[:space:]' | cut -d' ' -f3)" -ne "$UID" ] || [ "$(ls -nd /config | tr -s '[:space:]' | cut -d' ' -f4)" -ne "$GID" ]; then
  chown "$UID":"$GID" -R /config
fi

# Set up GIDLIST for DRI devices
for d in $(find /dev/dri -type c 2>/dev/null); do
  gid=$(stat -c %g "${d}")
  [ -z "${GIDLIST}" ] && GIDLIST=${gid} || GIDLIST="${GIDLIST},${gid}"
done 

# Start EmbyServer and log tailing together
if [ -n "$(uname -a | grep -q synology)" ] || [ "$IGNORE_VAAPI_ENABLED_FLAG" = "true" ]; then
  s6-applyuidgid -U /system/EmbyServer \
      -programdata /config \
      -ffdetect /bin/ffdetect \
      -ffmpeg /bin/ffmpeg \
      -ffprobe /bin/ffprobe \
      -ignore_vaapi_enabled_flag \
      -restartexitcode 3 &
else
  s6-applyuidgid -U /system/EmbyServer \
      -programdata /config \
      -ffdetect /bin/ffdetect \
      -ffmpeg /bin/ffmpeg \
      -ffprobe /bin/ffprobe \
      -restartexitcode 3 &
fi

# Start log tailing after Emby starts
sleep 5
/usr/local/bin/tail-logs.sh
