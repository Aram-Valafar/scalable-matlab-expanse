#!/bin/bash
#SBATCH --job-name=at2_array
#SBATCH --account=sds196
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=00:05:00
#SBATCH --array=1-5
#SBATCH --output=at2_%A_%a.out

module purge
module load cpu/0.15.4
module load matlab/2022a

matlab -batch "fprintf('AT2 task %d complete\n', str2num(getenv('SLURM_ARRAY_TASK_ID')))"
