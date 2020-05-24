#include <inttypes.h>
#include <stdlib.h>

uint64_t read();
void write(uint64_t val);

int main() {
  long long a[50];
  long long *m1 = (long long*)malloc(sizeof(long long)*50);

  for(long long i=0; i<50; i++) {
    a[i]=i;
    m1[i]=49-i;
  }

  long long sum=0; 
  for(long long i=0; i<50; i++) {
    sum+=a[i];
    sum+=m1[i];
    sum+=a[49-i];
    sum+=m1[49-i];
  }

  write(sum);
  return 0;
}
