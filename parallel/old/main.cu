#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <sys/time.h>
#include <functional>
#include <iostream>

#include <fstream>


#include <climits>
#include<cuda.h>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>
#include <math.h>


#define GS 1024
#define BS 1024

using namespace std;

typedef unsigned int eid_t;
typedef long var;


typedef struct{
  var N;  //no of vertices
  var M;  //no of edges
  var n; //no of non empty rows
  var nnz;

  eid_t *cols;  //nonzeroes in each row (colind)
  eid_t *roff;  //startig offset of each row (rowoff)
  eid_t *rlen;  //length of each row
  eid_t *rows;  //indices of the non empty rows
} G;

#include "read_graph.hpp"


int main(int argc, char *argv[]){

  G g;
  int gs=GS;
  int k = 68;

  readGraph("../../test_dir.txt",&g);
  cout<<"checkpoint 1"<<endl;

  cout<<"rows"<<endl;
  for (var i=0;i<(g.n) ;i++){
    cout<<g.rows[i]<<" ";
  }
  cout<<endl;
  cout<<"cols"<<endl;
  for (var i=0;i<(g.nnz) ;i++){
    cout<<g.cols[i]<<" ";
  }
  cout<<endl;
  cout<<"roff"<<endl;
  for (var i=0;i<(g.N+1) ;i++){
    cout<<g.roff[i]<<" ";
  }
  cout<<endl;
  cout<<"rlen"<<endl;
  for (var i=0;i<(g.N) ;i++){
    cout<<g.rlen[i]<<" ";
  }
  cout<<endl;


}
