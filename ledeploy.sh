#!/bin/bash


#########################################

# Description: déploiement à la volé de conteneur docker.

#################################################

if [ "$1" == "--create" ];then


 # Définition du nombre conteneur 
  nb_machine=1
    [ "$2" != "" ] && nb_machine=$2

 # setting min/max
  min=1
  max=0
 # récupération de l'idmax
 idmax=` docker ps -a --format 'table {{.ID}} {{.Names}}' | awk -F "-" -v user=$USER '$0 ~ user"-debian"{print $3}' | sort -r | head -1`
 # redéfinition de min et max
 min=$(($idmax + 1))
 max=$(($idmax  + $nb_machine))

 
  for i in $(seq $min $max) ; do 
  
  # docker run  -tid --name $USER-alpine-$i alpine:latest
   docker run  -tid --cap-add NET_ADMIN --cap-add SYS_ADMIN --publish-all=true -v /srv/data:/srv/html -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name $USER-debian-$i -h $USER-debian-$i registry.gitlab.com/ntyoussouf/imagedock:v1.0
   docker exec -ti $USER-debian-$i /bin/sh -c "useradd -m -p sa3tHJ3/KuYvI $USER"
   # Copier sur chaque conteneur 
   docker exec -ti $USER-debian-$i /bin/sh -c "mkdir ${HOME}/.ssh && chmod 700 ${HOME}/.ssh && chown $USER:$USER $HOME/.ssh"
   docker cp $HOME/.ssh/id_rsa.pub $USER-debian-$i:$HOME/.ssh/authorized_keys
   docker exec -ti $USER-debian-$i /bin/sh -c "chmod 600 ${HOME}/.ssh/authorized_keys && chown $USER:$USER $HOME/.ssh/authorized_keys"
   # Ajout su SUDOERS
   docker exec -ti $USER-debian-$i /bin/sh -c "echo '$USER ALL=(ALL) NOPASSWD: ALL'>>/etc/sudoers"
   # demarrer le service 
   docker exec -ti $USER-debian-$i /bin/sh -c "service ssh start"
   echo "Conteneur $USER-debian-$i crée"
   done      
   echo ""
      elif [ "$1" == "--drop" ];then
      nb_machine=1
      [ "$2" != "" ] && nb_machine=$2
      echo ""
      for i in $(seq 1 $nb_machine) ; do 
      echo $i
       docker rm -f $USER-$i
      done
      echo ""
           elif [ "$1" == "--info" ];then
           echo ""
           for conteneur  in $(docker ps -a | grep $USER-debian |  awk '{print $1}');do 
               docker inspect -f ' => {{.Name}} - {{.NetworkSettings.IPAddress }}' $conteneur
           done 
           echo ""
                elif [ "$1" == "--start" ];then
                echo
                # recupération d' ID
               #  docker ps -a | grep $USER-alpine | awk '{print $1}'
                # Ajouter start
                docker start $( docker ps -a | grep $USER-debian | awk '{print $1}')
                echo ""  
                     elif [ "$1" == "--ansible" ];then
                     echo
                     echo "Lancer Ansible"
                     echo
                          elif [ "$1" == "--stop" ];then
                          echo ""
                          docker stop $( docker ps -a | grep $USER-debian | awk 'print $1')
                          echo ""

else
echo "
Options:
       - --create : lancer 
       - --drop : supprimer
"
fi
