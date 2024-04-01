# Benchmarking Parallel Performance MPI Packages
This is my application test result of debian GSOC 2024 project **Benchmarking Parallel Performance MPI Packages**.

## My Environment
Google Cloud Engine Debian 12 with 4 CPU core.

## How to run
You have to be root to run this shell script.
```bash
sh iterate_benchmark.sh
```

## How does it work
It will iterate over all the free BLAS implementation in Debian package, and use `autopkgtest` to run the fenicsx-performance-tests with different BLAS libraries respectively. 
