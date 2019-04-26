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
      #labels:
        #- "traefik.backend.loadbalancer.sticky=false"
        #- "traefik.backend.loadbalancer.swarm=true"
        #- "traefik.backend=tplbackendsitename"
        #- "traefik.docker.network=traefiknet"
        #- "traefik.entrypoints=https"
        #- "traefik.frontend.passHostHeader=true"
        #- "traefik.frontend.rule=Host:tplpublicsitename"
        #- "traefik.port=99999"
    ports:
      - 99999:1180
    networks:
      - local
#      - traefiknet
    environment:
      - BUILD_ENV=tpl_BUILD_ENV
  tplphp:
    image: tpl_targetsrv/tpl_projectname/tplsitename_tplphpsrv:latest
    networks:
      - local
    environment:
      - BUILD_ENV=tpl_BUILD_ENV
#  bbaphp2:
#    image: reg.local/l/php72:latest
#    networks:
#      - local
#   environment:
#      - BUILD_ENV=${BUILD_ENV}

networks:
  local:
#  traefiknet:
#    external: true
