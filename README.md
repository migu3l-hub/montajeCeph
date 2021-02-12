# montajeCeph
Script que sirve para resolver el problema del montaje no automatico de Ceph

El script mountMaster sirve para montar la carpeta de ceph cuando este se encuentre listo al igual que el script de mountWorker, la diferencia es que este script reinicia
todo el stack de ceph en el caso de que ocurran errores de sincronizacion y este no pueda salir por su propia cuenta, este reinicio solo lo debe hacer un nodo para 
no chochar con los demas de modo que el script de mountMaster debe estar en un solo nodo del cluster, el que sea, pero se recomienda que sea que que tenga mas recursos, y cuando este
falle todos los intentos de montaje reiniciara Ceph y volvera a empezar

El script mountWorker debe estar en todos los nodos del cluster excepto en el que se puso el mountMaster, este script solo intenta montar la carpeta y cuando falla todos los 
intentos espera un rato y lo vuelve a intentar ya que el script mountMaster ha reiniciado el stack y los errores de sincronizacion deberan desaparecer.

Para agregar estos scripts al arranque del sistema como proceso se recomienda seguir los siguientes enlaces con tutoriales para llevarlo a cabo de la manera 
que mejor se considere.

https://superuser.com/questions/278396/systemd-does-not-run-etc-rc-local

https://unix.stackexchange.com/questions/308311/systemd-service-runs-without-exiting

https://unix.stackexchange.com/questions/337860/service-in-arch-not-starting-on-pc-boot
