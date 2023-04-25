#include <cuda_runtime.h>
#include <stdio.h>
#include <assert.h>

#define N 32
#define NUM_ITERATIONS 1000

__global__ void kernel_with_race_condition(int *A) {
  A[0] = A[threadIdx.x]; // race condition
}

int main() {
  int *A = (int*)malloc(N*sizeof(int));
  for (int i = 0; i < N; i++) {
    A[i] = i;
  }

  int *d_A;
  cudaMalloc(&d_A, N*sizeof(int));
  cudaMemcpy(d_A, A, N*sizeof(int), cudaMemcpyHostToDevice);

  for (int i = 0; i < NUM_ITERATIONS; i++) {
    kernel_with_race_condition<<<1, N>>>(d_A);
    int out;
    cudaMemcpy(&out, d_A, sizeof(int), cudaMemcpyDeviceToHost);
    assert(out >= 0 && out < N); // Select 1 of N values
  }
}