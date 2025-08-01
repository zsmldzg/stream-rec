FROM gradle:8.8-jdk21-alpine AS builder
WORKDIR /app
COPY . .
RUN gradle stream-rec:build -x test --no-daemon

# 使用 eclipse-temurin 镜像，它基于 Ubuntu 22.04 ("Jammy") 并且已经内置了 Java 21 没有 x86-64-v2 CPU 限制
FROM eclipse-temurin:21-jdk-jammy
WORKDIR /app
COPY --from=builder /app/stream-rec/build/libs/stream-rec.jar app.jar

# 分析安装失败程序1
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        unzip tar python3 python3-pip
        
# 分析安装失败程序2
RUN apt-get install -y --no-install-recommends \
        xz-utils findutils curl

# 分析安装失败程序3
RUN pip3 install streamlink && \
    # install streamlink-ttvlol
    INSTALL_DIR="/root/.local/share/streamlink/plugins"; mkdir -p "$INSTALL_DIR"; curl -L -o "$INSTALL_DIR/twitch.py" 'https://github.com/2bc4/streamlink-ttvlol/releases/latest/download/twitch.py' && \
    # 清理 apt 缓存以减小最终的镜像体积
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# 安装 ffmpeg (仅 amd64)
RUN URL="https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz" && \
    curl -L $URL

RUN tar -xJf ffmpeg-master-latest-linux64-gpl.tar.xz
    mv ffmpeg-*-linux*/bin/{ffmpeg,ffprobe,ffplay} /usr/local/bin/ 
    
RUN chmod +x /usr/local/bin/{ffmpeg,ffprobe,ffplay} && \
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
