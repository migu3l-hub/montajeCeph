#!/bin/bash
# EL SCRIPT DEBE COMENZAR CUANDO YA LOS 3 NODOS ESTAN ACTIVOS
# CUANDO FALLA TODOS LOS INTENTOS SOLO ESPERA UNOS SEGUNDOS Y LO VUELVE A INTENTAR



function validarMontaje() {
  MONTADO=0
  COUNTER=0
  NODE=0

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
        is_OK=$(docker exec -i "$(docker ps -qf name=ceph_mon)" ceph status | grep -c HEALTH_OK) 2>/dev/null
        lines=$(docker exec -i "$(docker ps -qf name=ceph_mon)" ceph status | wc -l) 2>/dev/null
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
          sleep 30
          COUNTER=0
          validarMontaje
fi