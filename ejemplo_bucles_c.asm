; Clase 2021-04-30

    ;###########;
    ;    For    ;
    ;###########;

            ; Registro CX contador.
            ; Se inicializa a cero.
            xor cx,cx

    forloop nop
            ; Aquí colocar las instrucciones a ejecutar en la iteración
            inc cx ; Incremento contador
            cmp cx, 3   ; Comparo CV con el límite
            jle forloop ; Salta a forloop mientras sea menor o igual

    ;############;
    ;  Do While  ;
    ;############;

                mov ax, 1

    dowhileloop nop
                ; Aquí colocar las instrucciones a ejecutar en la iteración
                cmp ax, 1       ; Chequea si CX=1
                je dowhileloop  ; Si igual a 1 va a dowhileloop

    ;###########;
    ;   While   ;
    ;###########;

                jmp whilecond   ; Salto a la primera condición
    whileloop   nop
    whilecond   cmp ax, 1       ; Chequea la condición
                je  whileloop   ; Saltar a whileloop si ax=1
