#include <stdio.h>
#include <allegro5/allegro.h>
#include <allegro5/allegro_primitives.h>

// arg: wskaznik na tablice pikseli 1 i 2, wymiary obrazkow, wybrany pkt odniesienia
void f(uint8_t *pixels_picture_under, uint8_t *pixels_picture_above, uint16_t width, uint16_t height, uint16_t x, uint16_t y);


void setup_picture_above(uint32_t pixel_array_len, uint8_t *pixels_picture_above){
    for (int i = 0; i < pixel_array_len/2; i++) {
        int remainder = i % 3;
        if (remainder == 0)
            pixels_picture_above[i] = 255;
        else if (remainder == 1)
            pixels_picture_above[i] = 0;
        else
            pixels_picture_above[i] = 150;
    }

    for (int i = pixel_array_len/2; i < pixel_array_len; i++) {
        int remainder = i % 3;
        if (remainder == 0)
            pixels_picture_above[i] = 252;
        else if (remainder == 1)
            pixels_picture_above[i] = 168;
        else
            pixels_picture_above[i] = 3;
    }
}

void get_input(uint16_t *input_coords, uint16_t width, uint16_t height){
    int x_input = -2;
    int y_input = -2;

    while (x_input < -1 || x_input >= width ){
        printf("Enter x between <0, %d>: ", width-1);
        scanf("%d", &x_input);
    }
    while (y_input < -1 || y_input >= height ){
        printf("Enter y between <0, %d>: ", height-1);
        scanf("%d", &y_input);
    }

    if (x_input == -1 || y_input == -1){
        input_coords[0] = -1;
        input_coords[1] = -1;
    } else {
        uint16_t x = x_input & 0xffff;
        uint16_t y = y_input & 0xffff;

        input_coords[0] = x;
        input_coords[1] = y;
    }
}

int main(int argc, char *argv[])
{
    // SETUP
    uint16_t width = 640;
    uint16_t height = 480;
    uint32_t pixel_array_len = width * height * 3;
    // Tablice pikseli obu obrazkow, ustawianie ich poczatkowych wartosci
    // Konwencja: R,G,B; kolejnosc od lewej do prawej, od gory do dolu
    uint8_t pixels_picture_under[pixel_array_len];
    uint8_t pixels_picture_above[pixel_array_len];
    uint8_t pixels_result_picture[pixel_array_len];

    setup_picture_above(pixel_array_len, pixels_picture_above);

    ALLEGRO_DISPLAY *display = NULL;
    if (!al_init())
        return -1;
    display = al_create_display(width, height);
    al_init_primitives_addon();

    uint16_t input_coords[2];
    input_coords[0] = -2; input_coords[1] = -2;

    // skopiuj poczatkowy obrazek
    for (int i = 0; i < pixel_array_len; i++){
        pixels_result_picture[i] = pixels_picture_above[i];
    }

    while (input_coords[0] != -1 && input_coords[1] != -1) {
        // WYSWIETLANIE
        // Konwencja w Allegro : 00 to lewy gorny
        for (int row = 0; row < height; row++){
            for (int column = 0; column < width; column++){
                uint32_t r_index = (row*width + column)*3;
                uint32_t g_index = r_index + 1;
                uint32_t b_index = r_index + 2;
                al_draw_pixel(column, row, al_map_rgb(pixels_result_picture[r_index], pixels_result_picture[g_index], pixels_result_picture[b_index]));
            }
        }
        al_flip_display();
        al_rest(5.0);

        // INPUT: WYBIERZ PUNKT ODNIESIENIA
        get_input(input_coords, width, height);
        printf("x: %d, y: %d\n", input_coords[0], input_coords[1]);

        // skopiuj poczatkowy obrazek
        for (int i = 0; i < pixel_array_len; i++){
            pixels_result_picture[i] = pixels_picture_above[i];
        }
        // ASSEMBLER, PRZETWORZ
        f(pixels_picture_under, pixels_result_picture, width, height, input_coords[0], input_coords[1]);
    }

    al_destroy_display(display);
    return 0;
}