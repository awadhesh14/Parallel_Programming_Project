CC=nvcc

all: old
	qsub old-script

old: old.o
	$(CC) -o old old.o

old.o: old.cu
	$(CC) -o old.o -c old.cu ../../test_dir.txt

clean:
	rm -f old.o old
