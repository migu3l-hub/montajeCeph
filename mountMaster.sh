#!/bin/bash -x
#EL SCRIPT DEBE COMENZAR CUANDO YA LOS 3 NODOS ESTAN ACTIVOS
#CUANDO FALLA TODOS LOS INTENTOS REINICIA TODOS LOS CONETENEDORES DE CEPH Y VUELVE A EMPEZAR
#Poner un ultimo if que pregunte si el mgr esta activo 3 veces por que inicia activo y luego se quita


function validarMontaje() {
  MONTADO=0
  COUNTER=0
  NODE=0
  MON=""
  #stop testing after N times
  TRIES=20
  until [ $NODE -ge 2 ]; do
      NODE=$(docker node ls | grep -c Ready)
      echo "En espera de los demas nodos.."
      sleep 15
  done
  until [ "$MON" != "" ]; do
      MON=$(docker ps -qf name=ceph_mon)
      echo "En espera del mon"
      sleep 10
  done
  until [  $COUNTER -eq "$TRIES" ]
    do
        let COUNTER=COUNTER+1
        is_OK=$(docker exec -i "$(docker ps -qf name=ceph_mon)" ceph status | grep -c HEALTH_OK) 2>/dev/null
        lines=$(docker exec -i "$(docker ps -qf name=ceph_mon)" ceph status | wc -l) 2>/dev/null
        mgr=$(docker exec -i "$(docker ps -qf name=ceph_mon)" ceph status | grep -c "no active mgr")
        if [ $is_OK -eq 1 ] || [ $lines -le 20 ] && [ $mgr -eq 0 ] && [ $lines -ne 0 ]; then
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

function remakeCeph() {
  CONTENEDORES=0
  until [ $NODE -ge 3 ]; do
    NODE=$(docker node ls | grep -c Ready)
    echo "En espera de los demas nodos.."
    sleep 15
  done
  CONTENEDORES=$(docker service ls | grep evaluador | awk '{ print $4 }' | grep -c 0)
  if [ "$CONTENEDORES" -eq 0 ]; then
     echo "Hay contenedores del sec activo asi no se puede reinicicar ceph"
  else
     docker stack rm ceph
     sleep 20
     docker stack deploy ceph -c /home/tessec/clusterMaster/master_sec_swarm/ceph/docker-compose.yml ceph
  fi

}

#Inicio
validarMontaje

if [ $MONTADO -eq 1 ]; then
          echo "montaje correcto"
	        exit 0
  else
          echo "paso por el else aun no montado"
          echo "Volviendo a regenerar Ceph"
          remakeCeph
          validarMontaje
fi