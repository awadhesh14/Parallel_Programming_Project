#include <stdio.h>
#include <thrust/scan.h>
#include <thrust/functional.h>
#include <thrust/reduce.h>
#include <thrust/execution_policy.h>

__global__ void vector_add(int *a, int *b, int *c)
{
    /* insert code to calculate the index properly using blockIdx.x, blockDim.x, threadIdx.x */
	//int index = blockIdx.x * blockDim.x + threadIdx.x;
	//c[index] = a[index] + b[index];
//if (index >0)

	thrust::inclusive_scan(thrust::seq, c, c+20 , c);
}

/* experiment with N */
/* how large can it be? */
#define N 2048//(2048*2048)
#define THREADS_PER_BLOCK 512

int main()
{
    int *a, *b, *c;
	int *d_a, *d_b, *d_c;
	int size = N * sizeof( int );

	/* allocate space for device copies of a, b, c */

	cudaMalloc( (void **) &d_a, size );
	cudaMalloc( (void **) &d_b, size );
	cudaMalloc( (void **) &d_c, size );

	/* allocate space for host copies of a, b, c and setup input values */

	a = (int *)malloc( size );
	b = (int *)malloc( size );
	c = (int *)malloc( size );

	for( int i = 0; i < N; i++ )
	{
		a[i] = b[i] = 1;
		c[i] = 1;
	}

	/* copy inputs to device */
	/* fix the parameters needed to copy data to the device */
	cudaMemcpy( d_a, a, size, cudaMemcpyHostToDevice );
	cudaMemcpy( d_b, b, size, cudaMemcpyHostToDevice );
	printf( "c[0] = %d\n",0,c[0] );
	printf( "c[%d] = %d\n",1, c[1] );
	printf( "c[%d] = %d\n",2, c[2] );
	printf( "c[%d] = %d\n",3, c[3] );
	printf( "c[%d] = %d\n",4, c[4] );
	printf( "c[%d] = %d\n",5, c[5] );

	printf( "a[0] = %d\n",0,a[0] );
	printf( "a[%d] = %d\n",1, a[1] );
	printf( "a[%d] = %d\n",2, a[2] );
	printf( "a[%d] = %d\n",3, a[3] );
	printf( "a[%d] = %d\n",4, a[4] );
	printf( "a[%d] = %d\n",5, a[5] );

	/* launch the kernel on the GPU */
	/* insert the launch parameters to launch the kernel properly using blocks and threads */
	vector_add<<< (N + (THREADS_PER_BLOCK-1)) / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>( d_a, d_b, d_c );

	/* copy result back to host */
	/* fix the parameters needed to copy data back to the host */
	cudaMemcpy( c, d_c, size, cudaMemcpyDeviceToHost );


	printf( "c[0] = %d\n",0,c[0] );
	printf( "c[%d] = %d\n",1, c[1] );
	printf( "c[%d] = %d\n",2, c[2] );
	printf( "c[%d] = %d\n",3, c[3] );
	printf( "c[%d] = %d\n",4, c[4] );
	printf( "c[%d] = %d\n",5, c[5] );

	printf( "c[0] = %d\n",0,a[0] );
	printf( "a[%d] = %d\n",1, a[1] );
	printf( "a[%d] = %d\n",2, a[2] );
	printf( "a[%d] = %d\n",3, a[3] );
	printf( "a[%d] = %d\n",4, a[4] );
	printf( "a[%d] = %d\n",5, a[5] );

	/* clean up */

	free(a);
	free(b);
	free(c);
	cudaFree( d_a );
	cudaFree( d_b );
	cudaFree( d_c );

	return 0;
} /* end main */
