#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

int main() {
  setbuf(stdout, NULL);
  printf("checkpoint1\n");
  if (open("./", O_RDONLY) == -1) {
    printf("checkpoint2\n");
    if (errno == EPERM) {
      printf("checkpoint3\n");
    } else {
      printf("fail1");
    }
  } else {
    printf("fail2");
  }
  return 0;
}