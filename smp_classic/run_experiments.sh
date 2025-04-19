#!/bin/bash

GEM5_WORKSPACE=/d/hpc/projects/FRI/GEM5/gem5_workspace
GEM5_ROOT=$GEM5_WORKSPACE/gem5
GEM_PATH=$GEM5_ROOT/build/X86

# First, make sure the Cholesky binary is built
# echo "Building Cholesky decomposition binary..."
# pushd ../workload/cholesky
# make clean
# apptainer exec $GEM5_WORKSPACE/gem5.sif make
# popd

# Directory to store results
RESULTS_DIR="cholesky_results"
mkdir -p $RESULTS_DIR

# Run experiments with different core counts
# echo "Running experiments with different core counts..."

# for NUM_CORES in 2 4 8 16
# do
#     echo "Running with $NUM_CORES cores..."
#     OUTPUT_DIR="$RESULTS_DIR/cores_$NUM_CORES"
#     mkdir -p $OUTPUT_DIR
    
#     # Run the simulation with specific number instead of variable
#     srun apptainer exec $GEM5_WORKSPACE/gem5.sif $GEM_PATH/gem5.opt --outdir=$OUTPUT_DIR smp_benchmark.py \
#         --num_cores=$NUM_CORES \
#         --l1_size=32KiB \
#         --l2_size=256KiB \
#         --l3_size=2MiB
    
#     # Copy stats file to the output directory
#     cp m5out/stats.txt $OUTPUT_DIR/
    
#     echo "Completed experiment with $NUM_CORES cores."
# done

echo "All experiments completed."

# Simple script to extract key metrics from stats files
echo "Extracting metrics from stats files..."

# Remove existing summary file if it exists
rm -f $RESULTS_DIR/summary.csv

# Create new summary file with header
echo "Core Count,CPI,L1D Miss Ratio,Upgrade Requests,Snoop Traffic" > $RESULTS_DIR/summary.csv

for NUM_CORES in 2 4 8 16
do
    STATS_FILE="$RESULTS_DIR/cores_$NUM_CORES/stats.txt"
    
    # Extract CPI
    CPI=$(grep "board.processor.cores.*core.ipc" $STATS_FILE | awk '{sum+=$2; count++} END {if(count>0) print 1/(sum/count); else print "NA"}')
    
    # Extract L1D cache miss ratio
    L1D_MISSES=$(grep "board.cache_hierarchy.clusters.*l1d_cache.overallMisses::total" $STATS_FILE | awk '{sum+=$2} END {print sum}')
    L1D_HITS=$(grep "board.cache_hierarchy.clusters.*l1d_cache.overallHits::total" $STATS_FILE | awk '{sum+=$2} END {print sum}')
    L1D_MISS_RATIO=$(awk -v misses="$L1D_MISSES" -v hits="$L1D_HITS" 'BEGIN {if(misses+hits > 0) printf "%.6f", misses/(misses+hits); else print "NA"}')
    
    # Extract upgrade requests at L3 cache - use first match only
    UPGRADE_REQUESTS=$(grep "board.cache_hierarchy.l3_bus.transDist::UpgradeReq" $STATS_FILE | head -n 1 | awk '{print $2}')
    
    # Extract snoop traffic - use first match only
    SNOOP_TRAFFIC=$(grep "board.cache_hierarchy.l3_bus.snoopTraffic" $STATS_FILE | head -n 1 | awk '{print $2}')
    
    # Print line to summary file - directly using variables
    printf "%d,%.5f,%.6f,%d,%d\n" "$NUM_CORES" "$CPI" "$L1D_MISS_RATIO" "$UPGRADE_REQUESTS" "$SNOOP_TRAFFIC" >> $RESULTS_DIR/summary.csv
done

echo "Results summary saved to $RESULTS_DIR/summary.csv"