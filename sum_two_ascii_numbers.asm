; Clase 4 - Unidad2.ppsx
;
; Problema Nro. 5: Ejemplo de suma de dos cifras ASCII en formato BCD
;                  con uP 8088

DATOS SEGMENT
    TABLA       DB      26  DUP (64)
                DB      36
    N           DW      25
    LINEAS      DB      23
    HH          DB       0
    VV          DB       0
DATOS ENDS

PILA SEGMENT STACK
                DW     128   DUP (?)
CAB_PILA LABEL WORD
PILA ENDS

PROG SEGMENT

ASSUME CS:PROG, DS:DATOS, SS:PILA
COMENZAR:       MOV     BX,DATOS
                MOV     DS,BX
                MOV     BX,PILA
                MOV     SS,BX
                LEA     SP,CAB_PILA

                MOV     AL,03
                INT     10h

                LEA     BX,TABLA    ; genera tabla ascii
                MOV     CX,N        ;A,B,C, ... , Z
                MOV     AL,[BX]
OTRO:           INC     AL
                MOV     [BX],AL
                INC     BX
                DEC     CX
                JNE     OTRO

NUEVO:          MOV     DH,VV
                MOV     DL,HH
                MOV     AH,02
                MOV     BH,00
                INT     10h
                MOV     AH,9
                LEA     DX,TABLA
                ADD     DL,VV
                INT     21h

                MOV     AX,30h      ; retardo 2 segundos
LAZO2:          MOV     BX,0ffffh   ; (80286 25MHZ)
LAZO:           DEC     BX
                JNE     LAZO
                DEC     AX
                JNE     LAZO2
                ADD     VV,1
                DEC     LINEAS
                JNE     NUEVO

                MOV     AH,4Ch
                INT     21h

PROG ENDS
                end     COMENZAR
