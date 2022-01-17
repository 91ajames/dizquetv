#!/bin/bash
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>dizquetv-pi-systemctl.log 2>&1
# Everything below will go to the file 'log.out':

git clone https://github.com/FFmpeg/FFmpeg.git ~/FFmpeg \
  && cd ~/FFmpeg \
  && git checkout n4.2.4 \
  && ./configure \
    --extra-cflags="-I/usr/local/include" \
    --extra-ldflags="-L/usr/local/lib" \
    --extra-libs="-lpthread -lm -latomic" \
    --arch=armel \
    --enable-gmp \
    --enable-gpl \
    --enable-libaom \
    --enable-libass \
    --enable-libdav1d \
    --enable-libdrm \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libkvazaar \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopus \
    --enable-librtmp \
    --enable-libsnappy \
    --enable-libsoxr \
    --enable-libssh \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libzimg \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxml2 \
    --enable-mmal \
    --enable-nonfree \
    --enable-omx \
    --enable-omx-rpi \
    --enable-version3 \
    --target-os=linux \
    --enable-pthreads \
    --enable-openssl \
    --enable-hardcoded-tables \
  && make -j$(nproc) \
  && sudo make install
cd /home/
git clone https://github.com/vexorian/dizquetv.git
cd /home/dizquetv
git checkout 1.2.2

if apt install npm -y ; then
   return
else
   wget https://nodejs.org/dist/v4.2.4/node-v4.2.4-linux-armv6l.tar.gz
   mv node-v4.2.4-linux-armv6l.tar.gz /opt
   cd /opt
   tar -xzf node-v4.2.4-linux-armv6l.tar.gz
   mv node-v4.2.4-linux-armv6l nodejs
   rm node-v4.2.4-linux-armv6l.tar.gz
   ln -s /opt/nodejs/bin/node /usr/bin/node
   ln -s /opt/nodejs/bin/npm /usr/bin/npm
   apt install npm nodejs -y
fi

npm install browserify

if rm /home/dizquetv/dizquetv.sh ; then
   return
else
echo '
#!/bin/bash
cd /home/dizquetv
npm start' >> /home/dizquetv/dizquetv.sh
chmod +x /home/dizquetv/dizquetv.sh
fi

if rm /home/dizquetv/dizquetv.service && rm /etc/systemd/system/dizquetv.service ; then
   return
else
echo '
[Unit]
Description=dizquetv Plex Custom TV Channel & Guide Server
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/bin/bash /home/dizquetv/dizquetv.sh
TimeoutSec=0
RestartSec=2

[Install]
WantedBy=multi-user.target' >> /home/dizquetv/dizquetv.service
cp /home/dizquetv/dizquetv.service /etc/systemd/system
fi

#if rm /etc/systemd/system/dizquetv.service ; then
#   return
#else
#   cp /home/dizquetv/dizquetv.service /etc/systemd/system
#fi

systemctl enable dizquetv.service
systemctl start dizquetv.service
systemctl status dizquetv.service

echo end script
