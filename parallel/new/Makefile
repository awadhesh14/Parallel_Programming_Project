CC=nvcc

all: thrust
	qsub thrust-script

thrust: thrust.o
	$(CC) -o thrust thrust.o

thrust.o: thrust.cu
	$(CC) -o thrust.o -c thrust.cu

clean:
	rm -f thrust.o thrust
