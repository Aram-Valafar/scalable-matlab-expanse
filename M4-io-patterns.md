# M4: Storage & I/O Patterns

**Time:** ~15 min | **Prerequisites:** [M2](M2-interactive-cli.md) | **Setup:** [Clone the repo to Expanse first](README.md#getting-started)

## What you'll do

Write intermediate files to node-local scratch (not directly to Lustre), aggregate
them into a single archive, and copy back — protecting the shared filesystem from
small-file metadata storms.

## Why this matters

Expanse's home and project directories use **Lustre**, a parallel filesystem optimized
for large sequential reads and writes. Writing thousands of small files (model
checkpoints, per-iteration outputs) directly to Lustre causes metadata storms that
degrade performance for all users. The fix: write intermediates to `$TMPDIR`
(node-local, fast, per-job), then copy back a single tar archive.

## Steps

### Step 1: Find your scratch directory
> **[Expanse-specific]**

Slurm pre-creates a per-job scratch directory:

```bash
echo $TMPDIR
```

**Expected output:**
```
/scratch/avalafar/job_46860107
```

This directory exists for the lifetime of your job and is automatically cleaned up.

### Step 2: Write intermediates to scratch, not home
> **[Portable]**

In your sbatch script, set `WORKDIR` from `$TMPDIR`:

```bash
WORKDIR=$TMPDIR/my_job
mkdir -p $WORKDIR
export WORKDIR
```

In your `.m` file, read the path:

```matlab
workdir = getenv('WORKDIR');
fname = fullfile(workdir, sprintf('checkpoint_%d.mat', i));
save(fname, 'data');
```

### Step 3: Aggregate small files into one tar
> **[Portable]**

After MATLAB exits, tar everything before copy-back:

```bash
OUTDIR=$HOME/results
mkdir -p $OUTDIR
tar -czf $OUTDIR/checkpoints_${SLURM_JOBID}.tar.gz -C $WORKDIR .
```

The `-C $WORKDIR .` flag archives the contents of `$WORKDIR`, not the directory itself.

Verify the archive:

```bash
tar -tzf $OUTDIR/checkpoints_${SLURM_JOBID}.tar.gz
```

**Expected output:**
```
./
./checkpoint_1.mat
./checkpoint_2.mat
./checkpoint_3.mat
./checkpoint_4.mat
./checkpoint_5.mat
```

### Step 4: Clean up scratch
> **[Portable]**

```bash
rm -rf $WORKDIR
```

### Step 5: Full working example
> **[Expanse-specific]** for account/partition/scratch path; **[Portable]** for I/O pattern

See `scripts/at3_io.sh` and `scripts/at3_work.m` in this repo for a complete,
verified example using all steps above.

Before submitting, copy the MATLAB script to your home directory on Expanse:

```bash
cp scripts/at3_work.m ~/at3_work.m
```

`at3_io.sh` calls `run('$HOME/at3_work.m')` — it expects the script in `$HOME`.

## Pass/Fail Check

- ✅ **PASS:** `tar -tzf ~/results/checkpoints_<jobid>.tar.gz` lists all expected files; no individual `.mat` files exist in `$HOME`
- ❌ **FAIL — WORKDIR not set:** Confirm `export WORKDIR` appears in the sbatch script before `matlab -batch`
- ❌ **FAIL — tar empty:** Confirm MATLAB actually wrote files by checking `ls $WORKDIR` before the tar step (add `echo` statements to debug)

**Next:** [M5 — Portal MATLAB](M5-portal.md)
