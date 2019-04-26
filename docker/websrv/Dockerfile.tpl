FROM reg.srv.local/code_company/ubuntu16 AS npm

ARG project_dir="./code/"

COPY $project_dir /source/

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs


WORKDIR /source


#  add  npm

RUN if [ -f /source/package.json ] \
; then echo "File  /source/package.json exist" \
&& echo "Adding npm" \
&& npm install && npm run-script build && rm -rf /source/node_modules \
; else  echo "File /source/package.json NOT exist !!! " \
; fi

RUN if [ -f /source/wwwroot/package.json ] \
; then echo "File  /source/wwwroot/package.json exist" \
&& echo "Adding npm" && cd wwwroot \
&& npm install && npm run-script build && rm -rf /source/wwwroot/node_modules && cd .. \
; else  echo "File /source/wwwroot/package.json NOT exist !!! " \
; fi





# RUN npm install
# RUN npm run-script build



FROM reg.srv.local/codinsula/nginx-www:latest
#FROM tpl/www:latest

MAINTAINER code_company

EXPOSE 1180
# copy source code into container
# ADD ./code/wwwroot /usr/share/nginx/html
#COPY --from=npm /source/wwwroot /source/wwwroot
COPY --from=npm /source /source

RUN chown www-data:www-data -R /source/
RUN chmod -R 755 /source/

# Copy config file

COPY ./docker/tplwebsrv/default.conf /etc/nginx/conf.d/

# RUN chown www-data:www-data -R /usr/share/nginx/html/

RUN mkdir -p /Static/Cloudx/Sitex/Logs/

RUN mkdir -p /Static/Cloudx/Sitex/Logs/siteadmin/nginx/

RUN chown www-data:www-data -R /Static/

RUN chmod 777 -R /Static/
