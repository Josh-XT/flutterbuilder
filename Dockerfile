FROM ubuntu:22.04

# Set environment variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    openjdk-17-jdk \
    sudo \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set up new user to avoid permission issues
RUN useradd -ms /bin/bash flutter
RUN usermod -aG sudo flutter
RUN echo 'flutter ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER flutter
WORKDIR /home/flutter

# Install Android SDK
ENV ANDROID_SDK_ROOT=/home/flutter/android-sdk
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-9123335_latest.zip -O cmdline-tools.zip \
    && unzip cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
    && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm cmdline-tools.zip

# Set Android environment variables
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools
RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2"

# Install Flutter
ENV FLUTTER_HOME=/home/flutter/flutter
ENV FLUTTER_VERSION=3.16.0
RUN git clone -b ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME}
ENV PATH=${PATH}:${FLUTTER_HOME}/bin

# Configure Flutter
RUN flutter config --no-analytics
RUN flutter precache
RUN flutter doctor -v

# Setup Git safe directories
RUN git config --global --add safe.directory ${FLUTTER_HOME}
RUN git config --global --add safe.directory /app

WORKDIR /app

# Clone and build AGiXT mobile app with better error handling
RUN git config --global --add safe.directory /app && \
    git clone https://github.com/AGiXT/mobile /app/agixt_mobile && \
    cd /app/agixt_mobile && \
    # Clear gradle cache to prevent corrupted files
    rm -rf ~/.gradle/caches/ && \
    # Make sure the repo is clean
    git clean -xfd && \
    # Update Flutter packages
    flutter pub upgrade --major-versions && \
    flutter pub get && \
    # Try to build with detailed error reporting
    flutter build apk --release --verbose

CMD ["bash"]