#!/bin/bash

# Job name:
#SBATCH --job-name=test
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1  
#SBATCH --cpus-per-task=1 #you will reserve all 128 cores but use only 4 threads
#SBATCH --time=00:30:00
#SBATCH --output=test1.out
#SBATCH --constraint=amd
#SBATCH --reservation=fri


export OMP_PLACES=cores
export OMP_PROC_BIND=TRUE

FILE=jacobi_serial


hostname
PERF_GROUP=NUMA

module load likwid/5.2.1-GCC-11.2.0

# FOR SERIAL PROGRAM
gcc -fno-tree-vectorize -O0 ${FILE}.c -o ${FILE}.out 
./${FILE}.out

#UNCOMMENT FOR LIKWID
#gcc -fno-tree-vectorize -O0 -fopenmp ${FILE}.c -I /cvmfs/sling.si/modules/el7/software/likwid/5.2.1-GCC-11.2.0/include/ -L /cvmfs/sling.si/modules/el7/software/likwid/5.2.1-GCC-11.2.0/lib/ -o $FILE.out -llikwid
#likwid-perfctr -m -M 0 -C 0,1,2,3 -g $PERF_GROUP --execpid ./${FILE}.out

#UNCOMMENT FOR HWLOC 
#gcc ${FILE}.c -o ${FILE} $(pkg-config --cflags hwloc) $(pkg-config --libs hwloc)
#gcc ${FILE}.c -o ${FILE}.out -lm -fopenmp $(pkg-config --cflags hwloc) $(pkg-config --libs hwloc)


# run
rm ./${FILE}.out