FROM jrottenberg/ffmpeg:8.0.1-nvidia2404

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt -y install --no-install-recommends \
    python3 \
    curl \
    ca-certificates

RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt - install nodejs

RUN npm install -g @peertube/peertube-runner@0.4.0
RUN rm -rf /var/lib/apt/lists/*

# Copy and set permissions as root before switching user
COPY start.sh /home/runner/start.sh
RUN chmod +x /home/runner/start.sh

# Rename ffmpeg, copy ffmpeg wrapper and set permissions
# RUN mv /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg-real
# COPY ffmpeg.sh /usr/local/bin/ffmpeg
# RUN chmod +x /usr/local/bin/ffmpeg

# Create user and switch
RUN useradd -ms /bin/bash runner
RUN chown -R runner:runner /home/runner
USER runner
WORKDIR /home/runner

ENTRYPOINT ["./start.sh"]
