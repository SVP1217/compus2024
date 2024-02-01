@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: sergi.vives@estudiants.urv.cat				  ===
@;=== Programador tarea 1F: sergi.vives@estudiants.urv.cat				  ===
@;=                                                         	      	=



.include "../include/candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz,f,c,ori): rutina para contar el número de
@;	repeticiones del elemento situado en la posición (f,c) de la matriz, 
@;	visitando las siguientes posiciones según indique el parámetro de
@;	orientación 'ori'.
@;	Restricciones:
@;		* sólo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;		* la primera posición también se tiene en cuenta, de modo que el número
@;			mínimo de repeticiones será 1, es decir, el propio elemento de la
@;			posición inicial
@;	Parámetros:
@;		R0 = dirección base de la matriz
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R3 = orientación 'ori' (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = número de repeticiones detectadas (mínimo 1)
	.global cuenta_repeticiones
cuenta_repeticiones:
		push {r1-r11,lr}
		@; Sección ENTRADA
		mov r4, #1 					@; r4: repeticiones del elemento = 1
		mov r10, #COLUMNS 			@; r10 registro temporal para guardar el valor de la constante COLUMNS
		mla r7, r1, r10, r2 		@; Obtenemos en r7 i*COLUMNS + j
		add r6, r7, r0 				@; Obtenemos en r6 i*COLUMNS+j+@matriu, obteniendo la dirección a la que apunta el primer elemento
		ldrb r8, [r6]				@; Cargamos a registros el contenido de la posición actual de la matriz
		and r5, r8, #0x00000007		@; Hacemos una máscara, poniendo todos los bits a 0 excepto los 3 últimos que mantendrán su valor en r5
		cmp r3, #1					@; Comparamos ori con 1
		bgt .Mesgran				@; Si es mayor es 2 o 3 ve a más grande
		beq .Sud					@; Si es 1 significa que ori es sur y ve a sur
		@; Sección EST
		.Est:
		mov r11, #COLUMNS
		sub r11, #1
		cmp r2, r11					@; Comparamos con COLUMNS
		bge .Exit					@; Si es mayor o igual ve a la sección de salida
		add r6, #1 					@; Pasamos al siguiente elemento
		add r2, #1					@; Modificamos el índice sumando 1
		ldrb r8, [r6]				@; Cargamos a r8 el contenido de memoria al que apunta r6 (siguiente elemento)
		and r7, r8, #0x00000007		@; Tres bits de menos peso del elemento actual
		cmp r5, r7					@; Comparamos los tres bits de menos peso del elemento actual con el primer elemento
		bne .Exit					@; Si son diferentes ve a la sección exit
		add r4, #1					@; Añade repetición porque son iguales
		b .Est
		.Sud:
		@; Sección SUR
		mov r11, #ROWS
		sub r11, #1
		cmp r1, r11					@; Comparamos con ROWS
		bge .Exit					@; Si es mayor o igual ve a la sección de salida
		mov r8, #COLUMNS			@; Cargamos el valor de COLUMNS a r8
		add r6, r8		 			@; Pasamos al siguiente elemento
		add r1, #1					@; Modificamos el índice sumando 1
		ldrb r8, [r6]				@; Cargamos a r8 el contenido de memoria al que apunta r6 (siguiente elemento)
		and r7, r8, #0x00000007		@; Tres bits de menos peso del elemento actual a r7
		cmp r5, r7					@; Comparamos los tres bits de menos peso del elemento actual con el primer elemento
		bne .Exit					@; Si son diferentes ve a la sección exit
		add r4, #1					@; Añade repetición porque son iguales
		b .Sud						@; Vuelve a empezar el bucle de recorrido
		.Mesgran:
		cmp r3, #2
		beq .Oest
		@; Sección NORTE
		.Norte:
		cmp r1, #0					@; Comparamos con 0
		ble .Exit					@; Si es menor o igual ve a la sección de salida
		mov r8, #COLUMNS			@; Cargamos el valor de COLUMNS a r8
		sub r6, r8					@; Pasamos al siguiente elemento
		sub r1, #1					@; Modificamos el índice restando 1
		ldrb r8, [r6]				@; Cargamos a r8 el contenido de memoria al que apunta r6 (siguiente elemento)
		and r7, r8, #0x00000007		@; Tres bits de menos peso del elemento actual a r7
		cmp r5, r7					@; Comparamos los tres bits de menos peso del elemento actual con el primer elemento
		bne .Exit					@; Si son diferentes ve a la sección exit
		add r4, #1					@; Añade repetición porque son iguales
		b .Norte					@; Vuelve a empezar el bucle de recorrido
		.Oest:
		@; Sección OESTE
		cmp r2, #0
		ble .Exit
		sub r6, #1 					@; Pasamos al siguiente elemento
		sub r2, #1					@; Modificamos el índice restando 1
		ldrb r8, [r6]				@; Cargamos a r8 el contenido de memoria al que apunta r6 (siguiente elemento)
		and r7, r8, #0x00000007		@; Tres bits de menos peso del elemento actual
		cmp r5, r7					@; Comparamos los tres bits de menos peso del elemento actual con el primer elemento
		bne .Exit					@; Si son diferentes ve a la sección exit
		add r4, #1					@; Añade repetición porque son iguales
		b .Oest
		@; Sección EXIT El programa siempre terminará aquí, por lo tanto, realizamos las operaciones pertinentes de salida
		.Exit:
		mov r0, r4
		pop {r1-r11, pc}


@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vacías, primero en vertical y después en sentido inclinado; cada llamada a
@;	la función sólo baja elementos una posición y devuelve cierto (1) si se ha
@;	realizado algún movimiento, o falso (0) si está todo quieto.
@;	Restricciones:
@;		* para las casillas vacías de la primera fila se generarán nuevos
@;			elementos, invocando la rutina 'mod_random' (ver fichero
@;			"candy1_init.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado algún movimiento, de modo que puede que
@;				queden movimientos pendientes. 
	.global baja_elementos
baja_elementos:
		push {r4, lr}
		mov r4, r0
		.b:
		bl baja_verticales
		cmp r0, #1
		beq .end
		bl baja_laterales
		.end:
		pop {r4, pc}


@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_verticales:
		push {r1-r11, lr}
		@;add r4, #COLUMNS				Factor de corrección: La vista de la NDS y la posición en memoria de la matriz están desplazadas una fila
		mov r10, #0						@;No hemos hecho ningún movimiento hasta que no se haga lo contrario
		mov r1, #ROWS					@;Cargamos índice filas
		mov r2, #COLUMNS				@;Cargamos índice columnas				
		mla r3, r1, r2, r4				@;Vamos a la última posición, por lo tanto, los índices son los valores de las constantes
		sub r3, #1						@;Restamos 1 para ajustar (se va una casilla más allá de la última posición de la matriz)
		sub r1, #1						@;Fase 2IC: Restamos 1 para ajustar el índice (0-ROWS-1)
		sub r2, #1						@;Fase 2IC: Restamos 1 para ajustar el índice (0-COLUMNS-1)
		@;BUCLE DE RECORRIDO DE LA MATRIZ
		.whilemove: 				
		ldrb r8, [r3]					@;Cargamos a r8 el contenido de la posición actual
		cmp r1, #0						@;Miramos si es la primera fila				
		beq .primerafila				@;Trata primera fila
		.segueix:
		and r11, r8, #7					@;Limpiamos bits de tipo
		cmp r11, #0						@;Comparamos bits de menos peso con 0
		bne .notractes					@;Salta al final del while si el elemento no está vacío (pasamos a la siguiente celda)
		b .tractar						@;Sino tratamos el elemento 
		@;SECCIÓN PRIMERA FILA (ELEMENTOS A 0 PRIMERA FILA)
		.primerafila:
		mov r7, r3						@;Guardamos la posición en la que estamos
		mov r5, r1						@;Fase 2IC: Utilizamos el temporal r5 para poder calcular la fila donde se debe crear el sprite
		.bucle:
		cmp r8, #15						@;Comparamos con 15
		addeq r7, #COLUMNS				@;Desplazamos hacia abajo
		addeq r5, #1					@;Fase 2IC: Sumamos 1 para actualizar el índice
		ldrb r8, [r7]					@;Cargamos contenido de la posición de más abajo (o la misma si no hemos encontrado huecos)
		cmp r8, #15						@;Compara con 15
		beq .bucle						@;Continua bajando si encuentras 15
		and r11, r8, #7					@;Corregimos bits
		cmp r11, #0						@;Compara con 0
		bne .notractes					@;Si no es elemento vacío, sal al final...
		@;Y sino tendrás que generar un aleatorio
		mov r0, #6						@;Le pasamos un 6 a la rutina mod random
		bl mod_random					@;Llamamos mod random (genera aleatorio entre 0 y 5)
		add r0, #1						@;Sumamos 1 para corregir 
		
		
		push {r0-r3}					@;Fase 2IC: Salvamos estado del registro r1
		mov r1, #-1						@;Fase 2IC: Movemos la fila donde se debe crear el sprite a r1 para pasar los parámetros
		bl crea_elemento				@;Fase 2IC: Generación del sprite (se pasa por r0=tipo de gelatina, r1=fila, r2=columna)
		mov r0, #-1
		mov r1, r2
		mov r2, r5
		mov r3, r1
		bl activa_elemento
		pop {r0-r3}						@;Fase 2IC: Recuperamos estado del registro r1
		
		add r8, r0						@;Sumamos la gelatina que había (que será 0, 8 o 16) al aleatorio correspondiente
		strb r8, [r7]					@;Guardamos el elemento generado en la posición que le toca
		mov r10, #1						@;Salida de parámetros
		b .notractes					@;Salimos de esta sección para avanzar
		@;SECCIÓN ELEMENTO VACÍO
		.tractar:
		mov r5, r1						@;Fase 2IC: Utilizamos el temporal r5 para poder calcular la fila origen (parámetro de activa_elemento)
		mov r6, r3						@;Salvamos la posición tratada en r6					
		.whiletractar:					@;Bucle de tratamiento
		cmp r5, #0						@;Fase 2IC: Si resulta que estamos en la fila 0
		beq .notractes					@;Fase 2IC: Vuelve a iterar porque te vas fuera de la matriz
		sub r6, #COLUMNS				@;Restamos el valor de columnas para acceder a la casilla superior
		sub r5, #1						@;Fase 2IC: Restamos 1 al índice
		ldrb r8, [r6]					@;Cargamos a r8 el contenido de la casilla superior
		cmp r8, #15						@;Si hay un "hueco"...
		beq .whiletractar				@;...subimos una casilla más
		cmp r8, #7						@;Miramos si hay un bloque fijo
		beq .notractes					@;Y salimos si lo hay
		and r9, r8, #7					@;Máscara de bits
		cmp r9, #0						@;Si es un elemento vacío entonces... 
		beq .notractes					@;...salimos
		sub r12, r8, r9					@;Y sino a la casilla superior le quitamos los bits de tipo
		strb r12, [r6]					@;Guarda los bits de gelatina en la posición donde estaba (hemos eliminado los de tipo) por lo tanto quedará en 0, 8 o 16
		ldrb r11, [r3]					@;Cargamos a r11 gelatina a tratar que será 0, 8 o 16
		add r6, r11, r9					@;Suma bits de la casilla a tratar más el tipo de la que baja
		
		push {r0-r4}					@;Fase 2IC: Salvamos estado de los registros para la pasada de parámetros
		mov r0, r5 						@;Fase 2IC: r0=fila origen
		mov r4, r1						@;Fase 2IC: Guardo el valor de fila destino
		mov r1, r2						@;Fase 2IC: r1=columna origen
		mov r3, r2						@;Fase 2IC: r3=columna destino (será la misma que la origen debido a que es un desplazamiento vertical)
		mov r2, r4						@;Fase 2IC: r2=fila destino
		bl activa_elemento				@;Fase 2IC: fila origen, columna origen, fila destino, columna destino	
		pop {r0-r4}						@;Fase 2IC: recuperamos estado de los registros
		
		strb r6, [r3]					@;Guardamos en la casilla tratada (la inferior)
		mov r10, #1						@;Hemos hecho movimiento por lo tanto...
		@;SECCIÓN AVANZAR/TRACTAMIENTO DE ÍNDICE
		.notractes:
		sub r3, #1						@;Restamos 1, como que las matrices en ARM son en realidad tablas podemos desplazarnos restando 1 hasta que el elemento actual sea la posición base de la matriz
		cmp r2, #0						@;Comprobamos que el índice de columna no ha llegado a 0
		bne .canvicolumna				@;Si no ha llegado a 0 cambia la columna
		cmp r1, #0						@;Si ha llegado a 0, Compara fila con 0
		beq .Surt						@;Y si todo es 0 ve a la salida porque ya hemos recorrido la matriz
		mov r2, #COLUMNS				@;Si solo la columna es 0, volvemos a cargar el máximo número de columnas...
		sub r2, #1
		sub r1, #1						@;...restamos una fila y 
		b .whilemove					@;Pasamos a la siguiente celda...
		.canvicolumna:
		sub r2, #1						@;Resta 1 a columnas si aún no ha llegado a 0
		b .whilemove					@;Y pasa a la siguiente celda...
		.Surt:
		mov r0, r10						@;Salida de parámetros
		pop {r1-r11, pc}



@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_laterales:
		push {r1-r11, lr}
		mov r1, #ROWS				@;Cargamos índice fila
		mov r2, #COLUMNS			@;Cargamos índice columna	
		mla r3, r1, r2, r4			@;Apuntamos a la primera posición válida de la matriz
		sub r1, #1
		sub r2, #1
		mov r10, #0					@;No hemos hecho ningún movimiento hasta que no se haga lo contrario

		sub r3, #1					@;Restamos 1 para corregir
		.buclewhile:
		ldrb r6, [r3]				@;Cargamos contenido a r6
		cmp r6, #15
		beq .passaseguent			@;Pasamos al siguiente elemento
		cmp r6, #7
		beq .passaseguent			@;Pasamos al siguiente elemento
		and r7, r6, #7					@;Limpiamos bits de gelatina
		cmp r7, #0					@;Comparamos con 0
		bne .passaseguent			@;Pasamos al siguiente elemento
		mov r9, #0					@;Ponemos flag a 0
		@;Casillas de la izquierda
		cmp r2, #0					@;Miramos si estás en el límite izquierdo de la matriz
		beq .comprovadret			@;Si estás en el límite de la matriz, pasa a derecha directamente
		sub r5, r3, #COLUMNS		@;Restar columnas
		sub r5, r5, #1				@;Restamos 1 para ajustar
		ldrb r8, [r5]				@;Cargar a r8 el contenido de la posición que se tiene que mover
		cmp r8, #7					@;Comparamos con 7
		beq .comprovadret			@;Si no puedes, comprueba el elemento de la derecha
		cmp r8, #15					@;Comparamos con 15
		beq .comprovadret			@;Si no puedes, comprueba el elemento de la derecha
		and r8, #7					@;Limpiamos bits de gelatina
		cmp r8, #0					@;Comparamos con 0 para saber si el elemento está vacío
		addne r9, r9, #1			@;Añade al flag un 1
		.comprovadret:
		mov r11, #COLUMNS
		sub r11, #1
		cmp r2, r11					@;Miramos si estás en el límite derecho de la matriz
		beq .fi						@;Y si no, tratamos el elemento izquierdo
		sub r5, r3, #COLUMNS		@;Restar columnas
		add r5, r5, #1				@;Añadimos 1 al índice para 
		ldrb r8, [r5]				@;Cargar la posición de la derecha
		cmp r8, #7					@;Comparamos con 7 
		beq .fi						@;Si no puedes, ve al final
		cmp r8, #15					@;Comparamos con 15 
		beq .fi						@;Si no puedes, ve al final
		and r8, #7					@;Limpiamos bits de gelatina
		cmp r8, #0					@;Comparamos con 0 para saber si el elemento está vacío
		addne r9, r9, #2			@;Añade dos al flag
		.fi:
		cmp r9, #1					@;Compara con 1 el flag
		beq .Esquerra				@;Si 1 se puede bajar la izquierda
		cmp r9, #2					@;Compara con 2 el flag
		beq .Dreta					@;Si 2 se puede bajar la derecha
		cmp r9, #0					@;Compara con 0 el flag
		beq .passaseguent			@;Pasa al siguiente si no hay ningún elemento susceptible de bajada
		@;SECCIÓN DE ELECCIÓN ALEATORIA
		@; Entonces el flag es 3 y podemos bajar por los dos lugares, por lo tanto, generamos el aleatorio
		mov r0, #2					@;Cargamos un 2 a r0 (para pasar como parámetro)
		bl mod_random				@;Llamamos a la función de módulo aleatorio
		cmp r0, #0					@;Si no es 0			
		bne .Dreta					@;Vamos a la derecha arbitrariamente
		@;SECCIÓN IZQUIERDA
		.Esquerra:
		
		push {r0-r5}				@;Función I
		mov r4, r1
		mov r5, r2
		sub r0, r4, #1
		sub r1, r5, #1
		mov r2, r4
		mov r3, r5
		
		bl activa_elemento
		pop {r0-r5}
		
		sub r5, r3, #COLUMNS		@;Restar columnas
		sub r5, #1					@;Restamos 1 para ajustar
		ldrb r8, [r5]				@;Cargar a r8 el contenido de la posición que se tiene que mover
		and r9, r8, #24				@;Bit clear
		strb r9, [r5]				@;Guarda los bits de más peso donde estaban
		sub r8, r9					@;obtiene el código de menos peso
		add r9, r8, r6				@;Carga a r9 el contenido de la posición actual (será 0, 8 o 16) más el código de menos peso
		strb r9, [r3]				@;Guarda en la posición actual
		mov r10, #1					@;Pase de parámetros
		b .passaseguent				@;Salimos
		@;SECCIÓN DERECHA
		.Dreta:
		
		push {r0-r5}				@;Función I
		mov r4, r1
		mov r5, r2
		sub r0, r4, #1
		add r1, r5, #1
		mov r2, r4
		mov r3, r5
		bl activa_elemento
		pop {r0-r5}
		
		sub r5, r3, #COLUMNS		@;Restar columnas
		add r5, r5, #1				@;Sumamos 1 para ajustar
		ldrb r8, [r5]				@;Cargar a r8 el contenido de la posición que se tiene que mover
		and r9, r8, #24				@;Bit clear
		strb r9, [r5]				@;Guarda los bits de más peso donde estaban
		sub r8, r8, r9				@;obtiene el código de menos peso
		add r9, r8, r6				@;Carga a r9 el contenido de la posición actual (será 0, 8 o 16) más el código de menos peso
		strb r9, [r3]				@;Guarda en la posición actual
		mov r10, #1					@;Pase de parámetros
		@;SECCIÓN AVANZAR/TRACTAMIENTO DE ÍNDICE
		.passaseguent:
		sub r3, r3, #1					@;Restamos 1 para decrementar el índice
		cmp r2, #0						@;Comprobamos que el índice de columna no ha llegado a 0
		bne .passacolumna				@;Si no ha llegado a 0, cambia la columna
		cmp r1, #1						@;si ha llegado a 0, Compara fila con 1
		beq .Sortir						@;y si todo es el límite, ve a la salida porque ya hemos recorrido la matriz
		mov r2, #COLUMNS				@;Si solo la columna es 1, volvemos a cargar COLUMNS a columnas...
		sub r2, #1
		sub r1, r1, #1					@;...restamos una fila y 
		b .buclewhile					@;pasamos a la siguiente celda...
		.passacolumna:
		sub r2 ,r2, #1					@;sumamos 1 a columnas si aún no ha llegado a 1
		b .buclewhile					@;y pasa a la siguiente celda...
		.Sortir:
		mov r0, r10	
		pop {r1-r11,pc}



@;:::RUTINAS DE SOPORTE:::



@; mod_random(n): rutina para obtener un número aleatorio entre 0 y n-1,
@;	utilizando la rutina 'random'
@;	Restricciones:
@;		* el parámetro 'n' tiene que ser un valor entre 2 y 255, de otro modo,
@;		  la rutina lo ajustará automáticamente a estos valores mínimo y máximo
@;	Parámetros:
@;		R0 = el rango del número aleatorio (n)
@;	Resultado:
@;		R0 = el número aleatorio dentro del rango especificado (0..n-1).global mod_random
mod_random:
		push {r1-r4, lr}
		
		cmp r0, #2				@;compara el rango de entrada con el mínimo
		bge .Lmodran_cont
		mov r0, #2				@;si menor, fija el rango mínimo
	.Lmodran_cont:
		and r0, #0xff			@;filtra los 8 bits de menos peso
		sub r2, r0, #1			@;R2 = R0-1 (número más alto permitido)
		mov r3, #1				@;R3 = máscara de bits
	.Lmodran_forbits:
		cmp r3, r2				@;genera una máscara superior al rango requerido
		bhs .Lmodran_loop
		mov r3, r3, lsl #1
		orr r3, #1				@;inyecta otro bit
		b .Lmodran_forbits
		
	.Lmodran_loop:
		bl random				@;R0 = número aleatorio de 32 bits
		and r4, r0, r3			@;filtra los bits de menos peso según máscara
		cmp r4, r2				@;si resultado superior al permitido,
		bhi .Lmodran_loop		@; repite el proceso
		mov r0, r4			@; R0 devuelve número aleatorio restringido a rango
		
		pop {r1-r4, pc}
		
		
		
@;random(): rutina para obtener un número aleatorio de 32 bits, a partir de
@;	otro valor aleatorio almacenado en la variable global 'seed32' (declarada
@;	externamente)
@;	Restricciones:
@;		* el valor anterior de 'seed32' no puede ser 0
@;	Resultado:
@;		R0 = el nuevo valor aleatorio (también se almacena en 'seed32')
random:
	push {r1-r5, lr}
		
	ldr r0, =seed32				@;R0 = dirección de la variable 'seed32'
	ldr r1, [r0]				@;R1 = valor actual de 'seed32'
	ldr r2, =0x0019660D
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2
	add r4, r3					@;R5:R4 = nuevo valor aleatorio (64 bits)
	str r4, [r0]				@;guarda los 32 bits bajos en 'seed32'
	mov r0, r5					@;devuelve los 32 bits altos como resultado
		
	pop {r1-r5, pc}	

.end
