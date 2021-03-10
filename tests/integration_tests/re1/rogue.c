#include <stdio.h>

int main() {
  setbuf(stdout, NULL);
  printf("checkpoint1");
  int a = 1 / 0;
  printf("checkpoint2");
  return 0;
}