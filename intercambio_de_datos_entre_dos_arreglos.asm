; Intercambia elementos de dos arreglos
; Clase 2021-04-23

data segment
  ; Arreglos, datos de 2 bytes (1 word)
  array1      dw  1000H, 2000H, 3000H, 4000H, 5000H
  array2      dw  6000H, 7000H, 8000H, 9000H, 0000H
data ends

code segment
  ; Referencia los segmentos de dato y código
  assume ds:data, cs:code

  ; Inicialización
                ; Inicializo el segmento de datos 'ds'
  start:    mov ax, data
            mov ds, ax
            ; Carga en registro 'si' la dirección efectiva de
            ; array1
            lea si, array1
            ; Carga en registro 'di' la dirección efectiva de
            ; array2
            lea di, array2
            ; Inicializa el contador en 5
            mov cx, 05H

  ; Código para intercambiar valores
            ; Mueve el contenido de la dirección 'si' hacia el
            ; acumulador
  swap:     mov ax, [si]
            ; Mueve el contenido de la dirección 'di' hacia 'bx'
            mov bx, [di]
            ; Mueve el contenido de 'bx' hacia la posición dada
            ; por el registro 'si'
            mov [si], bx
            ; Lo mismo que lo anterior solo que con 'ax' y 'di'
            mov [di], ax

            ; Incremento 'si' para apuntar al siguiente elemento
            ; (recordar que los elementos son words, es decir,
            ; de 2 bytes, por eso incremento 2 veces)
            inc si
            inc si

            ; Ídem a 'si'
            inc di
            inc di

            ; Decrementa registro 'cx' y salta a 'swap' mientras
            ; sea distinto de cero
            loop swap

            ; Devuelve control al sistema operativo
            mov ah, 4Ch
            int 21h ; DOS Interrupt
code ends

; Fin de programa
end start
