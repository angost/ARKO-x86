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
        mov   r10, 0 ; licznik aktualnej kolumny (x) - uint16_t
        mov   r11, 0 ; licznik aktualnego wiersza (y) - uint16_t
; mam licznik przerabianego piksela
; obliczam na jego podstawie wspolrzedna x piksela
; obliczam roznice miedzy x_input a x piksela
; wstawiam ja do wzoru na sinus = obliczam alfa
; pobieram kolejno r,g,b obrazka nad i pod, obliczam finaalna wartosc uzywajac alfa
; nadpisuje wartosci pikseli w obrazku nad
; ALBO po kolei 00,10,20,30 po linii poziomej
; ALBO po linii pionowej -> efektywniej bo kazda ma taka sama wartosc alfa
; = x=0, wszystkie y, x=1, wszystkie y, ...

current_coords:
next_column:
        mov     r12, r8
        sub     r12, r10
        jns     calculate_alpha
        neg     r12 ; r12 - |x1-x2|
calculate_alpha:
; mam aktualne x,y
; obliczam indeks w tablicy pikseli
calculate_addr_in_pixel_array:
        mov     r13, r11 ; r13 = y
        mov     rax, r13
        mul     rdx ; r13 = y*width
        mov     r13, rax
        add     r13, r10 ; r13 = y*width + x
        lea     r13, [r13 + r13*2] ;  r13 = (y*width + x)*3

        mov     bl, 0 ; iteracja petli zmieniania skladowych r,g,b

;TODO zmienic kolejnosc zeby w r14 miec adres tablicy obrazka nad
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

        cvttss2si ebx, xmm1 ; conversion to int
        mov     [r14], bl; r14 - adres w tabeli pikseli obrazka_nad


fin:
        ;mov     rax, rdi      ZAKOMENTOWANE BO NIE CHCE NIC ZWRACAC?  ; return the original arg
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        ret
