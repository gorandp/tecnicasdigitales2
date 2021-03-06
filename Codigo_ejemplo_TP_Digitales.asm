                  ; multi-segment executable file template.

data segment

    CIEN   DB 100
    DIEZ   DB 10
    WELC   DB "INGRESE HASTA 22 NUMEROS DE 3 CIFRAS$"
    WELC2  DB "PRESIONE ENTER PARA NUMEROS MENORES A 100$"
    WELC3  DB "PRESIONE ESC PARA FINALIZAR EL INGRESO$"
    DISP   DB "TABLA ORDENADA:$"
    VECT   DW 22 DUP(?)
    PUNT   DB 0
    NUM    DW 0
    ECO    DB 0
    AUX    DB 0
    CNUM   DB 0
    FIL    DB 0
    COL    DB 0
    OFFSET DW 0
    CANT   DB 0
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
    ; set segment registers:
    assume ds: data, cs: code
    mov ax, data
    mov ds, ax
    mov es, ax

    ; add your code here


    LEA BX,VECT

    MOV AX,03H  ;limpio pantalla
    INT 10H

    LEA DX,WELC ;mensajes de bienvenida
    MOV AH,09H
    INT 21H

    INC FIL
    MOV DH,FIL
    MOV DL,COL
    MOV BH,00
    MOV AH,02
    INT 10H


    LEA DX,WELC2
    MOV AH,09H
    INT 21H

    INC FIL
    MOV DH,FIL
    MOV DL,COL
    MOV BH,00
    MOV AH,02
    INT 10H

    LEA DX,WELC3
    MOV AH,09H
    INT 21H     ;ultimo mensaje bienvenida

    INC FIL

NUEVO:

    MOV CNUM,00    ;acomodo el cursor para el ingreso del numero
    MOV NUM,00
    MOV DH,FIL
    MOV DL,COL
    MOV BH,00
    MOV AH,02
    INT 10H

INGRESO:

    MOV AH,00       ;espero dato de tecla
    INT 16H

    CMP AL,13       ;me aseguro que sea un numero
    JE ENTER        ;si es enter o escape realizo un salto
    CMP AL,27
    JE ESC
    CMP AL,39H
    JG INGRESO
    CMP AL, 30H
    JL INGRESO

    INC CNUM        ;contador de cifras del numero

    MOV ECO,AL      ;muestro la variable ingresada ya que se que es un numero
    MOV DL, ECO
    MOV AH,06
    INT 21H


    MOV AX,NUM      ;al numero a guardar lo multiplico por diez y le sumo el ingresado
    MUL DIEZ
    MOV DL,ECO
    MOV DH,00
    ADD AX,DX
    SUB AX,30H
    MOV NUM,AX

    CMP CNUM,3      ;si el numero no es de 3 cifras continuo el ingreso
    JNE INGRESO



ENTER:

    CMP CNUM,00     ;si se apreto enter sin ingresar ningun numero
    JE INGRESO      ;no guardo el caracter para no malgastar memoria

    INC FIL         ;muevo el cursor para prepararme para el proximo num en pantalla
    INC PUNT        ;llevo la cuenta de la cantidad total de numeros

    MOV AX,NUM      ;almaceno el numero en el vector y muevo su puntero
    MOV [BX],AX
    ADD BX,2

    CMP PUNT,22     ;si no se ingresaron 22 numeros continuo el ingreso
    JNE NUEVO


ESC:
    ;si el usuario presiona esc detengo el ingreso
    MOV AL,PUNT     ;y registro la cantidad total de numeros
    MOV CANT,AL

    DEC PUNT        ;almaceno valores a utilizar
    MOV CNUM,0
    MOV ECO,1

ITERI:             ;ordenamiento por metodo de burbuja

    CMP ECO,1       ;si en la iteracion no se realizaron modificaciones
    JNE DISPLAY     ;el vector se ha ordenado antes de recorrerlo en su totalidad

    INC CNUM        ;incremento el contador de iteraciones
    MOV ECO,0       ;refresco la bandera de cambios realizados

    MOV AL,CANT     ;checkeo si ya realice todos los recorridos pertinentes
    CMP CNUM,AL
    JE  DISPLAY


    MOV AL,CANT     ;determino las comparaciones a realizar en esta iteracion
    MOV AUX,AL
    MOV AL,CNUM
    SUB AUX,AL      ; ( j= N-1-i = N - (i+1) )

    LEA CX,VECT

ITERJ:

    MOV BX,CX       ;comparo el un elemento del vector con el siguiente
    MOV AX,[BX]
    ADD BX,2
    CMP AX,[BX]
    JNBE NOCAM      ;si el primero es mayor, no debo realizar cambios

    MOV DX,[BX]     ;realizo el intercambio de elementos y levanto la bandera
    MOV [BX],AX     ;de cambio en la iteracion
    MOV BX,CX
    MOV [BX],DX
    MOV ECO,1

NOCAM:

    ADD CX,2        ;muevo el puntero para comparar los elementos siguientes
    DEC AUX
    CMP AUX,0

    JE ITERI        ;si ya compare todos los elementos necesarios en la iteracion,
    JMP ITERJ       ;paso a la siguiente. Si no, continuo la comparacion


DISPLAY:

    MOV COL,00      ;refresco los punteros de la pantalla
    MOV FIL,00

    MOV AX,03H      ;limpio la pantalla
    INT 10H

    LEA DX,DISP     ;mensaje de sistema
    MOV AH,09H
    INT 21H

    LEA BX,VECT

SIG:

    MOV COL,15      ;acomodo los numeros para alinearlos con el texto a gusto
    INC FIL
    MOV DH,FIL
    MOV DL,COL
    MOV BH,00
    MOV AH,02
    INT 10H

    MOV AX,0        ;limpio ax antes de realizar la asignacion
    MOV AX,[BX]     ;ya que si [bx] ocupa menos de 8bits ah sera 02 por la asignacion anterior

    CMP AX,10       ;checkeo si el elemento es menor a 10
    JNL DECENA

    ADD COL,2       ;ajusto las columnas

    MOV DH,FIL      ;refresco puntero pantalla
    MOV DL,COL
    MOV BH,00
    MOV AH,02
    INT 10H

    ADD AL,30H      ;al ser menor a 10, puedo imprimir el numero directamente
    MOV ECO,AL
    MOV DL,ECO
    MOV AH,06
    INT 21H
    JMP END

DECENA:

    CMP AX,100      ;checkeo si el numero es menor a 100
    JNL CENTENA

    INC COL         ;ajusto columna


    DIV DIEZ        ;al ser un numero entre 10 y 99 separo las decenas de las unidades
    ADD AL,30H
    MOV ECO,AL      ;y luego imprimo
    ADD AH,30H
    MOV AUX,AH

    MOV DH,FIL      ;ajusto puntero pantalla
    MOV DL,COL
    MOV BH,00
    MOV AH,02
    INT 10H

    MOV AH,06       ;realizo impresiones
    MOV DL,ECO
    INT 21H
    MOV DL,AUX
    INT 21H
    JMP END

CENTENA:

    DIV CIEN       ;como el elemento esta entre 100 y 999
    ADD AL,30H     ;debo separar centena decena y unidad
    MOV ECO,AL
    MOV AUX,AH

    MOV AH,06      ;imprimo la centena
    MOV DL,ECO
    INT 21H

    MOV AX,00      ;separo decenas y unidades
    MOV AL,AUX
    DIV DIEZ

    ADD AL,30H     ;transformacion a ascii
    MOV ECO,AL
    ADD AH,30H
    MOV AUX,AH

    MOV AH,06      ;impresion de decenas y unidades
    MOV DL,ECO
    INT 21H
    MOV DL,AUX
    INT 21H


END:

    ADD BX,2       ;muevo el puntero del vector

    DEC CANT       ;si aun no se imprimieron todos los elementos continuo
    CMP CANT,0
    JNZ SIG



    MOV AH,00       ;
    INT 16H
    mov ax, 4c00h ; exit to operating system.
    int 21h
ends

end start ; set entry point and stop the assembler.
