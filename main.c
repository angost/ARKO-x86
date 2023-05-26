#include <stdio.h>
#include <allegro5/allegro.h>
#include <allegro5/allegro_primitives.h>

// arg: wskaznik na tablice pikseli 1 i 2, wymiary obrazkow
void *f(char *s);


int main(int argc, char *argv[])
{
    int width = 640;
    int height = 480;
    int nr_of_pixels = width * height * 3;
    // Tablice pikseli obu obrazkow, ustawianie ich poczatkowych wartosci
    // Konwencja: R,G,B; kolejnosc od lewej do prawej, od gory do dolu
    uint8_t pixels_picture_under[nr_of_pixels];
    uint8_t pixels_picture_above[nr_of_pixels];
    for (int i = 0; i < nr_of_pixels; i++) {
        int remainder = i % 3;
        if (remainder == 0)
            pixels_picture_above[i] = 255;
        else if (remainder == 1)
            pixels_picture_above[i] = 0;
        else
            pixels_picture_above[i] = 150;
    }

    // input: wybierz punkt odniesienia
    int x, y;

    ALLEGRO_DISPLAY *display = NULL;
    if (!al_init())
        return -1;
    display = al_create_display(width, height);
    al_init_primitives_addon();

    for (int row = 0; row < height; row++){
        for (int column = 0; column < width; column++){
            int r = (row*width + column)*3;
            int g = r + 1;
            int b = r + 2;
            al_draw_pixel(column, row, al_map_rgb(pixels_picture_above[r], pixels_picture_above[g], pixels_picture_above[b]));
        }
    }
    //al_draw_pixel(10, 20, al_map_rgb(255, 255, 255));

    al_flip_display();
    al_rest(5.0);

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

