#!/bin/bash
#SBATCH --job-name=gem5_simulation
#SBATCH --output=gem5_log.txt
#SBATCH --cpus-per-task=16
#SBATCH --ntasks=1
#SBATCH --time=04:00:00

GEM5_WORKSPACE=/d/hpc/projects/FRI/GEM5/gem5_workspace
GEM5_ROOT=$GEM5_WORKSPACE/gem5
GEM_PATH=$GEM5_ROOT/build/X86

# Directory to store results
RESULTS_DIR="network_results"
mkdir -p $RESULTS_DIR

# Run experiments with different core counts and network topologies
echo "Running experiments with different core counts and network topologies..."

for NUM_CORES in 2 4 8 16
do
    for NETWORK in "SimplePt2Pt" "Circle" "Crossbar"
    do
        echo "Running with $NUM_CORES cores on $NETWORK network..."
        OUTPUT_DIR="$RESULTS_DIR/${NETWORK}_cores_$NUM_CORES"
        mkdir -p $OUTPUT_DIR
        
        # Run the simulation
        srun apptainer exec $GEM5_WORKSPACE/gem5.sif $GEM_PATH/gem5.opt --outdir=$OUTPUT_DIR network_benchmark.py \
            --num_cores=$NUM_CORES \
            --l1_size=32KiB \
            --l2_size=256KiB \
            --network=$NETWORK
        
        echo "Completed experiment with $NETWORK network using $NUM_CORES cores."
    done
done

echo "All experiments completed."

# Extract key metrics from stats files
echo "Extracting metrics from stats files..."

# Remove existing summary file if it exists
rm -f $RESULTS_DIR/summary.csv

# Create new summary file with header
echo "Network,Core Count,Network_Request_Control,Network_Response_Data,Network_Writeback_Data" > $RESULTS_DIR/summary.csv

for NUM_CORES in 2 4 8 16
do
    for NETWORK in "SimplePt2Pt" "Circle" "Crossbar"
    do
        STATS_FILE="$RESULTS_DIR/${NETWORK}_cores_$NUM_CORES/stats.txt"
        
        if [ -f "$STATS_FILE" ]; then
            # Extract network traffic metrics
            NET_REQ_CTRL=$(grep "network.msg_count.Request_Control" $STATS_FILE | head -n 1 | awk '{print $2}')
            NET_RESP_DATA=$(grep "network.msg_count.Response_Data" $STATS_FILE | head -n 1 | awk '{print $2}')
            NET_WB_DATA=$(grep "network.msg_count.Writeback_Data" $STATS_FILE | head -n 1 | awk '{print $2}')
            
            # Print line to summary file
            printf "%s,%d,%s,%s,%s\n" \
                   "$NETWORK" "$NUM_CORES" "$NET_REQ_CTRL" "$NET_RESP_DATA" "$NET_WB_DATA" >> $RESULTS_DIR/summary.csv
        else
            echo "Warning: Stats file not found for $NETWORK with $NUM_CORES cores"
        fi
    done
done

echo "Results summary saved to $RESULTS_DIR/summary.csv" 