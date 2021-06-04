; Alumno: Yakowitz, Santiago. 2021

datos segment
	diez db 10
	cien db 100
	resto db 0
	array dw 10 dup(?) ; Array de maximo 10 numeros
	c dw 0
	msg db "Ingrese al menos 2 numeros (0-999), ENTER para ingresar y ESC para terminar:$"
	num_count db 0  ; Cantidad de numeros ingresados en tabla
	num dw 0
	num_hex db 0    ; Numero ingresado en hex (ascii) para mostrarlo en pantalla (30h - 39h)
	db 36
	cont db 0       ; Cuenta los digitos del numero actual
	pos db 1        ; Fila en la pantalla
datos ends

pila segment stack
	dw 128 dup (?)
	cab_pila label word
pila ends

prog segment stack
assume cs: prog, ds: datos, ss: pila

start:
	mov bx, datos
	mov ds, bx
	mov bx, pila
	mov ss, bx
	lea sp, cab_pila

	lea bx, array          ; Cargo la direc efec del array en bx
    
    lea dx, msg          ; Muestro el titulo
    call print_str       
    
    ; --- Ingreso de los numeros ---
	new_num:
		mov cont, 00       ; Inicio variables
		mov num, 00
		mov dh, pos        ; fila
		mov dl, 0          ; columna
		mov ah, 02
		mov bh, 00         ; muevo el cursor
		int 10h

	key_input:
		call input_key     ; La tecla se registra en al
		cmp al, 13         ; al == 13: Enter
		je enter
		cmp al, 27         ; al == 27: Esc
		je esc
		
		; 0 - 9 = 30h - 39h
		cmp al, 30h        ; al < 30h: volver a pedir tecla
		jl key_input
		cmp al, 39h
		jg key_input       ; al > 39h: volver a pedir tecla

		inc cont           ; Sumamos un nuevo digito

		mov num_hex, al    ; Muevo el valor leido en al a num_hex
		lea dx, num_hex    ; y cargo la direc efectiva en dx para mostrarlo en pantalla
		call print_str

		mov ax, num
		mul diez           ; Multiplico por diez para agregar la unidad, decena o centena
		mov dl, num_hex    ; Ingreso el numero en dx (dh: 00, dl: 30 - 39)
		mov dh, 00
		add ax, dx         ; Sumo este numero con ax
		sub al, 30h        ; Le resto 30h para obtener el numero real
		mov num, ax        ; Lo guardo en num
		cmp cont, 03       ; Tomamos como que se ingreso enter si se ingresan 3 digitos
		je enter
		jmp key_input      ; Sino, volver a pedir otro digito

	enter:
		cmp cont, 00       ; Si no se ingreso ningun numero, volver a pedir
		je key_input
		inc pos            ; Sumamos fila del cursor
		inc num_count      ; Sumamos numeros ingresados
		mov ax, num        ; Lo ingresamos en el array
		mov [bx], ax
		add bx, 2          ; Pasamos al siguiente elemento en el array
		cmp num_count, 10  ; Verificar si se llego al limite
		jne new_num
           
	esc:
		cmp pos, 02        ; Si numeros ingresados <= 1: volver a pedir
		jbe key_input
	
	; --- Ordenamiento del array ---
	; Ver explicacion del funcionamiento al final del programa
    mov ah, 00
    mov al, num_count ; ax contiene la cantidad de numeros ingresados
    mov bl, 02
    mul bl            ; ax tiene ahora num_count * 2
    dec al            ; Resto 1 ya que los numeros van de 0 a (num_count * 2) - 1
    mov bx, ax        ; bx es ahora (num_count * 2) - 1
    mov cx, ax
    dec cl
    dec cl      ; cx es 2 veces anterior a bx
    mov c, cx
    loop1:
        mov cx, c
        loop2:
            mov si, cx
            mov ax, array[si-1]
            cmp ax, array[bx-1]
            jge next ; Si array[cx] >= array[bx] no hacer nada, sino:
            mov ax, array[bx-1] ; Los intercambio de lugar
            mov dx, array[si-1] 
            mov array[bx-1], dx 
            mov array[si-1], ax
            next:
            dec cx
            dec cx
            cmp cx, 01 ; El segundo bucle termina cuando cx llegue a -1 (FFFF)
            jge loop2
        dec bx ; Decremento bx y c para pasar al elemento anterior del array
        dec bx
        dec c
        dec c
        cmp bx, 01 ; El primer bucle termina cuando bx == 1
        jg loop1
	
	; --- Mostrar el array ---
	lea bx, array
	mov pos, 01            ; Empezamos en la fila 1

	print:
	    mov dh, pos        ; Fila
	    mov dl, 25         ; Columna
	    mov ah, 02         ; Muevo cursor
	    mov bh, 00
	    int 10h
	    
	    mov ax, [bx]       ; Cargo el numero del array en ax
	    
	    cmp ax, 100        ; Hago el salto correspondiente si es mayor o igual a 100
	    jae centena        
	    cmp ax, 10         ; o mayor o igual a 10
	    jae decena
	    jmp unidad 

	    centena:
	        div cien       ; entero: al, resto: ah
	        mov resto, ah  ; Guardo el resto para usarlo en la decena
	        add al, 30h    ; Lo paso a su correspondiente ascii
	        mov dl, al     ; Lo cargo a dl y lo muestro
	        call print_char
	    
	    mov ah, 00         ; Reseteo las variables y prosigo de la misma forma
	    mov al, resto
	    
	    decena:
	        div diez
	        mov resto, ah
	        add al, 30h
	        mov dl, al
	        call print_char
	    
	    mov ah, 00
	    mov al, resto
	    
	    unidad:
	        add al, 30h
	        mov dl, al
	        call print_char
	                        
	    add bx, 02          ; Paso al siguiente numero en el array
	    inc pos             ; Paso a la siguiente fila
	    dec num_count       ; Decremento la cantidad de numeros
	    cmp num_count, 00   ; Compruebo si se mostraron todos los numeros
	    je exit
	    jmp print
	prog ends

    ; --- Funciones utiles ---
    
    ; Ingreso de numero por teclado
    input_key:
        mov ah, 00
	    int 16h    
        ret
    
    ; Mostrar una cadena de caracteres
    print_str:
        mov ah, 09h
        int 21h
        ret
    
    ; Mostrar un caracter
    print_char:
        mov ah, 06
        int 21h
        ret
    
    ; Limpiar la pantalla
    clear_screen:
        mov ax, 03
        int 10h
        ret
    
    ; Terminar el programa
    exit:
        mov ah, 4ch
        int 21h
        ret
    
end start

; bx va desde el ultimo elemento del array hasta el primero sin incluir,
; cx va desde el anterior de bx hasta el primero incluyendo.
; Si array[cx] < array[bx]: los intercambio de lugar, de esta forma los
; numeros mayores van quedando primeros y los menores quedan ultimos.
; Ejemplo: si los numeros ingresados son 12, 123, 1, 10:
; esto seria: 000C, 007B, 0001, 000A
; bx empieza de la posicion 7 (000A, largo del array - 1) y cx de la posicion 5 (0001)
; 0001 < 000A, por lo tanto los intercambio. Los demas quedan igual:
; 000C, 007B, 000A, 0001
; Despues bx empieza en 000A y cx empieza en 007B, aca no se cambia nada.
; Finalmente, cuando bx esta en 007B y cx en 000C, los intercambio
; 007B, 000C, 000A, 0001 -> 123, 12, 10, 1, y asi queda el array ordenado.
