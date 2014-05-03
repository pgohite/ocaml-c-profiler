# OCAML-C-PROFILER makefile
# Use make clean to clean up generated object files
# Use make all to build project

LIBSOURCE = src/lib/instrument.c
CFLAGS    = -finstrument-functions
OFLAGS 	  =  
GCC		= 	gcc
ODEP    = 	str.cma unix.cma
OSOURCE = 	symresolver.ml \
			util.ml \
			callstats.ml \
			callstack.ml \
			callgraph.ml \
			threadstats.ml \
			parsedb.ml \
			parser.ml \
			main.ml
SAMPLE  =   sample/demo.c

all: demo main

#Compile Demo Code
demo: libprofile.a libsort.a
	${GCC} -g -o demo.o ${CFLAGS} ${SAMPLE} libprofile.a libsort.a -lrt

sort.o:
	${GCC} -c -Wall -O2 sample/sort.c
    
libsort.a : sort.o
	ar rvs libsort.a sort.o

#Compile instrumentation lib
instrument.o: 
	${GCC} -c -Wall -O2 ${LIBSOURCE}
   	
libprofile.a: instrument.o
	ar rvs libprofile.a instrument.o
	
#Compile OCAML profiler
main: 
	cd src/profiler && pwd && ocamlc $(ODEP) $(OSOURCE)
	mv src/profiler/a.out profiler.native

#Clean up	
clean:
	rm -f *.o; rm -f *.a; rm -f *.out
	rm -f *.native;
	rm -rf src/profiler/_build;
	rm -f src/profiler/*.o;
	rm -f src/profiler/*.cmi;
	rm -f src/profiler/*.cmo;
	
#ocamlc str.cma parser.ml main.ml 
