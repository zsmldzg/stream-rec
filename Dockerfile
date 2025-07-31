# ==================================
# Stage 1: Build the application
# ==================================
FROM gradle:8.8-jdk21-alpine AS builder
WORKDIR /app
COPY . .
RUN gradle stream-rec:build -x test --no-daemon

# ==================================
# Stage 2: Create the final, compatible image
# ==================================
# 使用 Alpine 基础镜像避免 x86-64-v2 的兼容性问题
FROM amazoncorretto:21-alpine-jdk

# 设置工作目录
WORKDIR /app

# 从构建阶段拷贝编译好的 Jar 包
COPY --from=builder /app/stream-rec/build/libs/stream-rec.jar app.jar

# 安装系统和 Python 依赖
RUN apk add --no-cache \
    tzdata \
    curl \
    unzip \
    tar \
    xz \
    python3 \
    py3-pip && \
    pip3 install streamlink && \
    # 安装 streamlink-ttvlol 插件
    INSTALL_DIR="/root/.local/share/streamlink/plugins"; mkdir -p "$INSTALL_DIR"; curl -L -o "$INSTALL_DIR/twitch.py" 'https://github.com/2bc4/streamlink-ttvlol/releases/latest/download/twitch.py'
 
# 安装 ffmpeg (仅 amd64)
RUN FFMPEG_URL="https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz" && \
    curl -L $FFMPEG_URL | tar -xJ && \
    mv ffmpeg-master-latest-linux64-gpl/bin/{ffmpeg,ffprobe,ffplay} /usr/local/bin/ && \
    chmod +x /usr/local/bin/{ffmpeg,ffprobe,ffplay} && \
    # 清理下载的临时文件
    rm -rf ffmpeg-master-latest-linux64-gpl

# 安装 rclone (仅 amd64)
RUN RCLONE_URL="https://downloads.rclone.org/rclone-current-linux-amd64.zip" && \
    curl -L $RCLONE_URL -o rclone.zip && \
    unzip rclone.zip && \
    # 使用通配符移动，使其不受 rclone 版本号变化的影响
    mv rclone-*-linux-amd64/rclone /usr/bin/rclone && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone && \
    # 清理下载的 zip 和解压后的文件夹
    rm -rf rclone.zip rclone-*-linux-amd64

# 设置时区
ENV TZ=${TZ:-Asia/Shanghai}
 
# 暴露端口
EXPOSE 12555
 
# 启动命令
CMD ["java", "-jar", "app.jar"]
