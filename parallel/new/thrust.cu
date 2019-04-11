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

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>


using namespace std;

ifstream fin;
ofstream fout;
string infile, outfile;

int main()
{
    cout<<"inside readGraph"<<endl;
  // infile ="../../../input/"      + name + ".mmio" ; //  ../../../input/amazon0302_adj.mmio
  // outfile="../../output/serial/" + name + ".txt"  ; //  dataset+"-out.txt";
  infile ="../../test_dir.txt";

  fin.open(infile.c_str());    // opening the input file
  fout.open(outfile.c_str());  // opening the output file

  string temp;
  getline(fin,temp); // readint the description line 1
  getline(fin,temp); // reading the description line 2

  int temp_e;          // temperory edge because edge weight is useless
  int u,v;             // the v1,v2 of edges

  fin >> g->n >> g->n >> g->m ;       // reading the MxN graph and edges
  cout<< g->n<<" "<< g->m<<endl;

  //int hist[n], srcp[n], dstp[n];

  thrust::host_vector<int> hist(g->n);

  int i;
  for(i=0;i<m;i++)
  {
      fin>>u>>v;
      hist[u]++;
      hist[v]++;
  }
  for(int i = 0; i < H.size(); i++)
        cout << "hist[" << i << "] = " << hist[i] << endl;

return 0;


}

