#!/bin/bash

GEM5_WORKSPACE=/d/hpc/projects/FRI/GEM5/gem5_workspace
GEM5_ROOT=$GEM5_WORKSPACE/gem5
GEM_PATH=$GEM5_ROOT/build/X86

# Directory to store results
RESULTS_DIR="pi_results"
mkdir -p $RESULTS_DIR

# Run experiments with different core counts
echo "Running experiments with different core counts..."

for NUM_CORES in 2 4 8 16
do
    # Run both versions of the program
    for PROGRAM in "pi_falsesharing" "pi_optimized"
    do
        echo "Running $PROGRAM with $NUM_CORES cores..."
        OUTPUT_DIR="$RESULTS_DIR/${PROGRAM}_cores_$NUM_CORES"
        mkdir -p $OUTPUT_DIR
        
        # Run the simulation
        srun apptainer exec $GEM5_WORKSPACE/gem5.sif $GEM_PATH/gem5.opt --outdir=$OUTPUT_DIR ruby_benchmark.py \
            --num_cores=$NUM_CORES \
            --l1_size=32KiB \
            --l2_size=256KiB \
            --binary="../workload/pi/${PROGRAM}.bin"
        
        # Copy stats file to the output directory
        cp m5out/stats.txt $OUTPUT_DIR/
        
        echo "Completed experiment with $PROGRAM using $NUM_CORES cores."
    done
done

echo "All experiments completed."

# Extract key metrics from stats files
echo "Extracting metrics from stats files..."

# Remove existing summary file if it exists
rm -f $RESULTS_DIR/summary.csv

# Create new summary file with header
echo "Program,Core Count,CPI,Execution Time,Invalidations,Load_I,Load_S,Load_E,Load_M,L1_GETS,L1_GETX,Network_Request_Control,Network_Response_Data,Network_Writeback_Data" > $RESULTS_DIR/summary.csv

for NUM_CORES in 2 4 8 16
do
    for PROGRAM in "pi_falsesharing" "pi_optimized"
    do
        STATS_FILE="$RESULTS_DIR/${PROGRAM}_cores_$NUM_CORES/stats.txt"
        
        # Extract CPI
        CPI=$(grep "board.processor.cores.*core.ipc" $STATS_FILE | awk '{sum+=$2; count++} END {if(count>0) print 1/(sum/count); else print "NA"}')
        
        # Extract execution time (in ticks)
        EXEC_TIME=$(grep "simTicks" $STATS_FILE | head -n 1 | awk '{print $2}')
        
        # Extract invalidations
        INVALIDATIONS=$(grep "ruby_system.L1Cache_Controller.Inv::total" $STATS_FILE | awk '{sum+=$2} END {print sum}')
        
        # Extract loads under different states
        LOAD_I=$(grep "L1Cache_Controller.I.Load::total" $STATS_FILE | awk '{sum+=$2} END {print sum}')
        LOAD_S=$(grep "L1Cache_Controller.S.Load::total" $STATS_FILE | awk '{sum+=$2} END {print sum}')
        LOAD_E=$(grep "L1Cache_Controller.E.Load::total" $STATS_FILE | awk '{sum+=$2} END {print sum}')
        LOAD_M=$(grep "L1Cache_Controller.M.Load::total" $STATS_FILE | awk '{sum+=$2} END {print sum}')
        
        # Extract L2 cache requests - use first match only
        L1_GETS=$(grep "L2Cache_Controller.L1_GETS" $STATS_FILE | head -n 1 | awk '{print $2}')
        L1_GETX=$(grep "L2Cache_Controller.L1_GETX" $STATS_FILE | head -n 1 | awk '{print $2}')
        
        # Extract network traffic - use first match only
        NET_REQ_CTRL=$(grep "network.msg_count.Request_Control" $STATS_FILE | head -n 1 | awk '{print $2}')
        NET_RESP_DATA=$(grep "network.msg_count.Response_Data" $STATS_FILE | head -n 1 | awk '{print $2}')
        NET_WB_DATA=$(grep "network.msg_count.Writeback_Data" $STATS_FILE | head -n 1 | awk '{print $2}')
        
        # Print line to summary file - directly using variables
        printf "%s,%d,%.5f,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n" \
               "$PROGRAM" "$NUM_CORES" "$CPI" "$EXEC_TIME" "$INVALIDATIONS" \
               "$LOAD_I" "$LOAD_S" "$LOAD_E" "$LOAD_M" "$L1_GETS" "$L1_GETX" \
               "$NET_REQ_CTRL" "$NET_RESP_DATA" "$NET_WB_DATA" >> $RESULTS_DIR/summary.csv
    done
done

echo "Results summary saved to $RESULTS_DIR/summary.csv" 