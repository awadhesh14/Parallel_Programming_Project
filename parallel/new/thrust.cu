#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <sys/time.h>
#include <functional>
#include <iostream>
#include <bits/stdc++.h>
#include <algorithm>

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
  int u,v,n,m;             // the v1,v2 of edges

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
      fin>>u>>v;
      hist[u]++;
      hist[v]++;

  }
  for( i = 0; i < hist.size(); i++)
        cout << "hist[" << i << "] = " << hist[i] << endl;

    thrust::sequence(srcp.begin(), srcp.end(),0);

    for(i = 0; i < srcp.size(); i++)
    cout << "srcp[" << i << "] = " << srcp[i] << endl;

    thrust::sort_by_key(hist.begin(), hist.begin() + n, srcp.begin(),thrust::greater<int>());

    for(i = 0; i < srcp.size(); i++)
    cout << "srcp[" << i << "] = " << srcp[i] << endl;

    for(i=0;i<n;i++)
    {
        dstp[srcp[i]]=i;
    }

    fin.close();
    fin.open(infile.c_str());
    getline(fin,temp);        // readint the description line 1
    getline(fin,temp);        // reading the description line 2
    fin >> n >> n >> m ;      // reading the MxN graph and edges
    cout<< n<<" "<< m<<endl;
    int u_,v_;
    for(i=0;i<m;i++){
        fin>>u>>v;
        u_ = dstp[u];
        v_ = dstp[v];
        
    }



return 0;


}
