#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <sys/time.h>
#include <functional>
#include <iostream>
#include <bits/stdc++.h>

#include <climits>
#include<cuda.h>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>
#include <math.h>

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/sequence.h>
#include <thrust/sort.h>
#include <thrust/functional.h>



using namespace std;

__global__ void line89 (int *d_dstp, int *d_srcp, int n){
  int index = threadIdx.x + blockDim.x*blockIdx.x;
  if(index >=0 && index < n)
    d_dstp [ d_srcp[index] ] =index;

}

int main()
{
    ifstream fin;
    ofstream fout;
    string infile, outfile;

    cout<<"inside readGraph"<<endl;
  // infile ="../../../input/"      + name + ".mmio" ; //  ../../../input/amazon0302_adj.mmio
  // outfile="../../output/serial/" + name + ".txt"  ; //  dataset+"-out.txt";
  infile ="ip.txt";

  fin.open(infile.c_str());    // opening the input file
  fout.open(outfile.c_str());  // opening the output file

  string temp;
  getline(fin,temp); // readint the description line 1
  getline(fin,temp); // reading the description line 2

  //int temp_e;          // temperory edge because edge weight is useless
  int u1,v1,n,m;             // the v1,v2 of edges

  fin >> n >> n >> m ;       // reading the MxN graph and edges
  cout<< n<<" "<< m<<endl;

  //int hist[n], srcp[n], dstp[n];

  thrust::device_vector<int> hist(n);
  thrust::device_vector<int> srcp(n);
  thrust::device_vector<int> dstp(n);

  int i;

  thrust::fill(hist.begin(), hist.begin() + n, 0);

  for(i=0;i<m;i++)
  {
      fin>>u1>>v1;
      hist[u1]++;
      hist[v1]++;

  }
  // for( i = 0; i < hist.size(); i++)
  //       cout << "hist[" << i << "] = " << hist[i] << endl;

    thrust::sequence(srcp.begin(), srcp.end(),0);

    // for(i = 0; i < srcp.size(); i++)
    // cout << "srcp[" << i << "] = " << srcp[i] << endl;

    thrust::sort_by_key(hist.begin(), hist.begin() + n, srcp.begin(),thrust::greater<int>());

    // for(i = 0; i < srcp.size(); i++)
    // cout << "srcp[" << i << "] = " << srcp[i] << endl;

    // for(i=0;i<n;i++)
    // {
    //     dstp[srcp[i]]=i;
    // }

    int *d_dstp = thrust::raw_pointer_cast(&dstp[0]);
    int *d_srcp = thrust::raw_pointer_cast(&srcp[0]);
    line89<<< n/1024 + 1 , 1024>>>(d_dstp, d_srcp, n);
    for(i = 0; i < dstp.size(); i++)
      cout << "dstp[" << i << "] = " << dstp[i] << endl;
    thrust::device_vector<int> u(m);
    thrust::device_vector<int> v(m);
    

return 0;


}
