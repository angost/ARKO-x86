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
        push r13
        push r14
        push r15
        mov   r11w, -1 ; licznik aktualnego wiersza (y) - uint16_t

; przechodze wszystkie kolumny w danym rzedzie, przechodze do kolejnego rzedu
next_row:
        inc     r11w ; y++
        cmp     r11w, cx ; y==height?
        je      fin

        mov   r10w, -1 ; licznik aktualnej kolumny (x) - uint16_t

        mov     r15w, r9w ; y_input
        sub     r15w, r11w ; y_input - y
        jns     square_difference_y
        neg     r15w ; r15: |y1-y2|

square_difference_y:
        ; (y1-y2)^2
        mov     r12w, dx
        mov    ax, r15w
        mul     r15w
        shl     edx, 16
        mov     r15d, edx
        mov     r15w, ax
        mov     dx, r12w

; TODO: przeniesc tutaj obliczanie r13, w next_column zwiekszac go o 3

next_column:
        inc     r10w ; x++
        cmp     r10w, dx ; x==width?
        je     next_row

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
        add     r12w, r15w ; [(x1-x2)^2 + (y1-y2)^2]
        cvtsi2ss xmm0, r12d
        sqrtss  xmm0, xmm0 ; xmm0 - sqrt([(x1-x2)^2 + (y1-y2)^2])
sqrt:
        ; skalowanie dystansu, zeby mala zmiana odleglosci nie maial az takiego wplywu na zmiane sinusa
        movd    xmm3, [scale]
        divss   xmm0, xmm3
divided:
        ; CALCULATE ALPHA (przeksztalcony sinus)
        fldpi   ; pi
td1:
        fdiv    dword [two] ;pi/2
td2:
        movd    [sin_arg], xmm0
td3:
        fadd    dword [sin_arg] ; pi/2 + distance
pi_plus_distance:
        fsin    ; sin(pi/2 + distance)
sinused:
        fadd    dword [one] ; sin(pi/2 + distance) + 1
        fdiv    dword [two] ; [sin(pi/2 + distance) + 1]/2
halfed:
        fstp     dword [alpha_calculated]
        movd    xmm0, [alpha_calculated]
finished:
; mam aktualne x,y
; obliczam indeks w tablicy pikseli

; PROBLEM - JEST ZE STOSEM, MUSZE POPOWAC RZECZY ZE STOSU JAK SKONCZE
calculate_offset_in_pixel_array:
        mov     r13w, r11w ; r13 = y
        mov     ax, r13w
        mov     r12w, dx ; zachowuje gdzies rdx, bo nadpisze sie przy mnozeniu
        mul     dx ; r13 = y*width
        ; wynik mnozenia 16b*16b jest 32b, jest w dx i ax, nizej operacje zeby zapisac te wyniki w r13
        shl     edx, 16
        mov     r13d, edx
        mov     r13w, ax
        ; restore rdx
        mov     dx, r12w

        add     r13d, r10d ; r13 = y*width + x
        lea     r13d, [r13d + r13d*2] ;  r13 = (y*width + x)*3

        mov     bl, -1 ; iteracja petli zmieniania skladowych r,g,b

components_loop:
        inc     bl
        cmp     bl, 3
        je      next_column

get_previous_color_components: ; loop dla kolejno r,g,b
        ;adres skladowej = pierwszy el + offset + nr_skladowej
        ; dla obrazka_pod
        movzx   r14, bl
        add     r14, r13
        add     r14, rdi ; rdi - pierwszy el w tablicy
        mov     al, [r14]
        mov     ah, 0
        mov     ah, al

        ; dla obrazka_nad
        movzx   r14, bl
        add     r14, r13
        add     r14, rsi ; rsi - pierwszy el w tablicy

        mov     al, [r14]
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
        ;--dzialalo tez cos takiego---
                ;fld1 ; wrzucenie 1.0 na stos
                ;movdqa [temp], xmm0
        ;-----------------------------
from_picture_under:
        mulss   xmm2, xmm1 ; xmm2 = (1-alfa)*R/G/B

        ; picture above
        ; pobranie skladowej
        mov     al, ah
        movzx   r12d, al ; conversion of color component to float
        cvtsi2ss xmm1, r12d ; trzymam skladowa obrazka_pod we floacie w xmm2
        ; obliczenie nowej skladowej part2
from_picture_above:
        mulss   xmm1, xmm0 ; xmm2 = alfa*R/G/B

        ;xmm1 -  czesc nowej skladowej z gornego obrazka
        ;xmm2 -  czesc nowej skladowej z dolnego obrazka
        addss   xmm1, xmm2 ; alfa*R/G/B + (1-alfa)*R/G/B

        cvttss2si r12d, xmm1 ; conversion to int
        mov     [r14], r12b; zapisz wynik (r14 - adres w tabeli pikseli obrazka_nad)
color:

        jmp components_loop


fin:
        ;mov     rax, rdi      ZAKOMENTOWANE BO NIE CHCE NIC ZWRACAC?  ; return the original arg
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        ret
