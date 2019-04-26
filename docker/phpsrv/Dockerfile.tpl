FROM reg.srv.local/code_company/php72:latest AS composer
#FROM tpl/php72:latest AS composer

MAINTAINER code_company

ARG project_dir="./code/"

# copy source code into container
ADD $project_dir /source/

# RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
# RUN apt-get install -y nodejs


WORKDIR /source

#  add  npm

# RUN if [ -f /source/package.json ] \
#    ; then echo "File  /source/package.json exist" \
#    && echo "Adding npm" \
#    && npm install && npm run-script build && rm -rf /source/node_modules \
#    ; else  echo "File /source/package.json NOT exist !!! " \
#    ; fi

# RUN if [ -f /source/wwwroot/package.json ] \
#        ; then echo "File  /source/wwwroot/package.json exist" \
#        && echo "Adding npm" && cd wwwroot \
#        && npm install && npm run-script build && rm -rf /source/wwwroot/node_modules && cd .. \
#       ; else  echo "File /source/wwwroot/package.json NOT exist !!! " \
#        ; fi




# RUN npm install && npm run-script build



#Check for composer.json in ./source/
RUN if [ -f /source/composer.json ] \
    ; then echo "File composer.json exist" \
    && echo "Adding composer" \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/bin/composer \
    && composer update \
    ; else  echo "File composer.json NOT exist !!! " \
    ; fi




# add composer
#RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
#	&& php composer-setup.php \
#  && php -r "if (hash_file('SHA384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
#	&& php -r "unlink('composer-setup.php');" \
#	&& mv composer.phar /usr/bin/composer \
#	&& composer update

# RUN composer update # --ignore-platform-reqs --no-scripts

########################

FROM reg.srv.local/codinsula/php72
#FROM tpl/php72
COPY --from=composer /source /source

EXPOSE 9000

RUN chown www-data:www-data -R /source/

RUN mkdir -p /Static/Cloudx/Sitex/Logs/

RUN chown www-data:www-data -R /Static/

RUN chmod 777 -R /Static/
