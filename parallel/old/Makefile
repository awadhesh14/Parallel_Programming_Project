CC=nvcc

all: main
	qsub samole-script

main: main.o
	$(CC) -o main main.o

main.o: main.cu
	$(CC) -o main.o -c main.cu

clean:
	rm -f main.o main
