#!/bin/bash
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=4
#SBATCH --partition=picluster
cd $SLURM_SUBMIT_DIR
mpicc hello_mpi.c -o hello_mpi
mpirun ./hello_mpi
