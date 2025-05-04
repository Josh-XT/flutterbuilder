FROM instrumentisto/flutter:latest AS base

# Set environment variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Configure Git
RUN git config --global --add safe.directory /usr/local/flutter && \
    git config --global --add safe.directory /app

# Accept Android licenses
RUN yes | flutter doctor --android-licenses || true

# Update Android SDK components
RUN sdkmanager "platforms;android-33" "build-tools;33.0.2"

WORKDIR /app

# Clone and build the project
RUN git config --global --add safe.directory /app && \
    git clone https://github.com/AGiXT/mobile /app/agixt_mobile && \
    cd /app/agixt_mobile && \
    flutter pub get && \
    flutter build apk --release --verbose &

CMD ["bash"]