CC=nvcc

all: old
	qsub old-script

old: old.o
	$(CC) -o old old.o

old.o: old.cu
	$(CC) -o old.o -c old.cu

clean:
	rm -f old.o old main.o main job*

main: main.o
	$(CC) -o main main.o
	qsub main-script

main.o: main.cu
	$(CC) -o main.o -c main.cu
