#include <stdio.h>
#include <allegro5/allegro.h>
#include <allegro5/allegro_primitives.h>

// arg: wskaznik na tablice pikseli 1 i 2, wymiary obrazkow, wybrany pkt odniesienia
void f(uint8_t *pixels_picture_under, uint8_t *pixels_picture_above, uint16_t width, uint16_t height, uint16_t x, uint16_t y, float alpha_temporary);

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
    //roboczo
    pixels_picture_under[(2*width+4)*3] = 40;
    for (int i = 0; i < pixel_array_len; i++) {
        int remainder = i % 3;
        if (remainder == 0)
            pixels_picture_above[i] = 255;
        else if (remainder == 1)
            pixels_picture_above[i] = 0;
        else
            pixels_picture_above[i] = 150;
    }

    ALLEGRO_DISPLAY *display = NULL;
    if (!al_init())
        return -1;
    display = al_create_display(width, height);
    al_init_primitives_addon();

    // INPUT: WYBIERZ PUNKT ODNIESIENIA
    uint16_t x_input = 2;
    uint16_t y_input = 3;
    for (int i = 0; i < pixel_array_len; i++){
        pixels_result_picture[i] = pixels_picture_above[i];
    }
    // ASSEMBLER, PRZETWARZANIE DANYCH
    float alpha_temporary = 0.75;
    f(pixels_picture_under, pixels_result_picture, width, height, x_input, y_input, alpha_temporary);
    // WYSWIETLANIE
    // Konwencja w Allegro : 00 to lewy gorny
    for (int row = 0; row < height; row++){
        for (int column = 0; column < width; column++){
            uint8_t r = (row*width + column)*3;
            uint8_t g = r + 1;
            uint8_t b = r + 2;
            al_draw_pixel(column, row, al_map_rgb(pixels_result_picture[r], pixels_result_picture[g], pixels_result_picture[b]));
        }
    }
    al_flip_display();
    al_rest(5.0);
    al_destroy_display(display);

    return 0;

// ALLEGRO_COLOR get_rgb(uint8_t *pixel_array, row, column)
//     ALLEGRO_COLOR white = al_map_rgb_f(1, 1, 1);




    // initDefaultParams(&x, &y);
    // uint8_t pPixelArray = allocPixelArray(WIDTH, HEIGHT);
    // while(true) {
    //     performAlgorithm(pPixelArray, WIDTH, HEIGHT, x, y, z);
    //     displayResult(pPixelArray, WIDTH, HEIGHT);
    //     waitForUserInput(?);
    //     modifyParamsAccordingToUserInput(&x, &y, &z, ?);
    // }

}

