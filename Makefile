LIBSOURCE = src/lib/instrument.c
CFLAGS = -finstrument-functions
OFLAGS =  
GCC    = gcc
ODEP    = str.cma unix.cma
OSOURCE = adt.ml symresolver.ml parser.ml main.ml

all: sample main

sample: libprofile.a
	${GCC} -o sample ${CFLAGS} sample.c libprofile.a -lrt

instrument.o: 
	${GCC} -c -Wall -O2 ${LIBSOURCE}

libprofile.a: instrument.o
	ar rvs libprofile.a instrument.o
	
main: 
	cd src/profiler && pwd && ocamlc $(ODEP) $(OSOURCE)
	mv src/profiler/a.out profiler.native
	
clean:
	rm -rf *.o; rm -rf *.a;
	rm -f sample;
	rm -f *.native;
	rm -rf src/profiler/_build;
	rm -f src/profiler/*.o;
	rm -f src/profiler/*.cmi;
	rm -f src/profiler/*.cmo;
	
#ocamlc str.cma parser.ml main.ml 
