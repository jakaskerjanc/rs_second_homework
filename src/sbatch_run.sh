#!/bin/bash

# Job name:
#SBATCH --job-name=test
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1  
#SBATCH --cpus-per-task=128 #gives random 4 cores in the processor, maybe allocate all the cores in the node then select 4 cores for the job using likwid-perfctr
#SBATCH --time=00:15:00
#SBATCH --output=test1.out
#SBATCH --constraint=amd
#SBATCH --reservation=fri
#SBATCH --propagate=STACK


export OMP_PLACES=cores
export OMP_PROC_BIND=TRUE

FILE=jacobi


hostname
PERF_GROUP=NUMA

module load likwid/5.2.1-GCC-11.2.0

# compile
#gcc ${FILE}.c -o ${FILE} $(pkg-config --cflags hwloc) $(pkg-config --libs hwloc)
#gcc ${FILE}.c -o ${FILE}.out -lm -fopenmp $(pkg-config --cflags hwloc) $(pkg-config --libs hwloc)
gcc -fno-tree-vectorize -O0 -fopenmp ${FILE}.c -I /cvmfs/sling.si/modules/el7/software/likwid/5.2.1-GCC-11.2.0/include/ -L /cvmfs/sling.si/modules/el7/software/likwid/5.2.1-GCC-11.2.0/lib/ -o $FILE.out -llikwid
likwid-perfctr -m -M 0 -C 0,1,2,3 -g $PERF_GROUP --execpid ./${FILE}.out
echo "+++++++++++++++++++++++++"
likwid-perfctr -m -M 0 -C 0,1,4,5 -g $PERF_GROUP --execpid ./${FILE}.out
echo "+++++++++++++++++++++++++"
likwid-perfctr -m -M 0 -C 0,1,8,7 -g $PERF_GROUP --execpid ./${FILE}.out
echo "+++++++++++++++++++++++++"
likwid-perfctr -m -M 0 -C 0,1,16,15 -g $PERF_GROUP --execpid ./${FILE}.out
echo "+++++++++++++++++++++++++"
likwid-perfctr -m -M 0 -C 0,1,32,33 -g $PERF_GROUP --execpid ./${FILE}.out
echo "+++++++++++++++++++++++++"
likwid-perfctr -m -M 0 -C 0,1,48,49 -g $PERF_GROUP --execpid ./${FILE}.out

# run
rm ./${FILE}.out