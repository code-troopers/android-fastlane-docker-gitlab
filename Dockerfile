FROM azul/zulu-openjdk-debian:13

LABEL maintainer "Cedric Gatay <c.gatay@code-troopers.com>"

ARG ANDROID_SDK_TOOLS="9477386"
ARG ANDROID_COMPILE_SDK="33"
ARG ANDROID_BUILD_TOOLS="33.0.1"

RUN apt-get --quiet update --yes \
    && apt upgrade -y \
    && apt-get --quiet install --yes curl procps gpg wget tar unzip lib32stdc++6 lib32z1 imagemagick make g++ less \
    && wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip \
    && unzip -d android-sdk-linux android-sdk.zip \
    && rm -f android-sdk.zip 
RUN mkdir -p android-sdk-linux/cmdline-tools/latest \ 
    && mv android-sdk-linux/cmdline-tools/bin android-sdk-linux/cmdline-tools/latest/ \
    && mv android-sdk-linux/cmdline-tools/lib android-sdk-linux/cmdline-tools/latest/
RUN echo y | android-sdk-linux/cmdline-tools/latest/bin/sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}"\
    && echo y | android-sdk-linux/cmdline-tools/latest/bin/sdkmanager "platform-tools"  \
    && echo y | android-sdk-linux/cmdline-tools/latest/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}" 
RUN export ANDROID_HOME=$PWD/android-sdk-linux \
    && export PATH=$PATH:$PWD/android-sdk-linux/cmdline-tools/latest/ \
    && yes | android-sdk-linux/cmdline-tools/latest/bin/sdkmanager --licenses \
    && rm -rf /var/lib/apt/lists/*


#RUN gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -

RUN curl -sSL https://get.rvm.io | bash -s stable --ruby

RUN /usr/local/rvm/bin/rvm install 2.6.3

ENV PATH=/usr/local/rvm/rubies/ruby-2.6.3/bin:$PATH

RUN gem install fastlane -NV 

RUN gem install bundler -NVf 
# Fix for corrupted build tools install missing dx / dx.jar
RUN cp android-sdk-linux/build-tools/33.0.1/d8 android-sdk-linux/build-tools/33.0.1/dx \
   && cp android-sdk-linux/build-tools/33.0.1/lib/d8.jar android-sdk-linux/build-tools/33.0.1/lib/dx.jar

ENV ANDROID_HOME=/android-sdk-linux
ENV PATH=$PATH:/android-sdk-linux/platform-tools/ 

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs
