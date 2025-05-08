#include "boinc_api.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <fraction_done (0.0 ~ 1.0)>\n", argv[0]);
        return 1;
    }

    double fraction = atof(argv[1]);

    if (fraction < 0.0 || fraction > 1.0) {
        fprintf(stderr, "Error: fraction must be between 0.0 and 1.0\n");
        return 1;
    }

    // boinc_init();
    boinc_fraction_done(fraction); 
    // boinc_finish(0);
    return 0;
}
