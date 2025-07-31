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
# 使用 Ubuntu 22.04 作为基础镜像，以获得最佳的硬件兼容性
FROM ubuntu:22.04

# 设置工作目录
WORKDIR /app

# 设置环境变量，防止 apt-get 在安装时出现交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# --- 依赖安装 (使用 apt-get) ---

# 1. 安装系统依赖和 Java 运行时 (JRE)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-21-jre-headless \
    unzip \
    tar \
    python3 \
    python3-pip \
    which \
    xz-utils \
    tzdata \
    findutils \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 创建一个非 root 的专用用户
RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup --no-create-home appuser

# 从构建阶段复制 jar 包，并直接将所有者设置为 appuser
COPY --from=builder --chown=appuser:appgroup /app/stream-rec/build/libs/stream-rec.jar app.jar

# 切换到 appuser 用户来执行后续的安装，更安全
USER appuser
WORKDIR /home/appuser

# 2. 安装 Python 包
RUN pip3 install streamlink --no-cache-dir

# 3. 安装自定义插件 (安装到用户目录下)
RUN INSTALL_DIR="/home/appuser/.local/share/streamlink/plugins"; \
    mkdir -p "$INSTALL_DIR"; \
    curl -L -o "$INSTALL_DIR/twitch.py" 'https://github.com/2bc4/streamlink-ttvlol/releases/latest/download/twitch.py'

# 切换回 root 用户以安装系统级工具
USER root
WORKDIR /app

# 4. 安装 ffmpeg
RUN curl -L "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz" | tar -xJ -C /usr/local/bin/ --strip-components=1 --wildcards '*/ffmpeg' '*/ffprobe' '*/ffplay' && \
    chmod a+x /usr/local/bin/{ffmpeg,ffprobe,ffplay}

# 5. 安装 rclone
RUN curl -L "https://downloads.rclone.org/rclone-current-linux-amd64.zip" -o rclone.zip && \
    unzip rclone.zip && \
    mv rclone-*-linux*/rclone /usr/bin/ && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone && \
    rm -rf rclone.zip rclone-*

# --- 运行配置 ---

ENV TZ=${TZ:-Asia/Shanghai}

EXPOSE 12555

# 切换到非 root 用户来运行应用
USER appuser
WORKDIR /app

CMD ["java", "-jar", "app.jar"]
