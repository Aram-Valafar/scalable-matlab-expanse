#!/bin/bash
#SBATCH --job-name=at1_sanity
#SBATCH --account=sds196
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=00:05:00
#SBATCH --output=at1_%j.out

module purge
module load cpu/0.15.4
module load matlab/2022a

matlab -batch "disp(version)"
