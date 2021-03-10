#include <stdio.h>
#include <stdlib.h>

int main() {
  setbuf(stdout, NULL);

  long long n, i;
  printf("checkpoint1\n");
  scanf("%lld", &n);

  char *arr = malloc(sizeof(char) * n);
  for (i = 0; i < n; i++) {
    arr[i] = 'a';
  }

  free(arr);
  printf("checkpoint2");
  return 0;
}