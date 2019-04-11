ifstream fin;
ofstream fout;
string infile, outfile;

int readGraph(char *filename, G *g){
  cout<<"inside readGraph"<<endl;
  // infile ="../../../input/"      + name + ".mmio" ; //  ../../../input/amazon0302_adj.mmio
  // outfile="../../output/serial/" + name + ".txt"  ; //  dataset+"-out.txt";
  infile =filename;

  fin.open(infile.c_str());    // opening the input file
  fout.open(outfile.c_str());  // opening the output file

  string temp;
  getline(fin,temp); // readint the description line 1
  getline(fin,temp); // reading the description line 2

  int temp_e;          // temperory edge because edge weight is useless
  int u,v;             // the v1,v2 of edges

  fin >> g->n >> g->n >> g->m ;       // reading the MxN graph and edges
  cout<< g->n<<" "<< g->m<<endl;



  bool flag[g->n];  // tells whether particular row is empty or not
  var m = 0;        // m -> no of edges





	for (int i=0; i<m; ++i) {  // runs all the m edges
		fin >> u >> v >>temp_e;  // reading the edgelist
		if (u==v) continue;      //
		vMax=max(vMax,max(u,v));
	}
  n=vMax+1;                  //
}
