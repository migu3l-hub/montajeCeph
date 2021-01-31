#!/bin/bash
# EL SCRIPT DEBE COMENZAR CUANDO YA LOS 3 NODOS ESTAN ACTIVOS

MONTADO=0
COUNTER=0

# wait till next loop
SECONDS=15

#stop testing after N times
TRIES=30

function validarMontaje() {
  while [ $NODE != 3 ]; do
        NODE=$(docker node ls | grep -c Ready)
        echo "En espera de los demas nodos.."
        sleep 15
  done
  until [  $COUNTER -eq "$TRIES" ]
    do
        let COUNTER=COUNTER+1
        mount -a
        if [ $? -eq 0 ]
	        then
	          MONTADO=1
	        if [ $MONTADO -eq 1 ]
	          then
		          COUNTER=$TRIES
	          else
		          MONTADO=0
	        fi
	      else
	        sleep $SECONDS
        fi
  done
}

validarMontaje

if [ $MONTADO -eq 1 ]
    then
          echo "montaje correcto"
	        exit 0
    else
          echo "paso por el else aun no montado"
          for i in $(docker service ls -qf name=ceph_mon) ; do docker service update $i ; done
          validarMontaje # -bailing, had to many tries
fi