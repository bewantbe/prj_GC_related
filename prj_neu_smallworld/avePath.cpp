// mkoctfile -ligraph avePath.cpp

#include <octave/oct.h>
#include <igraph/igraph.h>

DEFUN_DLD (avePath, args, nargout,
           "return average shortest path between every pairs of points\n")
{
  int nargin = args.length ();
  if (nargin != 1) {
    print_usage ();
    return octave_value_list ();    
  }

  //octave_stdout << "Hello World has " << nargin
  //<< " input arguments and "
  //<< nargout << " output arguments.\n";

  NDArray A = args(0).array_value ();
  //Matrix A = args(0).array_value ();
  int n=A.dims()(0);
  int m=A.dims()(1);

  igraph_t graph;
  igraph_vector_t v;
  igraph_real_t *edges = (igraph_real_t*) calloc(2*n*m, sizeof(igraph_real_t));
  igraph_real_t avg_path;

  //if (! error_state) {
  //print_usage ();
  //return octave_value_list ();
  //}
  int c = 0;
  for (int i=0; i<n; i++) {
    for (int j=0; j<m; j++) {
      if (A(i,j)!=0) {
        edges[c  ] = j;
        edges[c+1] = i;
        //octave_stdout << "(" << j << " -> " << i << ")\n";
        c += 2;
      }
    }
  }

  igraph_vector_view(&v, edges, 2*n);
  igraph_create(&graph, &v, 0, IGRAPH_DIRECTED);
  igraph_average_path_length(&graph, &avg_path, IGRAPH_DIRECTED, 1);
  igraph_destroy(&graph);  
  free(edges);

  return octave_value(avg_path);
}

