# M5: Portal MATLAB (GUI)

**Time:** ~10 min | **Prerequisites:** [M1](M1-preflight.md)

## What you'll do

Launch the MATLAB GUI from the Expanse User Portal, generate a plot, and save it
to your home directory. Use the portal for visualization and debugging only —
compute-intensive work belongs in batch jobs (M2–M4).

## Steps

### Step 1: Open the portal and launch MATLAB
> **[Expanse-specific]**

Go to https://portal.expanse.sdsc.edu and click **MATLAB**.

### Step 2: Configure the session
> **[Expanse-specific]**

Use these settings:

| Field | Value |
|---|---|
| Account | `sds196` |
| Partition | `shared` |
| Number of hours | `1` |
| CPUs | `1` |
| Memory (GB) | `4` |

Click **Launch**. Wait 1–2 minutes for the session to start.

### Step 3: Note the OpenGL warning
> **[Expanse-specific]**

When MATLAB opens you will see:

```
Warning: MATLAB has disabled some advanced graphics rendering features by
switching to software OpenGL.
```

**This is expected and normal on HPC nodes.** It does not affect plot generation
or file saving. Ignore it.

### Step 4: Generate and save a plot
> **[Portable]**

In the MATLAB command window:

```matlab
figure;
plot(sin(0:0.1:2*pi));
title('Portal Test');
saveas(gcf, fullfile(getenv('HOME'), 'portal_test.png'));
disp('plot saved');
```

**Expected output:**
```
plot saved
```

### Step 5: Verify the file was saved
> **[Portable]**

From the Expanse Shell Access (a separate portal app) or any shell on Expanse:

```bash
ls -lh ~/portal_test.png
```

**Expected output:**
```
-rw-r--r-- 1 avalafar sds196 20K <date> /home/avalafar/portal_test.png
```

### Step 6: Remember the rule
> **[Portable]**

| Use portal MATLAB for | Do NOT use portal MATLAB for |
|---|---|
| Inspecting results | Training neural networks |
| Plotting and debugging | High-frequency I/O |
| Interactive data exploration | Long-running jobs |

For compute and I/O-intensive work, use `sbatch` (M2–M4).

## Pass/Fail Check

- ✅ **PASS:** `ls -lh ~/portal_test.png` shows a non-zero file size
- ❌ **FAIL — session won't start:** Check `squeue -u $USER` from shell; the node may be busy
- ❌ **FAIL — file not saved:** Confirm `getenv('HOME')` returns your home path with `disp(getenv('HOME'))` before saving
