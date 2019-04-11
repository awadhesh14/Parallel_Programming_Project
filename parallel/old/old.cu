#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <sys/time.h>
#include <functional>
#include <iostream>

#include <climits>
#include<cuda.h>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>
#include <math.h>


using namespace std;

typedef unsigned int eid_t;
typedef long var;

#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
{
   if (code != cudaSuccess)
   {
      fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
      if (abort) exit(code);
   }
}

#define GS 1024
#define BS 1024

typedef struct {
    var n; //N vertices
    var m; //M edges
    var num_of_rows; //n no of nonempty rows

    eid_t *rows;  //rows [n]
    eid_t *adj;   //cols [NNZ] = M (initially)
    eid_t *num_edges; //roff [N+1]
    eid_t *rlen;  //rlen [N]

} graph_t;

void free_graph(graph_t *g) {
    if( g->adj != NULL )
	free( g->adj );

    if( g->num_edges != NULL )
	free( g->num_edges );

    }


static double timer() {
    struct timeval tp;
    gettimeofday(&tp, NULL);
    return ((double) (tp.tv_sec) + tp.tv_usec * 1e-6);
}

/*********************** READ INPUT FILE  ************************************************************/

int load_graph_from_file(char *filename, graph_t *g) {



    FILE *infp = fopen(filename, "r");
    if (infp == NULL) {
        fprintf(stderr, "Error: could not open inputh file: %s.\n Exiting ...\n", filename);
        exit(1);
    }

    fprintf(stdout, "Reading input file: %s\n", filename);

    //double t0 = timer();

    //Read N and M
    fscanf(infp, "%ld %ld\n", &(g->n), &(g->m));
    printf("N: %ld, M: %ld \n", g->n, g->m);

    bool flag[g->n];
    var m = 0;

    //Allocate space
    g->num_edges = (eid_t *) malloc((g->n + 1) * sizeof(eid_t));
    assert(g->num_edges != NULL);

    var i ;
    for ( i=0; i<g->n + 1; i++) {
        g->num_edges[i] = 0;
    }


    for ( i=0; i<g->n; i++) {
        flag[i] = false;
    }

    eid_t u, v;
   printf(" Checking1\n ");
    while( fscanf(infp, "%u %u\n", &u, &v) != EOF ) {

        if (u>v)
          { g->num_edges[u]++; flag[u] = true; m++; }
        else if(u<v)
          { g->num_edges[v]++; flag[v] = true; m++;}
    }
   printf(" Checking2\n ");

  g->rows = (eid_t *) malloc((g->n) * sizeof(eid_t));
  g->num_of_rows = 0;

  var k =0;
  for (i = 0; i<g->n; i++)
   { if (flag[i] == true)
           { g->num_of_rows++;
             g->rows[k] = i;
             k++;
           }
   }


  g->m = m;

  /*cout<<"flag"<<endl;

     for(long i = 0; i <  g->n; i++)
     {        cout<<flag[i] <<endl;
      }
  cout<<endl;

 cout<<"g->rows"<<endl;

      for(long i = 0; i < g->num_of_rows; i++)
     {        cout<<g->rows[i] <<endl;
      }
  cout<<endl;




 /* cout<<"num edges"<<endl;

      for(long i = 0; i <  m; i++)
     {        cout<<g->num_edges[i] <<endl;
      }
  cout<<endl;
  */

    fclose( infp );

   /* if( m != g->m) {
        printf("Reading error: file does not contain %ld edges.\n", g->m);
        free( g->num_edges );
        exit(1);
    }
   */

    m = 0;

    eid_t *temp_num_edges = (eid_t *) malloc((g->n + 1) * sizeof(eid_t));
    assert(temp_num_edges != NULL);

    temp_num_edges[0] = 0;

    for(i = 0; i < g->n; i++) {
        m += g->num_edges[i];
        temp_num_edges[i+1] = m;
    }




    //Allocate space for adj
    g->adj = (eid_t *) malloc(m * sizeof(eid_t));
    assert(g->adj != NULL);


   for(i= 0; i < g->n+1; i++)
            g->num_edges[i] = temp_num_edges[i];

  /*
  cout<<"g->num edges"<<endl;

      for(long i = 0; i <  g->n+1; i++)
     {        cout<<g->num_edges[i] <<endl;
      }
  cout<<endl;
*/

   g->rlen = (eid_t *) malloc((g->n) * sizeof(eid_t));

   k =0;

   for ( i = 0; i<g->n; i++)
   { if (flag[i] == true)
           { g->rlen[k] = g->num_edges[i+1] - g->num_edges[i];
           }
     else
           g->rlen[k] = 0;
     k++;
   }





    infp = fopen(filename, "r");
    if (infp == NULL) {
        fprintf(stderr, "Error: could not open input file: %s.\n Exiting ...\n", filename);
        exit(1);
    }

    //Read N and M
    fscanf(infp, "%ld %ld\n", &(g->n), &m);

   for(i = 0; i < m; i++)
            g->adj[i] = 0;


    //Read the edges
    while( fscanf(infp, "%u %u\n", &u, &v) != EOF ) {
        if ( u > v )

           { g->adj[ temp_num_edges[u]  ] = v;
             temp_num_edges[u]++;

           }

        else if (u<v)
           {
            g->adj[ temp_num_edges[v] ] = u;
            temp_num_edges[v]++;

           }


    }


  fclose( infp );
/*
  cout<<" g->adj"<<endl;
     for(long i = 0; i <  m; i++)
     {        cout<<g->adj[i] <<endl;
      }


   cout<<" g->rlen"<<endl;
     for(long i = 0; i <  g->n; i++)
     {        cout<<g->rlen[i] <<endl;
      }

*/



    //free( temp_num_edges );
    return 0;
}





//***************************************************** CUDA KERNEL *****************************************************************

__global__ void support_compute(eid_t* roff, eid_t* rows, eid_t *cols,  int* bitmap, eid_t* rlen, var M, var N, var m, int* supp, int k, bool* weak, bool* weak_vertices)

{
   //printf ("Inside Kernel \n");
   __shared__ int value[BS];

    int tid = threadIdx.x;

    eid_t io_s, io_e, io, jo_s, jo_e, jo, i;
    int c;

for(var s = blockIdx.x; s<M; s += gridDim.x)
 {

        i = rows[s];
	io_s = roff[i];
        io_e = io_s + rlen[i];

	for(io = io_s; io<io_e; io +=blockDim.x)
 	{
           value[tid] = -1;
           c= -1;
	   c = ((io+threadIdx.x)<io_e) ? (cols[io+threadIdx.x]): -1;

           if (c>-1)
	      { atomicOr((bitmap+(N*blockIdx.x)+c), 1);
                value[tid] = c;
              }

           __syncthreads();


            for(int t=0; t<blockDim.x; t++)
	     {

                 int j = value[t];
                 if(j == -1)
                    break;


                 var cnt = 0;
	         jo_s = roff[j];
		 jo_e = jo_s + rlen[j];


  		 for(jo = jo_s + threadIdx.x; jo < jo_e; jo += blockDim.x)
		 {
			       eid_t k = cols[jo];
			        if (*(bitmap+(blockIdx.x*N)+k) == 1)
			          { cnt++;
                                    atomicAdd(supp + jo, 1);
                                    eid_t a=0;
                                      for( a =0; a <= rlen[i]; a++)
                                       {  if (cols[io_s + a] == k)
                                              break;

                                       }


                                    atomicAdd(supp+io_s+a, 1);

                                  }

	         }


                 atomicAdd(supp+io+t, cnt);

	    }



        }
        atomicAnd((bitmap+(N*blockIdx.x))+c, 0);



 }

 //End of support computation

  __syncthreads();

/*
if (threadIdx.x == 0 && blockIdx.x == 0)
 { printf("Support\n");

 for( int i = 0; i<m; i++)
        printf("%d \n", supp[i]);
 }



*/




 __shared__ int flag;

 while(true)
  { //atomicAnd(point, 0);
    //flag[threadIdx.x] = 0;

    flag = 0;
    for (int s = blockIdx.x; (s*blockDim.x + threadIdx.x)<m; s+= gridDim.x)
     {
       int i = s* blockDim.x + threadIdx.x;
 //printf("it = %d, blockId =  %d, threadId =  %d, s = %d, i = %d,  weak[i]= %d, supp[i] = %d\n", it, blockIdx.x , threadIdx.x, s, i, weak[i], supp[i]);
       if (supp[i] < k-2 && weak[i] == 0)
        {
          weak[i] = 1;
          supp[i] = -1;
          flag = 1;

        }


     }
    __syncthreads();




   if(flag == 0)
      break;

    __syncthreads();



   if(k>3)
     { for (int s = blockIdx.x; (s*blockDim.x + threadIdx.x)<m; s+= gridDim.x)
        {
            int i = s* blockDim.x + threadIdx.x;

       		if (weak[i] == 1)
        	{ int j=0;

                  long start = 0, end = N, mid;
                  while(start<end)
                 { mid = (start+end)/2;
                   j = mid;
                   if(i+1 > roff[mid] ) start = mid+1;
                   else end = mid-1;


                 }


                  weak_vertices[j] = 1;

        	}

     	}
      __syncthreads();

     for (int s = blockIdx.x; (s*blockDim.x + threadIdx.x)<N; s+= gridDim.x)
        {
            int i = s* blockDim.x + threadIdx.x;

       		if (weak_vertices[i] == 1)
        	{ int j=0;
                  for ( j = 0; j<rlen[i]; j++)
                     { int u = roff[i+j];
                       weak_vertices[cols[u]] = 1;
                       //printf("blockId =  %d, threadId =  %d, u = %d \n", blockIdx.x , threadIdx.x, cols[u]);
                     }
                 }

     	}
      __syncthreads();



     for(int s = blockIdx.x; s<M; s += gridDim.x)
 	{
        	i = rows[s];
		io_s = roff[i];
        	io_e = io_s + rlen[i];

                if(weak_vertices[i] == 1)
		{
                for(io = io_s; io<io_e; io +=blockDim.x)
 		{
           		value[tid] = -1;
           		c= -1;
	   		c = ((io+threadIdx.x)<io_e) ? (cols[io+threadIdx.x]): -1;

           		if (c>-1)
	      			{ atomicOr((bitmap+(N*blockIdx.x)+c), 1);
               			  value[tid] = c;
              			}

           		__syncthreads();

            		for(int t=0; t<blockDim.x; t++)
	     			{
                 			int j = value[t];
                 			if(j == -1)
                    				break;

                                        if (weak_vertices[j] == 1)
                 			{
                                        int cnt = 0;
	         			jo_s = roff[j];
		 			jo_e = jo_s + rlen[j];


		 			for(jo = jo_s + threadIdx.x; jo < jo_e; jo += blockDim.x)
		 			{
					       eid_t k = cols[jo];
					       if (*(bitmap+(blockIdx.x*N)+k) == 1)
					          { cnt++;


                 		                   eid_t a=0;
                 		                   for( a =0; a<=rlen[i]; a++)
                 		                      { if (cols[io_s + a] == k)
                 		                              break;
                 		                      }




                                                    if(weak_vertices[k] == 1)
                 	                                 {

                                                               if( supp[jo] == -1 || supp[io_s+a] == -1 || supp[io+t] == -1)
                                                                    { if ( supp[jo] != -1) atomicSub(supp+jo, 1);
                                                                      if ( supp[io_s+a] != -1) atomicSub(supp+io_s+a, 1);
                                                                      if ( supp[io+t] != -1) atomicSub(supp+io+t, 1);

                                                                    }
                                                                 //printf("i =  %d, j =  %d, k = %d, f = %d\n", i, j, k,f);


                                                         }//if k end
                 		                  }
	         			}


                  		       //printf("i =  %d, j =  %d, cnt = %d, i,j = %d \n", i, j, cnt, io+t);

	    		           }//if j end
				}


        	}
        	atomicAnd((bitmap+(N*blockIdx.x))+c, 0);

            }//if i end
       }//for end

      __syncthreads();

     }  //(k > 3) end

 if (k==3) break;


 } // while end




}// cuda end




int main(int argc, char *argv[]) {

    graph_t g;
    int gs=GS;
    int k = 68;

  //   if( argc < 2 )
  //   {
	// fprintf(stderr, "%s <Graph file>\n", argv[0]);
	// exit(1);
  //   }


        load_graph_from_file(/*argv[1]*/"../../test_dir.txt", &g);
        cout<<"File read complete"<<endl;


     int *b;
     b= (int *) malloc(g.m*sizeof(int));

     for(int i=0;i<g.m;i++)
         *(b + i ) = 0;


     int *bm = (int *) malloc((g.n)*gs*sizeof(int));

     for(int i=0;i<gs;i++)
     	{
		for(int j=0;j<(g.n);j++)
         	{
		  *(bm + i*g.n +j)=0;

		}
	}

	cout<<"g.num_of_rows = "<<g.num_of_rows<<endl;
   int *supp;
   eid_t *roff;
   eid_t *r;
   eid_t *col;
   eid_t* rl;
   int *bitmap;
   bool *weak, *wh;
   bool* weak_vertices;

   wh= (bool *) malloc(g.m*sizeof(bool));
     for(int i=0;i<g.m;i++)
         *(wh + i ) = false;

    cout<<" Malloc startng "<<endl;


    gpuErrchk(cudaMalloc(&roff, (g.n + 1)*sizeof(eid_t)));
    gpuErrchk(cudaMemcpy(roff, g.num_edges, (g.n + 1)*sizeof(eid_t), cudaMemcpyHostToDevice));

    gpuErrchk(cudaMalloc(&r, (g.num_of_rows)*sizeof(eid_t)));
    gpuErrchk(cudaMemcpy(r, g.rows, ( g.num_of_rows )*sizeof(eid_t), cudaMemcpyHostToDevice));

    gpuErrchk(cudaMalloc(&col, (g.m)*sizeof(eid_t)));
    gpuErrchk(cudaMemcpy(col, g.adj, (g.m)*sizeof(eid_t), cudaMemcpyHostToDevice));

    gpuErrchk(cudaMalloc(&bitmap, (g.n)*gs*sizeof(int)));
    gpuErrchk(cudaMemcpy(bitmap, bm ,(g.n)*gs*sizeof(int), cudaMemcpyHostToDevice));

    gpuErrchk(cudaMalloc(&supp, g.m*sizeof(int)));
    gpuErrchk(cudaMemcpy(supp, b, g.m*sizeof(int), cudaMemcpyHostToDevice));

    gpuErrchk(cudaMalloc(&rl, g.n*sizeof(eid_t)));
    gpuErrchk(cudaMemcpy(rl, g.rlen, g.n*sizeof(eid_t), cudaMemcpyHostToDevice));

    gpuErrchk(cudaMalloc(&weak, g.m*sizeof(bool)));
    gpuErrchk(cudaMemcpy(weak, wh, g.m*sizeof(bool), cudaMemcpyHostToDevice));


    gpuErrchk(cudaMalloc(&weak_vertices, g.n*sizeof(bool)));

        cout<<"sending into cuda"<<endl;

    	double t0 = timer();
        support_compute<<<GS,BS>>>(roff, r, col, bitmap, rl, g.num_of_rows, g.n, g.m, supp, k, weak, weak_vertices);

        gpuErrchk( cudaPeekAtLastError() );
        gpuErrchk( cudaDeviceSynchronize() );
        cout<<"Time: "<< timer() - t0<<" sec\n ";



        gpuErrchk(cudaMemcpy(b, supp, g.m*sizeof(int), cudaMemcpyDeviceToHost));
        gpuErrchk(cudaMemcpy(wh, weak, g.m*sizeof(bool), cudaMemcpyDeviceToHost));

        cout<<"Return from Cuda"<<endl;



/*
  printf("Support\n");

 for(  var i = 0; i<g.m; i++)
        printf("%d \n", b[i]);




  printf("Weak\n");

 for( int i = 0; i<g.m; i++)
        printf("%d \n", wh[i]);
*/


 return 0;
}
