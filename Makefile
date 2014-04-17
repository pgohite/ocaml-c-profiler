LIBSOURCE = src/lib/instrument.c
CFLAGS = -finstrument-functions
GCC    = gcc

all: sample

sample: libprofile.a
	${GCC} -o sample ${CFLAGS} sample.c libprofile.a -lrt

instrument.o: 
	${GCC} -c -Wall -O2 ${LIBSOURCE}

libprofile.a: instrument.o
	ar rvs libprofile.a instrument.o

clean:
	rm -rf *.o; rm -rf *.a; rm -f sample
