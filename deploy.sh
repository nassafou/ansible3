#!/bin/bash

############################################################
#
#  Description : déploiement à la volée de conteneur docker
#
#  Auteur : Xavier
#
#  Date : 28/12/2018
#
###########################################################




#si option --create
if [ "$1" == "--create" ];then
	
	# définition du nombre de conteneur
  nb_machine=1
  [ "$2" != "" ] && nb_machine=$2
  
	# setting min/max
	min=1
	max=0

  # récupération de idmax
	idmax=`docker ps -a --format '{{ .Names}}' | awk -F "-" -v user="$USER" '$0 ~ user"-alpine" {print $3}' | sort -r |head -1`

	# redéfinition de min et max
	min=$(($idmax + 1))
	max=$(($idmax + $nb_machine))

  # lancement des conteneurs
	for i in $(seq $min $max);do
		docker run -tid --cap-add NET_ADMIN --cap-add SYS_ADMIN --publish-all=true -v /srv/data:/srv/html -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name $USER-debian-$i -h $USER-debian-$i registry.gitlab.com/xavki/presentations-scripting/debian-systemd:v1.0
		docker exec -ti $USER-debian-$i /bin/sh -c "useradd -m -p sa3tHJ3/KuYvI $USER"
		docker exec -ti $USER-debian-$i /bin/sh -c "mkdir  ${HOME}/.ssh && chmod 700 ${HOME}/.ssh && chown $USER:$USER $HOME/.ssh"
    docker cp $HOME/.ssh/id_rsa.pub $USER-debian-$i:$HOME/.ssh/authorized_keys
    docker exec -ti $USER-debian-$i /bin/sh -c "chmod 600 ${HOME}/.ssh/authorized_keys && chown $USER:$USER $HOME/.ssh/authorized_keys"
		docker exec -ti $USER-debian-$i /bin/sh -c "echo '$USER   ALL=(ALL) NOPASSWD: ALL'>>/etc/sudoers"
		docker exec -ti $USER-debian-$i /bin/sh -c "service ssh start"
		echo "Conteneur $USER-debian-$i créé"
	done


# si option --drop
elif [ "$1" == "--drop" ];then

	echo "Suppression des conteneurs..."
	docker rm -f $(docker ps -a | grep $USER-debian | awk '{print $1}')
	echo "Fin de la suppression"


# si option --start
elif [ "$1" == "--start" ];then
  
  echo ""
  docker start $(docker ps -a | grep $USER-debian | awk '{print $1}')
	echo ""



# si option --ansible
elif [ "$1" == "--ansible" ];then
  
  echo ""
	echo " notre option est --ansible"
	echo ""



# si option --infos
elif [ "$1" == "--infos" ];then
  
  echo ""
  echo "Informations des conteneurs : "
  echo ""
	for conteneur in $(docker ps -a | grep $USER-debian | awk '{print $1}');do      
		docker inspect -f '   => {{.Name}} - {{.NetworkSettings.IPAddress }}' $conteneur
	done
	echo ""



# si aucune option affichage de l'aide
else

echo "

Options :
		- --create : lancer des conteneurs

		- --drop : supprimer les conteneurs créer par le deploy.sh
	
		- --infos : caractéristiques des conteneurs (ip, nom, user...)

		- --start : redémarrage des conteneurs

		- --ansible : déploiement arborescence ansible

"

fi
