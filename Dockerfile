FROM openjdk:8u212-b04-jdk-stretch

LABEL maintainer "Cedric Gatay <c.gatay@code-troopers.com>"

ARG ANDROID_SDK_TOOLS="4333796"
ARG ANDROID_COMPILE_SDK="28"
ARG ANDROID_BUILD_TOOLS="28.0.2"

RUN apt-get --quiet update --yes \
    && apt-get --quiet install --yes wget tar unzip lib32stdc++6 lib32z1 imagemagick ruby ruby-dev rubygems make g++ less \
    && wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS}.zip \
    && unzip -d android-sdk-linux android-sdk.zip \
    && rm -f android-sdk.zip \
    && echo y | android-sdk-linux/tools/bin/sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}" >/dev/null \
    && echo y | android-sdk-linux/tools/bin/sdkmanager "platform-tools" >/dev/null \
    && echo y | android-sdk-linux/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}" >/dev/null \
    && export ANDROID_HOME=$PWD/android-sdk-linux \
    && export PATH=$PATH:$PWD/android-sdk-linux/platform-tools/ \
    && yes | android-sdk-linux/tools/bin/sdkmanager --licenses \
    && gem install fastlane -NV\
    && rm -rf /var/lib/apt/lists/*

ENV ANDROID_HOME=/android-sdk-linux
ENV PATH=$PATH:/android-sdk-linux/platform-tools/ 