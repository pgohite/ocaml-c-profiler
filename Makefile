LIBSOURCE = src/lib/instrument.c
CFLAGS = -finstrument-functions
OFLAGS = 
GCC    = gcc
OSOURCE = main.ml

all: sample

sample: libprofile.a
	${GCC} -o sample ${CFLAGS} sample.c libprofile.a -lrt

instrument.o: 
	${GCC} -c -Wall -O2 ${LIBSOURCE}

libprofile.a: instrument.o
	ar rvs libprofile.a instrument.o
	
main: 
	cd src/profiler
	corebuild $(OSOURCE) main.native
	
clean:
	rm -rf _build *.native


clean:
	rm -rf *.o; rm -rf *.a; rm -f sample; *.native
	
#ocamlc str.cma parser.ml main.ml 
