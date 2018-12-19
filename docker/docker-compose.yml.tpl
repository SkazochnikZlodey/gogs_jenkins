version: '3.6'

services:
  tplweb:

    image: tpl_targetsrv/tpl_projectname/tplsitename_tplwebsrv:latest
    depends_on:
      - tplphp
#      - bbaphp2
    deploy:
      replicas: 1
      placement:
        constraints: [node.role == manager]
      resources:
        reservations:
          memory: 128M
        limits:
          memory: 256M
    ports:
      - 99999:80
    networks:
      - local
    environment:
      - BUILD_ENV=tpl_BUILD_ENV
  tplphp:
    image: tpl_targetsrv/tpl_projectname/tplsitename_tplphpsrv:latest
    networks:
      - local
    environment:
      - BUILD_ENV=tpl_BUILD_ENV
#  bbaphp2:
#    image: reg.locaL/ll/bbadmin_php72:latest
#    networks:
#      - local
#   environment:
#      - BUILD_ENV=${BUILD_ENV}

networks:
  local:
