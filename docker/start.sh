# /bin/sh


export JOB_BASE_NAME="9999_Jenkins-GoGS-Trig________web__QA"
cat README.md


echo "Build tag:" $BUILD_TAG


./docker/start_jenkins.sh qa
#sudo docker run --name mysite  -p 10090:10090 -d mysite

#sudo docker network create --driver overlay mysite


#sudo  docker stack deploy -c docker-compose.yml mysite
