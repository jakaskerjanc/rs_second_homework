# Second homework assignment


## Employing Jacobi method for temperature distribution 

The Jacobi iterative method is a fundamental numerical technique for solving linear equation systems in an iterative fashion. This method operates by iteratively updating the values of unknowns in a system based on the values of neighboring variables, gradually refining the solution until a specified level of accuracy is achieved. In each iteration, the method computes the new values for each variable by averaging the values of its neighbors from the previous iteration. For this homework task, our objective is to employ the Jacobi method for the temperature distribution in a two-dimensional rectangular problem. We have defined the boundary conditions and computed the temperature distribution across various sizes of the problem domain. 

### Homework assignment 

In this homework assignment, you will employ the Jacobi iterative method as a benchmark to assess the efficiency of multithreaded programs, with a particular emphasis on the effects of thread pinning to hardware cores and the complexities of Non-Uniform Memory Access (NUMA) architectures. Initially, you'll investigate the performance impacts of thread pinning using the likwid tool. Additionally, you'll delve into the trade-offs between thread pinning and NUMA-aware memory allocation to uncover the constraints and opportunities associated with speeding up programs with multicore systems.


### Parallelize program 

In the repository, you will find the serial implementation of the Jacobi method for temperature distribution (jacobi_serial.c). Using serial implementation, adapt the program for multicore execution using the OpenMP library. 

### Evaluating the effects thread pining using likwid tool 

Utilizing the likwid tool (likwid-perfctr), analyze the performance of multithreaded applications across various hardware thread (hart) configurations:

1. Evaluate performance with 4 harts belonging to the same CCX.
2. Evaluate performance with 4 harts, distributing two threads per two adjacents cores.
3. Assess performance with 4 harts, distributing two threads per two adjacents CCX.
4. Evaluate performance with 4 harts, distributing two threads within same CCX per two adjacents CCD.
5. Analyze performance with 4 harts, distributing two threads within same CCX per two non-adjacent CCD.
6. Evaluate performance with 4 harts, distributing two threads within same CCX per NUMA domain.

During evaluation, monitor NUMA traffic, cache behavior, CPI, FLOPS, and execution time. Provide a detailed explanation of the obtained results in the report.  

### Memory binding and NUMA performance 

In this assignment, you aim to identify the closest CCXs to the data source. Start by binding the temperature matrix to the first NUMA domain, then systematically pin the four hardware threads (harts) to each CCX in succession. For instance, bind all four harts to the first CCX, measure performance, then repeat the process for the second CCX, and so forth. Repeat these experiments when binding the temperature matrix to the second NUMA domain. Represent the results in the form of matrix (NUMA domains vs CCX). To accomplish this, utilize the hwloc library. 

 **Analysis and Reporting:** Describe your results in a report (two-page max).
 **Warning:** Switch -C in likwid-perfctr pins and measures performance of threads. If you want only measure without pinning, use -c switch. (case sensitive!!!)
