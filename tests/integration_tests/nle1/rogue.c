#include <stdio.h>
#include <unistd.h>
#include <wait.h>
#include <sys/types.h>

int main() {
  setbuf(stdout, NULL);
  printf("checkpoint1\n");

  pid_t pid = fork();
  if (pid == -1) {
    printf("fail");
    return 0;
  } else if (pid == 0) {
    printf("checkpoint2");
  } else {
    wait(NULL);
    printf("checkpoint3\n");

    pid_t pid = fork();
    if (pid == -1) {
      printf("checkpoint4");
      // so that this process doesn't exit before it is terminated by the
      // sandbox
      sleep(1);
    } else if (pid == 0) {
      printf("child");
    } else {
      printf("parent");
    }
  }
  return 0;
}