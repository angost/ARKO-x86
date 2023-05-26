#include <stdio.h>
#include <allegro5/allegro.h>
#include <allegro5/allegro_primitives.h>

// arg: wskaznik na tablice pikseli 1 i 2, wymiary obrazkow
void *f(char *s);

int main(int argc, char *argv[])
{
    int width = 640;
    int height = 480;
    // input: wybierz punkt
    int x, y;
    // TODO: stworzyc display allegro, narysowac punkt, stworzyc wlasnorecznie (?) 2wymiarowa tablice pikseli [[0,0,0], [20,100,255], itd.] z podanymi tylko wymiarami height i width(?)
    ALLEGRO_DISPLAY *display = NULL;
    if (!al_init())
        return -1;

    display = al_create_display(width, height);
    al_init_primitives_addon();

    al_flip_display();
    al_rest(5.0);

    return 0;





    // initDefaultParams(&x, &y);
    // uint8_t pPixelArray = allocPixelArray(WIDTH, HEIGHT);
    // while(true) {
    //     performAlgorithm(pPixelArray, WIDTH, HEIGHT, x, y, z);
    //     displayResult(pPixelArray, WIDTH, HEIGHT);
    //     waitForUserInput(?);
    //     modifyParamsAccordingToUserInput(&x, &y, &z, ?);
    // }

}

