# Use a base image with Java pre-installed
FROM openjdk:17-jdk-slim AS base

# Set environment variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages: git, curl, unzip, wget, standard C++ library, libGLU (for Flutter)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    wget \
    libstdc++6 \
    libglu1-mesa \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# --- Flutter SDK ---
# Set Flutter version (adjust if needed, e.g., based on your pubspec.yaml or CI)
ARG FLUTTER_VERSION=3.24.5
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"

# Download and install Flutter SDK
RUN mkdir -p ${FLUTTER_HOME} && \
    cd /opt && \
    wget -q -P /tmp/flutter_download https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz && \
    tar xf /tmp/flutter_download/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz -C /opt

# Pre-download Flutter engine artifacts and Dart SDK
RUN flutter precache --linux --android

# Verify installation and download any missing components
RUN flutter doctor

# --- Android SDK ---
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$PATH"

# Download Android SDK command-line tools
ARG CMDLINE_TOOLS_VERSION=11076708_latest
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}.zip -O /tmp/android_download/cmdline-tools.zip && \
    unzip -q /tmp/android_download/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest

# Accept Android licenses
RUN yes | sdkmanager --licenses > /dev/null || true

# Install required Android SDK components (adjust versions as needed)
# Using NDK 26 as it's commonly used and stable. The log showed issues with 27/29.
ARG ANDROID_PLATFORM_VERSION=34
ARG ANDROID_BUILD_TOOLS_VERSION=34.0.0
ARG ANDROID_NDK_VERSION=26.1.10909125
RUN sdkmanager --install \
    "platform-tools" \
    "platforms;android-${ANDROID_PLATFORM_VERSION}" \
    "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "ndk;${ANDROID_NDK_VERSION}" && \
    chmod +x /opt/android-sdk/cmdline-tools/latest/bin/* && \
    chmod +x /opt/android-sdk/platform-tools/*

WORKDIR /app

RUN git config --global --add safe.directory /opt/flutter && \
    git config --global --add safe.directory /app

RUN git clone https://github.com/AGiXT/mobile /app/agixt_mobile && \
    cd /app/agixt_mobile && \
    flutter pub get
    # flutter build apk --release
