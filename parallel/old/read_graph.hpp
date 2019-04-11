ifstream fin;
ofstream fout;
string infile, outfile;

void readGraph(char *filename, G *g){
  cout<<"inside readGraph"<<endl;
  // infile ="../../../input/"      + name + ".mmio" ; //  ../../../input/amazon0302_adj.mmio
  // outfile="../../output/serial/" + name + ".txt"  ; //  dataset+"-out.txt";
  infile =filename;

  fin.open(infile.c_str());    // opening the input file
  fout.open(outfile.c_str());  // opening the output file

  string temp;
  getline(fin,temp); // readint the description line 1
  getline(fin,temp); // reading the description line 2

  var temp_e;          // temperory edge because edge weight is useless
  var u,v;             // the v1,v2 of edges

  fin >> g->N >> g->N >> g->M ;       // reading the MxN graph and edges
  cout<< g->N<<" "<< g->M<<endl;      // just checking if it worked



/**************************allocating & initializing all flag[N] to false**********************************/
  bool flag[g->N];                // tells whether particular row is empty or not
  for (var i=0 ; i < g->N ; i++) {
      flag[i] = false;            // false means empty
  }

/**************************allocating & initializing all roff[N+1] to zero**********************************/
  g->roff = (eid_t *) malloc((g->N + 1) * sizeof(eid_t));
  assert(g->roff != NULL);
  for (var i=0 ; i < g->N+1 ; i++) {
      g->roff[i] = 0;
  }

/**************************increase row offset and set flag for non empty row********************************/
	for (var i=0; i<g->M; ++i) {           //thrust
		fin >> u >> v >>temp_e;
    cout<< u <<" "<<v <<endl;

    if(u > v)
      g->roff[u]++ , flag[u] = true;
    else if(u < v)
      g->roff[v]++ , flag[v] = true;

	}

/**********************populates indexs of nonzero rows rows[n] and initilizes n (no of non empty rows)******/
  g->rows = (eid_t *) malloc((g->N) * sizeof(eid_t));
  g->n = 0;


  var k =0;
  for (var i = 0; i<g->N; i++){
     if (flag[i] == true){
       g->n++;                            //thrust
       g->rows[k] = i;                    //thrust
       k++;
     }
   }

/**********************************************************************************************************/
//converting the roff from degree holder to actual usage.
  eid_t *temp_num_edges = (eid_t *) malloc((g->N + 1) * sizeof(eid_t));
  assert(temp_num_edges != NULL);

  temp_num_edges[0] = 0;
  int m=0;
  for(i = 0; i < g->N; i++) {
      m += g->roff[i];
      temp_num_edges[i+1] = m;
  }

/**********************************************************************************************************/
  //Allocate space for adj
  g->adj = (eid_t *) malloc(m * sizeof(eid_t));
  assert(g->adj != NULL);


  for(i= 0; i < g->N+1; i++)
    g->roff[i] = temp_num_edges[i];

/**********************************************************************************************************/
  g->rlen = (eid_t *) malloc((g->N) * sizeof(eid_t));
  k =0;

  for ( i = 0; i<g->N; i++){
    if (flag[i] == true)
      g->rlen[k] = g->roff[i+1] - g->roff[i];
    else
      g->rlen[k] = 0;
    k++;
  }

/**********************************************************************************************************/
  fin.close();
  fin.open(filename.c_str());
  getline(fin,temp); // readint the description line 1
  getline(fin,temp); // reading the description line 2

  //Read N and M
  //fscanf(infp, "%ld %ld\n", &(g->n), &m);
  fin>>(g->N)>>(g->N)>>m;
  for(i = 0; i < m; i++)
    g->adj[i] = 0;
  //Read the edges
  // while( fscanf(infp, "%u %u\n", &u, &v) != EOF ) {
  for(var i=0 ; i<m ; i++){


    fin>>u>>v;
    if(u>v){
      g->adj[ temp_num_edges[u]  ] = v;
      temp_num_edges[u]++;
    }
    else if (u<v){
      g->adj[ temp_num_edges[v] ] = u;
      temp_num_edges[v]++;
    }


  }
  fin.close();

/**********************************************************************************************************/

}
