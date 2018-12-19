#!/bin/bash
#
# File for Jenkins
#
###################################################################
# local variables
###################################################################
unset username                 # user name for regitry
unset password                 # user password for regitry
unset sourceservername         # source registry server
unset targetservername         # target registry server
unset projectname              # project name
unset sourcecontainerlocation  # source container name
unset targetcontainerlocation  # target container name
unset swarmmanager             # docker swarm managerfor ssh connections
unset buildenv                 # additional environment variables for containers
unset job                      # what to do in this script
unset basedir                  # main directory (not used)
unset dockerdir                # docker files directory for build
unset portnumber               # portnumber - 1st part of JOB_BASE_NAME
unset sitename                 # sitename -2nd part of JOB_BASE_NAME
unset endofsitename            # string after _ in sitename
unset string
unset delimiter
unset delimiter2
unset delimiter3
unset retval


# string="11112_test"
delimiter="_"
retval=""
Global_Projectname="ll"
basedir=$(pwd) # not used
dockerdir="docker"



##################################################################
# templates variable for dockerfiles
##################################################################

unset tplsiteuser          # user name for webserver (used to access web site files (www-data))
unset tplsitelogsdir       # log dir for site
unset tpldestsitedir       # directory with site comtent ( not where index file located)
unset tpldestindexfiledir  # directory where is index.* file located
unset tplsourcecodedir     # source code directory
unset tplsourceindexdir    # source index.* directory


##################################################################
# templates variable for docker-compose
##################################################################






##################################################################
# starting
##################################################################
# echo $JOB_BASE_NAME
echo "Version 0.1a"

if [[ -z "$JOB_BASE_NAME" ]];   then
      JOB_BASE_NAME="9999_mysite"
# echo -n " Please, enter site name for docker repository server: "

# read JOB_BASE_NAME



echo -n " Please, enter username for docker repository server: "
read username
prompt=" Please, enter password: "
while IFS= read -p "$prompt" -r -s -n 1 char
do
    if [[ $char == $'\0' ]]
    then
         break
    fi
    prompt='*'
    password+="$char"
done

#  echo $username
#  echo $password

fi


string=$JOB_BASE_NAME

subst(){
  local str=$1
  local substr=$2

#   echo "First parameter $str "
#   echo "Second parameter is $substr "
#   echo "Last parameter is (l|r))$3 "
   if [[ $3 == *"r"* ]];
   then
#    echo right
    retval=${str#*"$substr"}
#    echo $retval
   else
#    echo left
    retval=${str%%"$substr"*}
#    echo $retval
   fi
}



# Function Set dev environment variables
DevEnvironment(){
   echo "Enviroment is $1 "
   echo "Second parameter is $2 "
     username=jenkinsuser
     password=Password
     sourceservername=reg.srv.local
     targetservername=reg.srv.local
     projectname=$Global_Projectname
#     sitename=$JOB_BASE_NAME
     sourcecontainerlocation="reg.srv.local/main"
     targetcontainerlocation=$string
     swarmmanager=jenkins.srv.local
     buildenv=dev
     job=build
}

# Function Set qa environment variables
QaEnvironment(){
   echo "Enviroment is $1 "
   echo "Second parameter is $2 "
   username=jenkinsuser
   password=P@ssw0rd
   sourceservername=reg.srv.local
   targetservername=regbackup.srv.local
   projectname=$Global_Projectname
#   sitename=$JOB_BASE_NAME
   sourcecontainerlocation="reg.srv.local/main"
   targetcontainerlocation=$string
   swarmmanager=swarmqa0.srv.local
   buildenv=qa
   job=copy
}

# Function Set prod environment variables
ProdEnvironment(){
   echo "Enviroment is $1 "
   echo "Second parameter is $2 "
   username=jenkinsuser
   password=P@ssw0rd
   sourceservername=regbackup.srv.local
   targetservername=regprod.srv.local
   projectname=$Global_Projectname
#   sitename=$JOB_BASE_NAME
   sourcecontainerlocation="reg.srv.local/main"
   targetcontainerlocation=$string
   swarmmanager=prodnode0.srv.local
   buildenv=prod
   job=copy
}


echo "Initial JOB Name:"$string
#####################################################################
#Lets cleanup string from __ or ___ ....______________________
#####################################################################

for i in {1..10}
do
  delimiter2="$delimiter2$delimiter"
done

echo "Max delimiter is :" $delimiter2

for i in {1..10}
do

delimiter3="$delimiter$delimiter"

delimiter2="${delimiter2/$delimiter3/$delimiter}"


string="${string//$delimiter2/$delimiter}"
#echo $string

done

# echo $delimiter2
echo "Cleaned JOB Name:"$string

#####################################################################


#echo $string
#echo $delimiter
subst "${string}" "${delimiter}" "l"
portnumber=$retval
retval=""
subst "${string}" "${delimiter}" "r"
sitename=$retval
retval=""





option="${1}"
case ${option} in
   dev) SECOND="${2}"
       DevEnvironment ${option} ${2}
#      echo "Dev environment $SECOND"
      ;;
   qa) SECOND="${2}"
      QaEnvironment ${option} ${2}
      ;;
   prod) SECOND="${2}"
      ProdEnvironment ${option} ${2}
      ;;
   *)
      echo "`basename ${0}`:usage: dev|qa|prod"
      exit 1 # Command to come out of the program with status 1
      ;;
esac

endofsitename=${sitename##*_}
endofsitename=${endofsitename,,}



if [[ "${endofsitename,,}" ==  "${buildenv,,}" ]]; then
  echo "     !!!!!!!!!!!!!!!!!!     "

   echo ${endofsitename} " found in site name !"
#   subst "${sitename}" "${delimiter}" "r"

   echo " Sitename changed to :" ${sitename%_*}
   sitename=${sitename%_*}
   echo "    !!!!!!!!!!!!!!!!!!     "
   endofsitename=${sitename##*_}
   endofsitename=${endofsitename,,}
fi

echo " "
echo " Assigned variables: "

echo "Username for servers          :"$username
echo "Password for server           :"$password
echo "Sources server name           :"$sourceservername
echo "Target server name            :"$targetservername
echo "Project name                  :"$projectname
echo "Site name                     :"$sitename
echo "End of site name (low symbols):"$endofsitename
echo "Site Port number              :"$portnumber
echo "Source container location     :"$sourcecontainerlocation
echo "Traget container location     :"$targetcontainerlocation
echo "Swarm manager                 :"$swarmmanager
echo "Build enviroment (dev|qa|prod):"$buildenv
echo "Current job                   :"$job
echo "Current directory             :"$basedir
echo "Docker directory              :"$dockerdir

echo " "






export BUILD_ENV=$buildenv

#echo "Current dir"
#pwd

# echo "OS Enviroment"
# printenv

docker login -u $username -p $password $sourceservername
docker login -u $username -p $password $targetservername
#clean up system

#docker stack rm banner_bonuses_admin
#docker system prune -f -a

#echo $job

if [ "$job" == "build" ]; then

  ##############################################################################
  # 1- folder name;2 - task for file in folder;3 - file name for task;
  # 4- task insde file 3. 5. What to search 6. value for modification insde file
  #
  ##############################################################################
  step_1=("websrv" "create" "default.conf" $endofsitename)
  step_2=("websrv" "use" "default.conf" "replace" "    server  tplphp:9000" "    server  phpsrv1:9000")
  #step_3=("nginx" "use" "default.conf" "add" "    server  phpsrv1:9000" "    server  phpsrv2:9000;")
  #step_4=("nginx" "use" "default.conf" "add" "    server  phpsrv2:9000" "     server  phpsrv3:9000")
  #step_5=("nginx" "use" "default.conf" "delete" "     server  phpsrv3:9000")
  step_3=("websrv" "create" "Dockerfile" $endofsitename)
  step_4=("phpsrv" "create" "Dockerfile" $endofsitename)
  step_5=("websrv" "use" "Dockerfile" "replace" "tplwebsrv" "websrv")
  step_6=("." "create" "docker-compose.yml" $endofsitename)
  step_7=("." "use" "docker-compose.yml" "replace" "- tplphp" " - phpsrv1")
  step_8=("." "use" "docker-compose.yml" "replace" "tplphp:" "phpsrv1:")
  step_9=("." "use" "docker-compose.yml" "replace" "tplweb:" "websrv:")
  step_10=("." "use" "docker-compose.yml" "replace" "replicas: 1" "replicas: 1")
  step_11=("." "use" "docker-compose.yml" "replace" "tplwebsrv" "websrv")
  step_12=("." "use" "docker-compose.yml" "replace" "tplphpsrv" "phpsrv")

  # sources for containers

  step_13=("." "use" "docker-compose.yml" "replace" "tpl_targetsrv" ${sourceservername,,})
  step_14=("." "use" "docker-compose.yml" "replace" "tpl_projectname" ${projectname,,})
  step_15=("." "use" "docker-compose.yml" "replace" "tplsitename" ${sitename,,})
  step_16=("websrv" "build" "Dockerfile" ${sourceservername} ${projectname} "${sitename}")
  step_17=("phpsrv" "build" "Dockerfile" ${sourceservername} ${projectname} "${sitename}")
  #step_18=("." "deploy" "docker-compose.yml" "${projectname}" "${sitename}")

  #step_14=("php" "build" "Dockerfile")
  #step_15=("php" "use" "Dockerfile" "replace" "tpl/php72" "reg.srv.local/codinsula/php72")





           # folders for build where Dockerfile(s) is located and seps
  declare -a buildfolders=(
    step_1[@]
    step_2[@]
    step_3[@]
    step_4[@]
    step_5[@]
    step_6[@]
    step_7[@]
    step_8[@]
    step_9[@]
    step_10[@]
    step_11[@]
    step_12[@]
    step_13[@]
    step_14[@]
    step_15[@]
    step_16[@]
    step_17[@]
  )



echo "Stoping stack :"${sitename}
docker stack rm "${sitename}"
#  echo "Clean up docker .... ."
#  docker system prune -a -f

   echo "Let's build a container(s) for project $projectname "

    arrayleght=${#buildfolders[@]}
     for (( i=1; i<${arrayleght}+1; i++ ));
     do
       folder="${!buildfolders[$i-1]:0:1}"
       file_task="${!buildfolders[$i-1]:1:1}"
       file="${!buildfolders[$i-1]:2:1}"
       task="${!buildfolders[$i-1]:3:1}"
       variable_name="${!buildfolders[$i-1]:4:1}"
       variable_value="${!buildfolders[$i-1]:5:1}"
#       echo "Folder" ${folder}    " leght "${#folder}
#       echo "Task ${file_task}"  " leght "${#file_task}
#       echo "File ${file}"  " leght "${#file}
#       echo "Task for file ${task}"  " leght "${#task}
#       echo "Variable name ${variable_name}"   " leght "${#variable_name}
#       echo "Variable value ${variable_value}"  " leght "${#variable_value}
       echo " "
       bash  ./${dockerdir}/scripts/build.sh ./${dockerdir}/${folder}/ ${file_task} ${file} ${task} "${variable_name}" "${variable_value}" ${folder}
#       echo "$i"
#       echo ${buildfolders[$i-1]}
#       ls -lh ./$dockerdir/${buildfolders[$i-1]}
#       pwd
#       bash ./$dockerdir/scripts/build.sh ./$dockerdir/${buildfolders[$i-1]}/ create default.conf
     done
     echo "Make changes in docker-compose.yml depending on project settings"
     bash ./${dockerdir}/scripts/build.sh "./${dockerdir}/./" "use" "docker-compose.yml" "replace" "- 99999:80" "- ${portnumber}:80"
# tpl_BUILD_ENV
     bash ./${dockerdir}/scripts/build.sh "./${dockerdir}/./" "use" "docker-compose.yml" "replace" "tpl_BUILD_ENV" "dev"
     echo "create and start docker stack"
     bash ./${dockerdir}/scripts/build.sh "./${dockerdir}/" "deploy" "docker-compose.yml" "${projectname}" "${sitename}"
     #   docker build --nocahe -f ./docker/
fi


if [ "$job" == "copy" ]; then

  case ${buildenv} in
     qa)
        echo "Prepering QA environment "

        step_1=("." "create" "docker-compose.yml" $endofsitename)
        step_2=("." "use" "docker-compose.yml" "replace" "- tplphp" " - phpsrv1")
        step_3=("." "use" "docker-compose.yml" "replace" "tplphp:" "phpsrv1:")
        step_4=("." "use" "docker-compose.yml" "replace" "tplweb:" "websrv:")
        step_5=("." "use" "docker-compose.yml" "replace" "replicas: 1" "replicas: 1")
        step_6=("." "use" "docker-compose.yml" "replace" "tplwebsrv" "websrv")
        step_7=("." "use" "docker-compose.yml" "replace" "tplphpsrv" "phpsrv")

        # sources for containers

        step_8=("." "use" "docker-compose.yml" "replace" "tpl_targetsrv" ${targetservername,,})
        step_9=("." "use" "docker-compose.yml" "replace" "tpl_projectname" ${projectname,,})
        step_10=("." "use" "docker-compose.yml" "replace" "tplsitename" ${sitename,,})
        step_11=("websrv" "copy" ${sourceservername,,} ${targetservername,,} ${projectname,,} "${sitename,,}")
        step_12=("phpsrv" "copy" ${sourceservername,,} ${targetservername,,} ${projectname,,} "${sitename,,}")

        declare -a buildfolders=(
          step_1[@]
          step_2[@]
          step_3[@]
          step_4[@]
          step_5[@]
          step_6[@]
          step_7[@]
          step_8[@]
          step_9[@]
          step_10[@]
          step_11[@]
          step_12[@]
          )

        echo "Let's manipulate with container(s) for project $projectname "

         arrayleght=${#buildfolders[@]}
          for (( i=1; i<${arrayleght}+1; i++ ));
          do
            folder="${!buildfolders[$i-1]:0:1}"
            file_task="${!buildfolders[$i-1]:1:1}"
            file="${!buildfolders[$i-1]:2:1}"
            task="${!buildfolders[$i-1]:3:1}"
            variable_name="${!buildfolders[$i-1]:4:1}"
            variable_value="${!buildfolders[$i-1]:5:1}"
#            echo "Folder" ${folder}    " leght "${#folder}
#            echo "Task ${file_task}"  " leght "${#file_task}
#            echo "File ${file}"  " leght "${#file}
#            echo "Task for file ${task}"  " leght "${#task}
#            echo "Variable name ${variable_name}"   " leght "${#variable_name}
#            echo "Variable value ${variable_value}"  " leght "${#variable_value}
#            echo " "
            bash  ./${dockerdir}/scripts/build.sh ./${dockerdir}/${folder}/ ${file_task} ${file} ${task} "${variable_name}" "${variable_value}" ${folder}

     #       echo "$i"
     #       echo ${buildfolders[$i-1]}
     #       ls -lh ./$dockerdir/${buildfolders[$i-1]}
     #       pwd
     #       bash ./$dockerdir/scripts/build.sh ./$dockerdir/${buildfolders[$i-1]}/ create default.conf
          done
          echo "Make changes in docker-compose.yml depending on project settings"
          bash ./${dockerdir}/scripts/build.sh "./${dockerdir}/./" "use" "docker-compose.yml" "replace" "- 99999:80" "- ${portnumber}:80"
          # tpl_BUILD_ENV >> qa
          bash ./${dockerdir}/scripts/build.sh "./${dockerdir}/./" "use" "docker-compose.yml" "replace" "tpl_BUILD_ENV" "qa"
#          bash ./${dockerdir}/scripts/build.sh "./${dockerdir}/./" "copy" "$sourceservername" "$targetservername" "$projectname" "$sitename"



        ;;
     prod)
        echo "Prepering Prod environment "
        ;;
     *)
        echo "`basename ${0}`:usage: dev|qa|prod"
        exit 1 # Command to come out of the program with status 1
        ;;
  esac
fi




echo "Exit ?"
