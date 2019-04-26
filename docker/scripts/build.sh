#!/bin/bash
#
# File for Jenkins
#

unset template_name
unset foldername
unset dockerdir
unset variable_name
unset variable_value
unset $sourceservername
unset $projectname
unset $sitename
unset $folder
unset $string

dockerdir="docker"

foldername="$1"

# echo "Current path from $0"
# pwd
if [ -z "$1" ]
  then
    echo "No argument supplied"
    echo "Usage: $0 foldername create|use|delete template_name add|replace|delete variable_name variable_value"
    echo "Example: $0 foldername create default.conf  - create default.conf from default.cont.tpl"
    echo " $0 foldername  use default.conf add 'server  bbaphp' '1:9000;' - use default.conf file serch for server  bbaphp and add 1:9000 as value "
    exit 1
fi

echo "Executing " $0 "with parameter(s): " "$@"
# echo "foldername: " $foldername

# cd ..
# pwd
# cd $foldername
# ls -lh $foldername

option="${2}"
case ${option} in
   create) template_name=$foldername"${3}"
       echo "Copy "$template_name".tpl to " $foldername
#       ls -lh $template_name
       echo "$template_name.tpl"
       echo "Default file copy in process"
       cp -f $template_name".tpl" $template_name
       if [ ! -f "$template_name" ]; then
            echo "Error: File $template_name does not exist !"
       exit 1
       fi
       ls -lh $template_name
       if [ ! -z "$4" ]; then
         echo "Copy "$template_name"."${4}".tpl to " $foldername
  #       ls -lh $template_name
         echo "$template_name."${4}".tpl"
         echo "Additional file copy in process"
         cp -f $template_name"."${4}".tpl" $template_name
         if [ ! -f "$template_name" ]; then
              echo "Error: File $template_name does not exist !"
         exit 1
         fi
       fi
       ls -lh $template_name
       exit 0
      ;;
   delete) template_name=$foldername"${3}"
      echo "Deleting :" $template_name
      rm  $template_name
      if [  -f "$template_name" ]; then
           echo "Error: File $template_name still exist !"
      exit 1
      fi
      exit 0
      ;;
   use) template_name=$foldername"${3}"
      echo "Using $template_name as target"
      ;;
   build)
   # cd $(pwd)/nginx
      echo "current dir:"
      pwd
      sourceservername="${4,,}"
      projectname="${5,,}"
      sitename="${6,,}"
      folder="${7,,}"
      echo " Folder: "   $folder
      echo " Building container:" $sitename
      echo " Project "$projectname
      echo " for server " $sourceservername
      echo " Setting file " ${3}
      echo " in folder $1               $foldername"
      string="temp_${sitename}_${folder}:latest ${sourceservername}/${projectname}/${sitename}_${folder}:latest"
      echo $string
      echo " ############################################################ "
#      docker system prune -a -f
      echo " build --no-cache -f "${1}${3}" -t temp_"${6,,}"_"${7,,}" ."
      docker build --no-cache -f "${1}${3}" -t temp_"${6,,}"_"${7,,}" .
#      echo "tag temp_"${6,,}"_"${7,,}":latest" ${4}"/"${5}"/"${6,,}"_"${7,,}"
      echo "Tagging... . "$string
       docker tag $string
#      docker tag temp_"${6,,}"_"${7,,}"":latest" ${4}"/"${5}"/"${6,,}"_"${7,,}"
#      docker tag ${"temp_"${6,,}"_"${7,,}":latest " ${4}"/"${5}"/"${6,,}"_"${7,,}":latest"}
#      echo "push "${4}"/"${5}"/"${6,,}"_"${7,,}"
      echo "Pushing... ."
      docker push "${4}"/"${5}"/"${6,,}"_"${7,,}"
      echo " "
      exit 0
      ;;
   deploy)
      echo "Docker stack deployment:"
      echo "Folder name :" ${foldername}
      echo "File name   :" ${3}
      echo "Project name:" ${4}
      echo "Site name   :" ${5}
      echo "${foldername}""${3}" "${5}"
      docker stack deploy -c "${foldername}""${3}" "${5}"
      exit 0
      ;;
   rdeploy)
     echo "Docker stack deployment:"
     echo "Folder name :" ${foldername}
     echo "File name   :" ${3}
     echo "Project name:" ${4}
     echo "Site name   :" ${5}
     echo "Remote user :" ${6}
     echo "Remote server" ${7}
     echo "${foldername}""${3}" "${5}"
     ssh -o "StrictHostKeyChecking=no" -t "${6}"@"${7}" mkdir -p /tmp/docker_"${5}"
#     ssh -t "${6}"@"${7}" docker stack rm "${5}"
     scp "${foldername}""${3}" "${6}"@"${7}":/tmp/docker_"${5}"
     ssh -t "${6}"@"${7}" ls -la /tmp/docker_"${5}"
     ssh -t "${6}"@"${7}" docker stack deploy -c  /tmp/docker_"${5}"/"${3}" "${5}"
#     docker stack deploy -c "${foldername}""${3}" "${5}"
     exit 0
     ;;

    copy)
    echo "Docker contaner copy:"
    echo "Folder name         :" ${foldername}
    echo "Source server name  :" ${3}
    echo "Target server name  :" ${4}
    echo "Project name        :" ${5}
    echo "Site name           :" ${6}
    echo "Folder name         :" ${7}
##    echo "${foldername}""${3}" "${5}"
##     docker stack deploy -c "${foldername}""${3}" "${5}"
   docker pull "${3}"/"${5}"/"${6}"_"${7}:latest"
   docker tag "${3}"/"${5}"/"${6}"_"${7}:latest" "${4}"/"${5}"/"${6}"_"${7}:latest"
   docker push "${4}"/"${5}"/"${6}"_"${7}:latest"
      exit 0
       ;;
   *)
      echo "Errors in 1 argument !! Usage: $0 create|use|delete folder_name template_name add|replace|delete variable_name variable_value "
      exit 1 # Command to come out of the program with status 1
      ;;
esac

echo "Starting manipulations with $template_name"
option="${4}"
case ${option} in
   delete) variable_name=${5}
      variable_value=${6}
      echo "Delete in :" "$template_name"
      echo "variable  :" "${variable_name}"
      echo "parameter :" "${variable_value}"
      sed -i "s/${variable_name}/""/g" "${template_name}"
       exit 0
      ;;
   replace) variable_name="${5}"
      variable_value="${6}"
      echo "Replace in:" "$template_name"
      echo "variable  :" "${variable_name}"
      echo "parameter :" "${variable_value}"
      sed -i "s/${variable_name}/${variable_value}/g" "${template_name}"
    #    cp -f $template_name".tmp" $template_name
    #    rm -f $template_name".tmp"
      exit 0
      ;;
   add) variable_name=${5}
      variable_value=${6}
      echo "Adding to :" "$template_name"
      echo "variable  :" "${variable_name}"
      echo "parameter :" "${variable_value}"
      sed -i "/${variable_name}/a${variable_value// /\\ }" "${template_name}"
      exit 0
      ;;
   *)
      echo "Errors in 4 argument !! Usage: $0 create|use|delete folder_name template_name add|replace|delete variable_name variable_value "
      exit 1 # Command to come out of the program with status 1
      ;;
esac
# cd ..
# cd scripts
























exit 0
