FROM gradle:8.8-jdk21-alpine AS builder
WORKDIR /app
COPY . .
RUN gradle stream-rec:build -x test --no-daemon

# 使用 Alpine 基础镜像避免 x86-64-v2 的兼容性问题
FROM amazoncorretto:21-alpine-jdk
WORKDIR /app
COPY --from=builder /app/stream-rec/build/libs/stream-rec.jar app.jar

# 安装系统和 Python 依赖
RUN yum update -y && \
    yum install -y unzip tar python3 python3-pip which xz tzdata findutils && \
    pip3 install streamlink && \
    # install streamlink-ttvlol
    INSTALL_DIR="/root/.local/share/streamlink/plugins"; mkdir -p "$INSTALL_DIR"; curl -L -o "$INSTALL_DIR/twitch.py" 'https://github.com/2bc4/streamlink-ttvlol/releases/latest/download/twitch.py' && \
    yum clean all && \
    rm -rf /var/cache/yum

# 安装 ffmpeg (仅 amd64)
RUN URL="https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz" && \
    curl -L $URL | tar -xJ && \
    mv ffmpeg-*-linux*/bin/{ffmpeg,ffprobe,ffplay} /usr/local/bin/ && \
    chmod +x /usr/local/bin/{ffmpeg,ffprobe,ffplay} && \
    rm -rf ffmpeg-*

# 安装 rclone (仅 amd64)
RUN URL="https://downloads.rclone.org/rclone-current-linux-amd64.zip" && \
    curl -L $URL -o rclone.zip && \
    unzip rclone.zip && \
    mv rclone-*-linux*/rclone /usr/bin/ && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone && \
    rm -rf rclone.zip rclone-*

# 设置时区
ENV TZ=${TZ:-Asia/Shanghai}
 
# 暴露端口
EXPOSE 12555
 
# 启动命令
CMD ["java", "-jar", "app.jar"]
