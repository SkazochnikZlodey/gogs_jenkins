# /bin/sh


export JOB_BASE_NAME="11192_Jenkins-GoGS-Trig________web__QA"
cat README.md


echo "Build tag:" $BUILD_TAG


./docker/start_jenkins.sh qa
