# cantillo-post1-u5

## Descripción General
El presente repositorio documenta la actividad de laboratorio guiado de la Unidad 5 de Arquitectura de Computadores, enfocada en contrastar la emulación por software frente a la virtualización asistida por hardware. En la Parte 1, el estudiante configura un entorno DOSBox con NASM para ensamblar, depurar con `DEBUG` y ejecutar programas reales de 16 bits (`saludo.asm`, `entrada.asm` y `ciclos.asm`). En la Parte 2, se crea y administra una máquina virtual con Alpine Linux 3.19 en Oracle VirtualBox mediante `VBoxManage`, evaluando modos de red, *snapshots*, reasignación de recursos, rendimiento de discos virtuales y exportación en formato OVF/OVA.

## Entorno de Trabajo
- **Parte 1 (Emulación):** DOSBox 0.74-3+, NASM 2.x para DOS (`nasm.exe`), configuración en `dosbox.conf` (`core=normal`, `cycles=8000`, `memsize=16`).
- **Parte 2 (Virtualización):** Oracle VirtualBox 7.x, VM `Lab5-Alpine` con Alpine Linux 3.19 (Standard x86_64), 1024 MB a 2048 MB de RAM, 1 a 2 vCPUs, disco dinámico de 10 GB (`Lab5-Alpine.vdi`) y disco fijo de 4 GB (`Lab5-Alpine-fixed.vdi`).

## Compilación y Ejecución (Parte 1)
```bat
cd src
nasm -f bin saludo.asm -o ..\bin\saludo.com
nasm -f bin entrada.asm -o ..\bin\entrada.com
nasm -f bin ciclos.asm -o ..\bin\ciclos.com
cd ..
bin\saludo
bin\entrada
bin\ciclos
```

## Registro de Mediciones Locales (Completar tras ejecutar en DOSBox y VirtualBox)

### Comparación de `cycles` en DOSBox (`ciclos.com`)
| Corrida | `cycles` | Hora inicial (cc) | Hora final (cc) | Duración observada (centésimas) |
| --- | --- | --- | --- | --- |
| 1 | 8000 | [Completar en ejecución local] | [Completar en ejecución local] | [Calcular] |
| 2 | 1000 | [Completar en ejecución local] | [Completar en ejecución local] | [Calcular] |
| 3 | 20000 | [Completar en ejecución local] | [Completar en ejecución local] | [Calcular] |

### Modos de Red en VirtualBox (`Lab5-Alpine`)
| Modo de Red | Dirección IP (`eth0`) | Conectividad Internet (`8.8.8.8`) | Alcance desde Anfitrión |
| --- | --- | --- | --- |
| NAT | [Completar] | Sí | Aislada (solo reenvío de puertos) |
| Host-Only | [Completar] | No | Sí (red privada `vboxnet0`) |
| Bridge | [Completar] | Sí | Sí (misma subred física) |

### Benchmark de Disco Fijo frente a Dinámico (`dd` 200 MB)
| Tipo de disco | Comando | Tiempo real (`real`) |
| --- | --- | --- |
| Fijo (`Lab5-Alpine-fixed.vdi`) | `time dd if=/dev/zero of=/mnt/fijo/test.img bs=1M count=200` | [Completar] |
| Dinámico (`Lab5-Alpine.vdi`) | `time dd if=/dev/zero of=/root/test.img bs=1M count=200` | [Completar] |

---

## Decisiones Técnicas Justificadas

### Parte 1 — Decisión 1: Valor correcto de `cycles` para un laboratorio reproducible
Para garantizar mediciones reproducibles en `ciclos.com`, el valor apropiado en `dosbox.conf` es una constante fija como `cycles=8000`, en lugar de `cycles=max` o `cycles=auto`. Si se configurara `cycles=max`, DOSBox emularía tantas instrucciones por segundo como permitiera la capacidad libre del procesador anfitrión moderno; en consecuencia, el bucle fijo de `ciclos.com` concluiría de manera casi instantánea (en pocas centésimas de segundo o cero), invalidando el propósito experimental de observar variaciones proporcionales en el tiempo de ejecución. Por su parte, un valor fijo como `cycles=8000` establece una tasa uniforme de instrucciones virtuales por segundo, permitiendo comparar resultados de forma consistente entre equipos con procesadores anfitriones de muy distinta potencia. Fuera de este laboratorio, `cycles=max` o `cycles=auto` sí resultan recomendables al ejecutar aplicaciones de productividad o compiladores DOS modernos cuya temporización no depende de bucles de espera ligados al reloj del procesador.

### Parte 1 — Decisión 2: Tiempo emulado (`cycles`) frente a ciclos de reloj reales del anfitrión
Comparar directamente el parámetro `cycles=8000` de `dosbox.conf` con la frecuencia física del procesador anfitrión (medida en GHz, es decir, miles de millones de ciclos reales por segundo) constituye un error de categoría. El valor `cycles` representa aproximadamente la cantidad de instrucciones x86 de 16 bits emuladas por milisegundo virtual dentro de DOSBox, mientras que los GHz del silicio físico miden pulsos de reloj de hardware real. En la práctica, el procesador anfitrión invierte cientos o miles de ciclos reales por cada instrucción emulada, porque DOSBox debe decodificar, validar y traducir por software cada instrucción del 8086 mediante múltiples instrucciones nativas, lo que explica el consumo de CPU observable del proceso `DOSBox.exe` en el sistema operativo anfitrión. Para estimar con precisión los ciclos o el tiempo de CPU real consumido por la ejecución de `ciclos.com`, la herramienta adecuada es un perfilador de procesos del sistema anfitrión (como `perf` en Linux, el Monitor de Recursos o el Administrador de Tareas de Windows).

### Parte 2 — Decisión 1: Modo de red apropiado para una VM de laboratorio personal y seguridad
En una máquina virtual de práctica ejecutada en un equipo personal sin requerimiento de acceso externo, el modo de red más apropiado por defecto es **NAT**. Bajo NAT, VirtualBox actúa como enrutador privado y traduce las conexiones salientes de la VM hacia internet mediante la dirección del anfitrión, manteniendo a la máquina virtual aislada frente a conexiones entrantes no solicitadas desde la red local. En contraste, dentro de un curso de Arquitectura de Computadores sería preferible **Host-Only** cuando se requiera experimentar con servicios de red o pruebas de comunicación entre el anfitrión y la VM en un entorno hermético sin ningún tráfico externo, asumiendo la pérdida funcional de acceso a internet (por ejemplo, imposibilidad de usar `apk add`). Finalmente, el modo **Bridge** representa el mayor riesgo de seguridad para este escenario, ya que asigna a la VM una dirección IP directa en la red física local, exponiendo todos sus puertos y servicios activos —como el demonio `sshd` de Alpine— a cualquier otro dispositivo conectado a esa misma red.

### Parte 2 — Decisión 2: Disco fijo frente a dinámico y asignación razonable de CPU/RAM
De acuerdo con el funcionamiento interno de VirtualBox, un disco de tamaño fijo (`Lab5-Alpine-fixed.vdi`) ofrece mayor velocidad en escritura secuencial frente a un disco dinámico, ya que reserva todos los bloques contiguos desde su creación y evita el costo adicional de asignar clústeres nuevos y expandir el archivo `.vdi` en el sistema de archivos del anfitrión durante cada escritura. No obstante, el disco dinámico continúa siendo la opción preferida por defecto en laboratorios académicos con múltiples estudiantes y almacenamiento limitado, porque ocupa en el anfitrión únicamente el espacio real utilizado por el sistema huésped en lugar de bloquear varios gigabytes vacíos desde el inicio. Respecto al cómputo, asignar 2 vCPUs y 2048 MB de RAM a `Lab5-Alpine` resulta equilibrado en un anfitrión de 4 a 8 núcleos y 8 a 16 GB de RAM; en cambio, asignar todos los núcleos o la mayor parte de la memoria física dejaría sin recursos al sistema operativo anfitrión, provocando contención de planificación y paginación severa.

---

## Conclusiones
El contraste entre ambas partes evidencia la diferencia estructural entre emulación y virtualización: DOSBox reproduce por software la arquitectura x86 de 16 bits y el entorno DOS con un costo de traducción elevado pero controlado mediante `cycles`, mientras VirtualBox ejecuta instrucciones x86-64 de forma casi nativa apoyándose en extensiones de hardware (VT-x/AMD-V) para aislar un sistema Linux completo con gestión avanzada de red, *snapshots*, recursos dinámicos y portabilidad mediante OVF.
