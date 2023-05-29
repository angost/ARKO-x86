; x86-64 version
; void f:
; RDI - uint8_t *pixels_picture_under
; RSI - uint8_t *pixels_picture_above
; RDX - int width
; RCX - int height
; R8 - int x_input
; R9 - int y_input

        section .text
        global  f

f:
; prolog
        push rbx
        push r12
        push r13
        push r14
        push r15
        mov     r10, 0 ; licznik aktualnej kolumny (x)
        mov     r11, 0 ; licznik aktualnego wiersza (y)
; mam licznik przerabianego piksela
; obliczam na jego podstawie wspolrzedna x piksela
; obliczam roznice miedzy x_input a x piksela
; wstawiam ja do wzoru na sinus = obliczam alfa
; pobieram kolejno r,g,b obrazka nad i pod, obliczam finaalna wartosc uzywajac alfa
; nadpisuje wartosci pikseli w obrazku nad
; ALBO po kolei 00,10,20,30 po linii poziomej
; ALBO po linii pionowej -> efektywniej bo kazda ma taka sama wartosc alfa
        ; = x=0, wszystkie y, x=1, wszystkie y, ...
next_column:
        lea     r12, [r8 - r10] ; roznica x1-x2
        jns     calculate_alpha
        neg     r12 ; |x1-x2|

calculate_alpha:
        move    xmm0, 0.3 ; roboczo

; mam aktualne x,y
; obliczam indeks w tablicy pikseli
calculate_addr_in_pixel_array:
        ; cel: r13 = (y*height + x)*3
        mov     r13, r11 ; r13 = y
        mul     r13, rcx ; r13 = y*height
        add     r13, r10 ; r13 = y*height + x
        lea     r13, [r13 + r13*2] ;  r13 = (y*height + x)*3

        mov     bl, 0 ; iteracja petli zmieniania skladowych r,g,b

calculate_new_color_value: ; loop dla kolejno r,g,b
; pobieram skladowa z obrazka_nad i obrazka_pod
        mov     r14, rdi ; pierwszy el w tablicy obrazka_pod
        lea     r14, [r14 + r12 + bl] ; adres skladowej = pierwszy el + offset
        mov     al, [r14]

        mov     r14, rsi ; pierwszy el w tablicy obrazka_nad
        lea     r14, [r14 + r12 + bl]; adres skladowej = pierwszy el + offset
        mov     ah, [r14]

        ; picture_under
        movzx   ebx, al ; conversion of color to float
        cvtsi2ss ebx, xmm2
        movss   xmm1, dword 0x3F800000 ; xmm1 = 1.0
        subss   xmm1, xmm0 ; xmm1 = 1-alfa
        mulss   xmm2, xmm1 ; xmm2 = (1-alfa)*R/G/B

        ; picture above
        movzx   ebx, ah ; conversion to float
        cvtsi2ss ebx, xmm1
        mulss   xmm0, xmm1 ; xmm1 = alfa*R/G/B

        addss   xmm2, xmm1 ; (1-alfa)*R/G/B + alfa*R/G/B

        cvtss2si ebx, xmm1 ; conversion to int
        and     ebx, 0xFF
        ; tak to mniej wicej powinno dzialac

fin:
        ;mov     rax, rdi      ZAKOMENTOWANE BO NIE CHCE NIC ZWRACAC?  ; return the original arg
        pop r15
        pop r14
        pop r13
        pop r12
        pop ebx
        ret
