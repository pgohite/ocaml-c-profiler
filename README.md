OCAML Based C application profiler

1. Compiling

cd ocaml-c-profiler
make clean
make all

(generates demo.o and profiler.native)

2. Running Demo App

./demo.o

3. Running Profiler

./profiler.native -n demo.o -p profile.data

(Scroll up and see outputs *)
