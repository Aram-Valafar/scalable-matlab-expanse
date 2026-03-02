#!/bin/bash
#SBATCH --job-name=at3_io
#SBATCH --account=sds196
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:10:00
#SBATCH --output=at3_%j.out

module purge
module load cpu/0.15.4
module load matlab/2022a

# $TMPDIR is pre-created by Slurm: /scratch/$USER/job_$SLURM_JOBID
echo "TMPDIR: $TMPDIR"

# Working directory for intermediate files (not written directly to home/Lustre)
WORKDIR=$TMPDIR/at3
mkdir -p $WORKDIR
echo "WORKDIR: $WORKDIR"

# Pass workdir to MATLAB
export WORKDIR

# Run MATLAB script from home directory
matlab -batch "run('$HOME/at3_work.m')"

# Aggregate all small checkpoint files into one tar before copy-back
OUTDIR=$HOME/at3_results
mkdir -p $OUTDIR
tar -czf $OUTDIR/checkpoints_${SLURM_JOBID}.tar.gz -C $WORKDIR .

echo "AT3: aggregated tar written: $OUTDIR/checkpoints_${SLURM_JOBID}.tar.gz"
echo "AT3: tar contents:"
tar -tzf $OUTDIR/checkpoints_${SLURM_JOBID}.tar.gz

# Clean up scratch
rm -rf $WORKDIR
echo "AT3: scratch cleaned up"
