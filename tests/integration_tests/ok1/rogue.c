#include <stdio.h>

int main() {
  printf("checkpoint1");
  int n;
  scanf("%d", &n);
  int ans = 0, i;
  for (i = 0; i < n; i++) {
    int temp;
    scanf("%d", &temp);
    ans += temp;
  }
  printf("%d\n", ans);
  printf("checkpoint2\n");
  return 0;
}