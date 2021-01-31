#!/bin/bash
# EL SCRIPT DEBE COMENZAR CUANDO YA LOS 3 NODOS ESTAN ACTIVOS



function validarMontaje() {
  MONTADO=0
  COUNTER=0
  NODE=0
  # wait till next loop
  SECONDS=15

  #stop testing after N times
  TRIES=30
  until [ $NODE -ge 3 ]; do
        NODE=$(docker node ls | grep -c Ready)
        echo "En espera de los demas nodos.."
        sleep 15
  done
  until [  $COUNTER -eq "$TRIES" ]
    do
        let COUNTER=COUNTER+1
        is_OK=$(docker exec -i "$(docker ps -qf name=ceph_mon)" ceph status | grep -c HEALTH_OK)
        lines=$(docker exec -i "$(docker ps -qf name=ceph_mon)" ceph status | wc -l)
        if [ $is_OK -eq 1 ] || [ $lines -lt 19 ]; then
	          mount -a
	          if [ $? -eq 0 ]; then
	              MONTADO=1
	          else
	              MONTADO=0
	          fi
            if [ $MONTADO -eq 1 ]; then
                COUNTER=$TRIES
              else
                MONTADO=0
            fi
	      else
	        sleep 15
        fi
  done
}

validarMontaje

if [ $MONTADO -eq 1 ]; then
          echo "montaje correcto"
	        exit 0
  else
          echo "paso por el else aun no montado"
          for i in $(docker service ls -qf name=ceph_mon) ; do docker service update $i ; done
          COUNTER=0
          validarMontaje # -bailing, had to many tries
fi