; x86-64 version
; void f:
; RDI - uint8_t *pixels_picture_under
; RSI - uint8_t *pixels_picture_above
; RDX - uint16_t width
; RCX - uint16_t height
; R8 - uint16_t x_input
; R9 - uint16_t y_input
; XMM0 - float alpha_temporary ALPHA - 32b
section .data
        ;temp resq 2
        one dd 1.0

section .text
        global  f

f:
; prolog
        push rbx
        push r12
        push r13
        push r14
        push r15
        mov   r11d, -1 ; licznik aktualnego wiersza (y) - uint16_t

; przechodze wszystkie kolumny w danym rzedzie, przechodze do kolejnego rzedu
next_row:
        inc     r11d ; y++
        cmp     r11, rcx ; y==height?
        je      fin

        mov   r10d, -1 ; licznik aktualnej kolumny (x) - uint16_t

        mov     r15, r9 ; y_input
        sub     r15, r11 ; y_input - y
        jns     next_column
        neg     r15 ; r15 - |y1-y2|

; TODO: przeniesc tutaj obliczanie r13, w next_column zwiekszac go o 3

next_column:
        inc     r10d ; x++
        cmp     r10d, edx ; x==width?
        je     next_row

        mov     r12, r8 ; x_input
        sub     r12, r10 ; x_input - x
        jns     calculate_alpha
        neg     r12 ; r12 - |x1-x2|

calculate_alpha:
;in progress

; mam aktualne x,y
; obliczam indeks w tablicy pikseli
calculate_addr_in_pixel_array:
        mov     r13w, r11w ; r13 = y
        mov     ax, r13w
        mov     r12, rdx ; zachowuje gdzies rdx, bo nadpisze sie przy mnozeniu
        mul     dx ; r13 = y*width
        ; wynik mnozenia 16b*16b jest 32b, jest w dx i ax, nizej operacje zeby zapisac te wyniki w r13
        shl     edx, 16
        mov     r13d, edx
        mov     r13w, ax
        ; restore rdx
        mov     rdx, r12

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
        mov     [r14], r12b; zapisz wynik (r14 - adres w tabeli pikseli obrazka_nad)

        jmp components_loop


fin:
        ;mov     rax, rdi      ZAKOMENTOWANE BO NIE CHCE NIC ZWRACAC?  ; return the original arg
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        ret
