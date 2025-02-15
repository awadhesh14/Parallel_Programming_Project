ifstream fin;
ofstream fout;
string infile, outfile;

void readGraph(string filename, G *g){
  cout<<"inside readGraph"<<endl;
  // infile ="../../../input/"      + name + ".mmio" ; //  ../../../input/amazon0302_adj.mmio
  // outfile="../../output/serial/" + name + ".txt"  ; //  dataset+"-out.txt";
  infile =filename;

  fin.open(infile.c_str());    // opening the input file
  fout.open(outfile.c_str());  // opening the output file

  string temp;
  getline(fin,temp); // readint the description line 1
  getline(fin,temp); // reading the description line 2

  var temp_edge;          // temperory edge because edge weight is useless
  var u,v;             // the v1,v2 of edges

  fin >> g->V >> g->V >> g->E ;       // reading the MxN graph and edges
  cout<< g->V<<" "<< g->E<<endl;      // just checking if it worked



/**************************allocating & initializing all flag[V] to false**********************************/
  bool flag[g->V];                // tells whether particular row is empty or not
  for (var i=0 ; i < g->V ; i++) {
      flag[i] = false;            // false means empty
  }

/**************************allocating & initializing all roff[V+1] to zero**********************************/
  g->roff = (uui *) malloc((g->V + 1) * sizeof(uui));
  assert(g->roff != NULL);
  for (var i=0 ; i < g->V+1 ; i++) {
      g->roff[i] = 0;
      //cout<<g->roff[i]<<" ";
  }cout<<endl;

/**************************increase row offset and set flag for non empty row********************************/
	for (var i=0; i<g->E; ++i) {           //thrust
		fin >> u >> v >>temp_edge;
    cout<< u <<" "<<v <<endl;

    if(u > v)
      g->roff[u+1]++ , flag[u] = true;
    else if(u < v)
      g->roff[v+1]++ , flag[v] = true;

	}

/**********************populates indexs of nonzero rows rows[n] and initilizes n (no of non empty rows)******/
  g->rows = (uui *) malloc((g->V) * sizeof(uui));
  g->n = 0;


  var k =0;
  for (var i = 0; i<g->V; i++){
     if (flag[i] == true){
       g->n++;                            //thrust
       g->rows[k++] = i;                    //thrust
     }
   }

/**********************************************************************************************************/
//converting the roff from degree holder to actual usage.
  uui *temp_num_edges = (uui *) malloc((g->V + 1) * sizeof(uui));
  assert(temp_num_edges != NULL);

  temp_num_edges[0] = 0;
  //g->E= 0;
  k=0;
  for(var i = 0; i < g->V; i++) {
    //  g->E += g->roff[i];
      k += g->roff[i+1];
      temp_num_edges[i+1] =k;
  }

  for(var i= 0; i < g->V+1; i++)
    g->roff[i] = temp_num_edges[i];

/**********************************************************************************************************/
  g->rlen = (uui *) malloc((g->V) * sizeof(uui));
  k =0;

  for (var i = 0; i<g->V; i++){
    if (flag[i] == true)
      g->rlen[k] = g->roff[i+1] - g->roff[i];
    else
      g->rlen[k] = 0;
    k++;
  }

/**********************************************************************************************************/
  //Allocate space for colind
  g->colind = (uui *) malloc(g->E * sizeof(uui));
  assert(g->colind != NULL);

  fin.close();
  fin.open(infile.c_str());
  getline(fin,temp); // readint the description line 1
  getline(fin,temp); // reading the description line 2

  //Read V and E
  //fscanf(infp, "%ld %ld\n", &(g->n), &g->E);
  fin>>(g->V)>>(g->V)>>g->E;
  for(var i = 0; i < g->E; i++)
    g->colind[i] = 0;
  //Read the edges
  // while( fscanf(infp, "%u %u\n", &u, &v) != EOF ) {
  for(var i=0 ; i<g->E ; i++){


    fin>>u>>v>>temp_edge;
    if(u>v){
      g->colind[ temp_num_edges[u]  ] = v;
      temp_num_edges[u]++;
    }
    else if (u<v){
      g->colind[ temp_num_edges[v] ] = u;
      temp_num_edges[v]++;
    }


  }
  fin.close();

/**********************************************************************************************************/

}
