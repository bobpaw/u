#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ABS(x) x < 0 ? -(x) : x

int main (int argc, char * argv[]) {
  double z = 1.0;
  double x = 0;
  int imaginary = 0;
  for (int i = 1; i < argc; imaginary = 0, i++) {
    x = atof(argv[i]);
    if ((int) x == 0) {
      printf("Sqrt of 0 is 0\n");
      continue;
    } else if ((int) x == -1) {
      printf("Sqrt of -1 is i\n");
      continue;
    }
    if ((int) x < 0) {
      imaginary = 1;
      x = -1*x;
    }
    while (ABS((z*z-x)/(2*z)) > 0.0000001) {
      z -= (z*z-x)/(2*z);
    }
    printf("Sqrt of %.*g is approximately %.6f%c\n", x, strlen(argv[i]), z, imaginary ? 'i' : '\0');
  }
  return 0;
}
