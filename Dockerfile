
FROM ubuntu:xenial
MAINTAINER Chilio 

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV LC_ALL=en_US.UTF-8
ENV DISPLAY :99
ENV SCREEN_RESOLUTION 1920x720x24
ENV CHROMEDRIVER_PORT 9515

ENV TMPDIR=/tmp

RUN apt-get update -y
RUN apt-get install -yq apt-utils zip unzip
RUN apt-get install -yq openssl language-pack-en-base
RUN apt-get install -yq software-properties-common curl
RUN add-apt-repository ppa:ondrej/php
RUN sed -i'' 's/archive\.ubuntu\.com/us\.archive\.ubuntu\.com/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -yq
RUN apt-get install -yq libgd-tools
RUN apt-get -yq update
RUN apt-get install -yq --fix-missing php7.0-fpm php7.0-cli php7.0-xml php7.0-zip php7.0-curl php7.0-bcmath php7.0-json \
    php7.0-mbstring php7.0-pgsql php7.0-mysql php7.0-mcrypt php7.0-gd php-xdebug php-imagick imagemagick nginx

RUN apt-get install -yq mc lynx mysql-client bzip2 make g++

ENV COMPOSER_HOME /usr/local/share/composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV PATH "$COMPOSER_HOME:$COMPOSER_HOME/vendor/bin:$PATH"
RUN \
  mkdir -pv $COMPOSER_HOME && chmod -R g+w $COMPOSER_HOME \
  && curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) \
    !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); \
    echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --filename=composer --install-dir=$COMPOSER_HOME 

ADD commands/xvfb.init.sh /etc/init.d/xvfb 

ADD commands/start-nginx-ci-project.sh /usr/bin/start-nginx-ci-project

ADD configs/.bowerrc /root/.bowerrc

RUN chmod +x /usr/bin/start-nginx-ci-project
ADD commands/configure-laravel.sh /usr/bin/configure-laravel

RUN chmod +x /usr/bin/configure-laravel

RUN \
  apt-get install -yq xvfb gconf2 fonts-ipafont-gothic xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base \
    xfonts-scalable \
  && chmod +x /etc/init.d/xvfb \
  && CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` \
  && mkdir -p /opt/chromedriver-$CHROMEDRIVER_VERSION \
  && curl -sS -o /tmp/chromedriver_linux64.zip \
    http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip \
  && unzip -qq /tmp/chromedriver_linux64.zip -d /opt/chromedriver-$CHROMEDRIVER_VERSION \
  && rm /tmp/chromedriver_linux64.zip \
  && chmod +x /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver \
  && ln -fs /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver /usr/local/bin/chromedriver \
  && curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get -yqq update && apt-get -yqq install google-chrome-stable x11vnc

RUN apt-get install -yq apt-transport-https
RUN apt-get install -yq  python-software-properties
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get update
RUN apt-get install -yq nodejs
RUN apt-get install -yq git
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -yq yarn
RUN yarn global add bower --network-concurrency 1
RUN wget https://phar.phpunit.de/phpunit-6.5.14.phar
RUN chmod +x phpunit-6.5.14.phar
RUN mv phpunit-6.5.14.phar /usr/local/bin/phpunit

RUN npm install -g node-gyp --unsafe
RUN npm install -g node-sass --unsafe
RUN npm install -g gulp --unsafe

RUN apt-get install -y supervisor

ADD configs/supervisord.conf /etc/supervisor/supervisord.conf

ADD configs/nginx-default-site /etc/nginx/sites-available/default 

VOLUME [ "/var/log/supervisor" ]

RUN apt-get -yq update
RUN apt-get -yq clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-get upgrade
RUN apt-get autoremove

ADD commands/versions /usr/bin/versions
RUN chmod +x /usr/bin/versions
RUN versions

EXPOSE 80 9515

CMD ["php7.0-fpm", "-g", "daemon off;"]
CMD ["nginx", "-g", "daemon off;"]
