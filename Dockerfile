FROM instrumentisto/flutter:latest AS base

# Set environment variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Configure Git
RUN git config --global --add safe.directory /usr/local/flutter && \
    git config --global --add safe.directory /app

# Accept Android licenses
RUN yes | flutter doctor --android-licenses || true

# Update Android SDK components to include required packages
RUN sdkmanager \
    "platforms;android-33" "build-tools;33.0.2" \
    "ndk;27.0.11902837" \
    "build-tools;34.0.0" \
    "platforms;android-34" \
    "platforms;android-31"

WORKDIR /app

CMD ["bash"]