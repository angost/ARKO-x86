
rdi wskaznik obrazek_pod
rsi wskaznik obrazek_nad
rdx width
rcx height
r8 x_input
r9_y_input
r10 x
r11 y

next_column:
r12 roznica x

calculate_addr_in_pixel_array
rax roboczy
r13 offset
bl iteracja skladowej

get_previous_color_components:
r14 aktualny adres w obrazku_nad
al,ah aktualne kolory

calculate_new_color_component
r12  roboczy

WOLNY - r15