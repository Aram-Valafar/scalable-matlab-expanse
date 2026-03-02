# M1: Pre-flight & GUI→CLI Migration

**Time:** ~10 min | **Prerequisites:** Linux command line basics

## What you'll do

Orient yourself on Expanse: confirm your allocation, load MATLAB, and learn the
key CLI equivalents for common MATLAB GUI actions before running any jobs.

## Steps

### Step 1: Log in via portal shell
> **[Expanse-specific]**

Go to https://portal.expanse.sdsc.edu → **Expanse Shell Access**. This opens a
browser-based terminal on a login node. (SSH also works once your key is configured:
`ssh <username>@login.expanse.sdsc.edu`.)

### Step 2: Confirm your allocation account
> **[Expanse-specific]**

```bash
groups
```

**Expected output:**
```
sds196
```

This is the account name you will pass to every `sbatch` and `srun` command with `-A sds196`.

Also check your home directory quota:

```bash
quota -s
```

### Step 3: Load MATLAB
> **[Expanse-specific]**

On Expanse, MATLAB requires a prerequisite module. Always load in this order:

```bash
module purge
module load cpu/0.15.4
module load matlab/2022a
```

Omitting `cpu/0.15.4` causes: `These module(s) or extension(s) exist but cannot be loaded as requested`.

Verify what is loaded:

```bash
module list
```

### Step 4: Run a quick sanity check
> **[Portable]**

```bash
matlab -batch "disp(version)"
```

**Expected output:**
```
9.12.0.1884302 (R2022a)
```

> **Note:** Running `matlab -batch` on a login node is fine for a quick version check.
> For real computation, always use a compute node via `sbatch` or `srun` (see M2).

### Step 5: GUI→CLI reference
> **[Portable]**

| GUI action | CLI / batch equivalent |
|---|---|
| Open MATLAB and run a script | `matlab -batch "run('~/my_script.m')"` |
| Run a one-liner | `matlab -batch "disp(version)"` |
| Check GPU availability | `matlab -batch "disp(gpuDeviceCount)"` |
| Generate and save a plot | `saveas(gcf, fullfile(getenv('HOME'), 'plot.png'))` inside a `.m` file |
| Check a variable | Use `fprintf` or `disp` — no interactive workspace in `-batch` mode |

**Key `-batch` rules:**
- No GUI windows open
- No keyboard input accepted
- Exit code 0 = success, non-zero = error (Slurm will mark job FAILED)
- Always put multi-line logic in a `.m` file; call it with `run('~/script.m')`

## Pass/Fail Check

- ✅ **PASS:** `groups` shows `sds196` and `matlab -batch "disp(version)"` prints `9.12.0.1884302 (R2022a)`
- ❌ **FAIL — module error:** Run `module spider matlab/2022a` to confirm `cpu/0.15.4` is listed as prerequisite, then load it first
- ❌ **FAIL — account not found:** Contact consult@sdsc.edu to confirm your allocation is active

**Next:** [M2 — Interactive CLI MATLAB](M2-interactive-cli.md)
