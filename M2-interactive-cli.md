# M2: Interactive CLI MATLAB

**Time:** ~10 min | **Prerequisites:** [M1](M1-preflight.md)

## What you'll do

Allocate an interactive compute node with `srun`, load MATLAB, and run a headless
job — the foundation for all batch workflows in M3 and M4.

## Steps

### Step 1: Allocate an interactive compute node
> **[Expanse-specific]**

From the login node, request an interactive session on a compute node:

```bash
# replace sds196 with your allocation
srun --account=sds196 --partition=shared --nodes=1 --ntasks=1 \
     --cpus-per-task=1 --mem=4G --time=00:30:00 --pty bash
```

Your prompt will change to reflect the compute node (e.g., `exp-1-12`).
This is where MATLAB should actually run — not on the login node.

### Step 2: Load modules on the compute node
> **[Expanse-specific]**

```bash
module purge
module load cpu/0.15.4
module load matlab/2022a
```

### Step 3: Run the headless sanity check
> **[Portable]**

```bash
matlab -batch "disp(version)"
```

**Expected output:**
```
9.12.0.1884302 (R2022a)
```

Exit code 0 confirms MATLAB is functional on this compute node.

### Step 4: Run a script with -batch
> **[Portable]**

Put your MATLAB logic in a `.m` file, then call it:

```bash
matlab -batch "run('$HOME/my_script.m')"
```

> **Important:** Do NOT embed multi-line MATLAB code directly in a shell `heredoc` or
> `sbatch` script — the shell may corrupt whitespace and quoting. Always use a `.m` file.

### Step 5: Exit the interactive session
> **[Portable]**

```bash
exit
```

This releases the compute node and returns you to the login node.

## Pass/Fail Check

- ✅ **PASS:** `matlab -batch "disp(version)"` prints `9.12.0.1884302 (R2022a)` on the compute node
- ❌ **FAIL — srun hangs:** The partition may be busy. Check with `squeue -u $USER` or try again shortly
- ❌ **FAIL — module error:** Confirm you ran `module load cpu/0.15.4` before `module load matlab/2022a`

> **See also:** `scripts/at1_sanity.sh` for a batch-submitted version of this sanity check.

**Next:** [M3 — Scalable Job Arrays](M3-arrays.md)
