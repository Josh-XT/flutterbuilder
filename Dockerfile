FROM instrumentisto/flutter:latest AS base

# Set environment variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

RUN git config --global --add safe.directory /usr/local/flutter && \
    git config --global --add safe.directory /app

WORKDIR /app

RUN git config --global --add safe.directory /app && \
    git clone https://github.com/AGiXT/mobile /app/agixt_mobile && \
    cd /app/agixt_mobile && \
    flutter pub get && \
    flutter build apk --release
CMD ["bash"]