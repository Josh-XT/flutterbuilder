FROM instrumentisto/flutter:latest AS base

# Set environment variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Configure Git
RUN git config --global --add safe.directory /usr/local/flutter && \
    git config --global --add safe.directory /app

# Accept Android licenses
RUN yes | flutter doctor --android-licenses || true

# Update Android SDK components to include required packages
# The base image ships with the latest SDK platform (currently 36).
# We also need older platforms that the mobile app and its plugins target.
RUN sdkmanager \
    "platforms;android-31" \
    "platforms;android-33" \
    "platforms;android-34" \
    "platforms;android-35" \
    "build-tools;33.0.2" \
    "build-tools;34.0.0" \
    "build-tools;35.0.0" \
    "ndk;27.0.11902837" \
    "cmake;3.22.1"

# Pre-warm Gradle wrapper so first builds don't download it
RUN mkdir -p /tmp/gradle-warmup/android/gradle/wrapper && \
    echo 'distributionBase=GRADLE_USER_HOME\ndistributionPath=wrapper/dists\nzipStoreBase=GRADLE_USER_HOME\nzipStorePath=wrapper/dists\ndistributionUrl=https\\://services.gradle.org/distributions/gradle-8.7-bin.zip' \
    > /tmp/gradle-warmup/android/gradle/wrapper/gradle-wrapper.properties && \
    cd /tmp/gradle-warmup && \
    gradle --version 2>/dev/null || true && \
    rm -rf /tmp/gradle-warmup

WORKDIR /app

CMD ["bash"]