FROM nvidia/cuda:13.0.2-cudnn-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt -y install --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    git-core \
    libass-dev \
    libc6 \
    libc6-dev \
    libfreetype6-dev \
    libgnutls28-dev \
    libmp3lame-dev \
    libnuma1 \
    libnuma-dev \
    libsdl2-dev \
    libtool \
    libva-dev \
    libvdpau-dev \
    libvorbis-dev \
    libxcb1-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    meson \
    ninja-build \
    pkg-config \
    python3 \
    python3-pip \
    texinfo \
    unzip \
    wget \
    yasm \
    zlib1g-dev

RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt - install nodejs

RUN npm install -g @peertube/peertube-runner@0.4.0
RUN rm -rf /var/lib/apt/lists/*

# Install ffmpeg with NVIDIA support
RUN cd /tmp \
    && git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git \
    && cd nv-codec-headers \
    && make install
RUN cd /tmp \
    && git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg/ \
    && cd ffmpeg \
    && ./configure --enable-nonfree --enable-cuda-nvcc --enable-libnpp --extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64 --disable-static --enable-shared \
    && make -j 8 \
    && make install

# Copy and set permissions as root before switching user
COPY start.sh /home/runner/start.sh
RUN chmod +x /home/runner/start.sh

# Create user and switch
RUN useradd -ms /bin/bash runner
RUN chown -R runner:runner /home/runner
USER runner
WORKDIR /home/runner

ENTRYPOINT ["./start.sh"]
