# Snooping-Based Cache Coherence Protocol Performance Analysis

This directory contains scripts to analyze the performance of a snooping-based cache coherence protocol in a multiprocessor system using Cholesky decomposition as the benchmark workload.

## Experiment Setup

The experiment evaluates the cache coherence protocol with different processor counts:
- 2 cores
- 4 cores
- 8 cores
- 16 cores

### Cache Hierarchy Configuration

- **L1 cache**: 32KB, 8-way set associative, 64B cache line size (private to each core)
- **L2 cache**: 256KB, 8-way set associative, 64B cache line size (private to each core)
- **L3 cache**: 2MB, 16-way set associative, 64B cache line size (shared)

### Metrics

The experiment measures the following metrics:
1. CPI (Cycles Per Instruction)
2. L1 cache miss ratio per core
3. Number of upgrade requests at L3 cache
4. Snoop traffic

## Running the Experiment

To run the experiment, execute the `run_experiments.sh` script:

```bash
./run_experiments.sh
```

This script will:
1. Build the Cholesky decomposition binary
2. Run the simulation with different core counts
3. Extract and summarize the key metrics

## Files

- `smp_benchmark.py`: GEM5 simulation script
- `three_level.py`: Three-level cache hierarchy implementation
- `run_experiments.sh`: Script to run all experiments and extract metrics
- `run_benchmark.sh`: Original benchmark script

## Results

After running the experiments, a summary of results will be available in the `cholesky_results/summary.csv` file. Detailed statistics for each run are stored in individual directories for further analysis. 