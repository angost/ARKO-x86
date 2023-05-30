; x86-64 version
; void f:
; RDI - uint8_t *pixels_picture_under
; RSI - uint8_t *pixels_picture_above
; RDX - uint16_t width -> dx
; RCX - uint16_t height -> cx
; R8 - uint16_t x_input -> r8w
; R9 - uint16_t y_input -> r9w
section .data
        one dd 1.0
        two dd 2.0
        scale dd 20.0

section .bss
        sin_arg resd 1 ; 4B * 1
        alpha_calculated   resd 1 ; 4B * 1

section .text
        global  f

f:
; prolog
        push rbx
        push r12
        push r14
        push r15
        mov   r11w, -1 ; licznik aktualnego wiersza (y) - uint16_t

; przechodze wszystkie kolumny w danym rzedzie, przechodze do kolejnego rzedu
next_row:
        inc     r11w ; y++
        cmp     r11w, cx ; y==height?
        je      fin

        mov     r10w, -1 ; licznik aktualnej kolumny (x) - uint16_t

        mov     r15w, r9w ; y_input
        sub     r15w, r11w ; y_input - y
        jns     square_difference_y
        neg     r15w ; r15: |y1-y2|

square_difference_y:
        ; (y1-y2)^2
        mov     r12w, dx
        mov     ax, r15w
        mul     r15w
        shl     edx, 16
        mov     r15d, edx
        mov     r15w, ax
        mov     dx, r12w

next_column:
        inc     r10w ; x++
        cmp     r10w, dx ; x==width?
        je      next_row

        mov     r12w, r8w ; x_input
        sub     r12w, r10w ; x_input - x
        jns     square_difference_x
        neg     r12w ; r12: |x1-x2|

square_difference_x:
        ; (x1-x2)^2
        mov     r14w, dx
        mov     ax, r12w
        mul     r12w
        shl     edx, 16
        mov     r12d, edx
        mov     r12w, ax
        mov     dx, r14w

calculate_alpha:
        ; CALCULATE DISTANCE
        add     r12d, r15d ; [(x1-x2)^2 + (y1-y2)^2]
        cvtsi2ss xmm0, r12d
        sqrtss  xmm0, xmm0 ; xmm0 - sqrt([(x1-x2)^2 + (y1-y2)^2])

        ; skalowanie dystansu, zeby mala zmiana odleglosci nie mial az takiego wplywu na zmiane sinusa
        movd    xmm3, [scale]
        divss   xmm0, xmm3
        ; CALCULATE ALPHA (przeksztalcony sinus)
        fldpi   ; pi
        fdiv    dword [two] ;pi/2
        movd    [sin_arg], xmm0
        fadd    dword [sin_arg] ; pi/2 + distance
        fsin    ; sin(pi/2 + distance)
        fadd    dword [one] ; sin(pi/2 + distance) + 1
        fdiv    dword [two] ; [sin(pi/2 + distance) + 1]/2
        fstp     dword [alpha_calculated]
        movd    xmm0, [alpha_calculated]

loop_setup:
        mov     bl, -1 ; iteracja petli zmieniania skladowych r,g,b

components_loop:
        inc     bl
        cmp     bl, 3
        je      next_column

        ; Updating pointers to current elements
        inc     rdi ; pixels_picture_under
        inc     rsi ; pixels_picture_above

get_previous_color_components: ; loop dla kolejno r,g,b
        ; dla obrazka_pod
        mov     al, [rdi]
        mov     ah, 0
        mov     ah, al

        ; dla obrazka_nad
        mov     al, [rsi]
        xchg    al, ah

        ; ah - obrazek_nad, al - obrazek_pod

calculate_new_color_component:
        ; picture_under
        ; pobranie skladowej
        movzx   r12d, al ; conversion of color component to float
        cvtsi2ss xmm2, r12d ; trzymam skladowa obrazka_pod we floacie w xmm2
        ; obliczenie nowej skladowej part1
        movss   xmm1, dword [one]
        subss   xmm1, xmm0 ; 1 - alfa
        mulss   xmm2, xmm1 ; xmm2 = (1-alfa)*R/G/B

        ; picture above
        ; pobranie skladowej
        mov     al, ah
        movzx   r12d, al ; conversion of color component to float
        cvtsi2ss xmm1, r12d ; trzymam skladowa obrazka_pod we floacie w xmm2
        ; obliczenie nowej skladowej part2
        mulss   xmm1, xmm0 ; xmm2 = alfa*R/G/B

        ;xmm1 -  czesc nowej skladowej z gornego obrazka
        ;xmm2 -  czesc nowej skladowej z dolnego obrazka
        addss   xmm1, xmm2 ; alfa*R/G/B + (1-alfa)*R/G/B

        cvttss2si r12d, xmm1 ; conversion to int
        cmp     r12w, 255
        jle      save_color
        mov     r12b, 255

save_color:
        mov     [rsi], r12b; zapisz wynik (rsi - adres w tabeli pikseli obrazka_nad)
        jmp components_loop

fin:
        pop r15
        pop r14
        pop r12
        pop rbx
        ret
