# dvcs_simulation

## Overview

A Python-based event generator for Deeply Virtual Compton Scattering (DVCS) simulations, supporting multiple models:

- **KM15**
- **VGG**
- **BH**: pure Bethe-Heitler process

## Installation

```bash
git clone https://github.com/tbhayward/dvcs_simulation.git
cd dvcs_simulation
chmod +x install.sh
./install.sh
```

## Command-Line Options

### Core Parameters

| Option    	| Description                           | Default  |
|---------------|---------------------------------------|----------|
| `--beam`  	| Beam energy in GeV                    | 10.604   |
| `--model` 	| Physics model (`km15`, `vgg`, `bh`)   | km15     |
| `--nentries`  | Number of events to generate          | 1        |
| `--fname` 	| Output filename prefix                | output   |

### Kinematic Ranges

| Option     | Description              | Default | Range      |
|------------|--------------------------|---------|------------|
| `--xBmin`  | Minimum $x_B$            | 0.05    | 0.001–0.99 |
| `--xBmax`  | Maximum $x_B$            | 0.75    | 0.001–0.99 |
| `--Q2min`  | Minimum $Q^2$ (GeV²)     | 0.9     | 0.1–15     |
| `--Q2max`  | Maximum $Q^2$ (GeV²)     | 11.0    | 0.1–15     |
| `--tmin`   | Minimum $t$ (GeV²)       | 0.085   | 0.01–2.0   |
| `--tmax`   | Maximum $t$ (GeV²)       | 1.79    | 0.01–2.0   |
| `--ymin`   | Minimum $y$ 		        | 0.19	  | 0-1        |
| `--ymax`   | Maximum $y$ 	            | 0.85    | 0-1        |
| `--w2min`  | Minimum $W^2$ (GeV²)     | 3.61    |  		   |


### Advanced Options

| Option      | Description                                  |
|-------------|----------------------------------------------|
| `--seed`    | Set predefined seed (0 = automatic)          |

... Several additional advanced options if you are willing to bravely venture deep into the dvcsgen installation.

## Usage Examples

### Basic KM15 Generation

```bash
python main.py --model km15 --nentries 1000 --fname km15_test
```

### Basic VGG Generation

```bash
python main.py --model vgg --nentries 1000 --fname vgg_test
```

### Basic BH Generation

```bash
python main.py --model bh --nentries 1000 --fname bh_test
```

### Limited KM15 kinematic range and non-default beam energy

```bash
python main.py --model km15 --nentries 1000 --fname km15_test --Q2min 2 --Q2max 3 --beam 6.5
```

## Output Files

- `<fname>.dat`: Generated events in CLAS12 Lund format.
- Automatic handling of temporary files from **dvcsgen**.

## Dependencies

- Python 3.6+
- Cython
- NumPy
- SciPy
- Gepard (for VGG/BH models)
- CLAS12 environment (via `module load clas12`)

## Troubleshooting

**Q:** Getting `test.1.dat` instead of `test.dat`?  
**A:** The code automatically renames files. Temporary files from **dvcsgen** will be cleaned up.

**Q:** Installation fails with Cython errors?  
**A:** Ensure you have Cython installed:
```bash
pip3 install --user cython
```
**Q:** `dvcsgen` not found?  
**A:** Run `source ~/.bashrc` after installation and/or verify that the `CLASDVCS_PDF` environment variable is set.



## plot_kinematics.py

**Description**:  
`plot_kinematics.py` is a utility script to visualize and analyze the kinematics of the generated DVCS events. It reads the output Lund file (e.g., `*.dat`) generated by this event generator and produces a set of histograms for electron, proton and photon momenta, as well as common DIS variables such as y, Q², W, x<sub>B</sub>, and t. This helps in quickly diagnosing the event distributions and ensuring the generated data aligns with expected physics ranges.

**Usage Examples**:  
To plot a single file:
```bash
python plot_kinematics.py myevents.dat --beam-energy 10.2
```
Here, `myevents.dat` is the Lund-format file to analyze, and `--beam-energy` (or `-b`) can be used to specify a beam energy different from the default of 10.604 GeV.

To plot two files with custom legend labels:
```bash
python plot_kinematics.py file1.dat file2.dat -b 10.604 -l "Model A" "Model B"
```

To plot three files with custom legend labels:
```bash
python plot_kinematics.py file1.dat file2.dat file3.dat -l "Set 1" "Set 2" "Set 3"
```