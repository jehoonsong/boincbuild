#!/bin/bash

# NOTE
# simple simulation of insulin with GROMACS
# this is test simulation to check if the system is working


# Function to calculate time difference
calculate_time() {
    local start=$1
    local end=$2
    local diff=$((end - start))
    local hours=$((diff / 3600))
    local minutes=$(( (diff % 3600) / 60 ))
    local seconds=$((diff % 60))
    echo "${hours}h ${minutes}m ${seconds}s"
}

# Record start time
START_TIME=$(date +%s)

NTOMP=$(nproc)

# Common MDP parameters definition 
COMMON_MDP_PARAMS=$(cat << 'EOF'
; Essential common parameters

; Periodic boundary conditions
pbc                 = xyz              ; 3D periodic boundary conditions

; Electrostatics
coulombtype         = PME              ; Particle Mesh Ewald for long-range electrostatics
pme_order           = 4                ; Cubic interpolation
fourierspacing      = 0.16             ; Grid spacing for FFT
rcoulomb            = 1.0              ; Short-range electrostatic cutoff (in nm)
rvdw                = 1.0              ; Short-range van der Waals cutoff (in nm)

; Neighbor searching
cutoff-scheme       = Verlet           ; Verlet cutoff scheme
nstlist             = 10               ; Frequency to update the neighbor list
EOF
)

# Execute only if -j option is given
if [ "$1" == "-j" ]; then
    # Create a working directory name based on the current time
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    WORKDIR="simulation_${TIMESTAMP}"

    # Create the working directory
    mkdir -p $WORKDIR

    # Copy necessary files to the new directory
    cp run_simul1.sh pdbfix1.py pdbfix2.py $WORKDIR/

    # Move to the new directory
    cd $WORKDIR
fi

if [ -f $HOME/.local/gromacs/bin/GMXRC ]; then
    source $HOME/.local/gromacs/bin/GMXRC
fi

#############################################
# STEP 1: Preprocessing
#############################################

input_pdb="AF-Q15047-F1-model_v4.pdb"

echo "=== STEP 1: Starting system preprocessing ==="

# Generating topology

echo "Generating topology..."
if [ ! -f "processed.gro" ]; then
    gmx pdb2gmx -f $input_pdb -o processed.gro -p topol.top -water tip3p -ff charmm27 -nobackup || exit 1
else
    echo "processed.gro already exists. Skipping topology generation."
fi

# Setting box size

echo "Setting box size..."
if [ ! -f "newbox.gro" ]; then
    gmx editconf -f processed.gro -o newbox.gro -c -d 1.5 -bt cubic -nobackup || exit 1
else
    echo "newbox.gro already exists. Skipping box size setting."
fi

# Adding solvent

echo "Adding solvent..."
if [ ! -f "solv.gro" ]; then
    gmx solvate -cp newbox.gro -cs spc216.gro -o solv.gro -p topol.top -nobackup || exit 1
else
    echo "solv.gro already exists. Skipping solvation."
fi

# Creating ions.mdp
cat << EOF > ions.mdp
integrator  = steep
emtol       = 1000.0
emstep      = 0.01
nsteps      = 50000

constraints  = h-bonds
constraint_algorithm = lincs

$COMMON_MDP_PARAMS
EOF

# Adding ions

echo "Adding ions..."

if [ ! -f "solv_ions.gro" ]; then
    gmx grompp -f ions.mdp -c solv.gro -p topol.top -o ions.tpr -maxwarn 2 -nobackup || exit 1
    printf "SOL\n" | gmx genion -s ions.tpr -o solv_ions.gro -p topol.top -pname NA -nname CL -neutral -nobackup || exit 1
else
    echo "solv_ions.gro already exists. Skipping ion addition."
fi

# Energy minimization settings
cat << EOF > em.mdp
integrator   = steep
emtol        = 500.0
emstep       = 0.0001
nsteps       = 100000
nstxout      = 100
nstvout      = 100
nstfout      = 100
nstenergy    = 100
nstlog       = 100
cutoff-scheme = Verlet
nstlist      = 10
coulombtype  = PME
rcoulomb     = 1.2
rvdw         = 1.2
pbc          = xyz
constraints  = h-bonds
constraint_algorithm = lincs
rlist        = 1.2
vdwtype      = Cut-off
rvdw-switch  = 1.0
nstxout-compressed = 100
EOF

echo "Running energy minimization..."

if [ -f "em.gro" ]; then
    echo "em.gro already exists. Skipping energy minimization."
else
    gmx grompp -f em.mdp -c solv_ions.gro -p topol.top -o em.tpr -maxwarn 2 -nobackup || exit 1
    gmx mdrun -v -deffnm em -ntomp $NTOMP -ntmpi 1 -pin on -pinoffset 0 -nobackup || exit 1
fi
# gmx energy -f em.edr -o potential.xvg

#############################################
# STEP 2: NVT Equilibration
#############################################

echo "=== STEP 2: Starting NVT equilibration ==="

# Creating initial index file
echo "Creating initial index file..."
if [ ! -f "index.ndx" ]; then
    printf "q\n" | gmx make_ndx -f em.gro -o index.ndx -nobackup || exit 1
else
    echo "index.ndx already exists. Skipping index file creation."
fi

# Creating NVT settings file
cat << EOF > nvt.mdp
title       = NVT equilibration
define      = -DPOSRES

; Run parameters
integrator  = md
nsteps      = 50000
dt          = 0.002

; Output control
nstxout     = 500
nstvout     = 500
nstenergy   = 500
nstlog      = 500

constraints  = h-bonds
constraint_algorithm = lincs

$COMMON_MDP_PARAMS

; Temperature coupling
tcoupl      = V-rescale
tc-grps     = Protein Non-Protein
tau_t       = 0.1     0.1
ref_t       = 310     310

; Pressure coupling
pcoupl      = no

; Position restraints
continuation = no

; Initial velocities
gen_vel     = yes
gen_temp    = 310
gen_seed    = -1

; Dispersion correction
DispCorr    = EnerPres
EOF

echo "Running NVT equilibration..."
if [ ! -f "nvt.gro" ]; then
    gmx grompp -f nvt.mdp -c em.gro -r em.gro -p topol.top -n index.ndx -o nvt.tpr -maxwarn 2 -nobackup || exit 1
    gmx mdrun -v -deffnm nvt -ntomp $NTOMP -ntmpi 1 -pin on -pinoffset 0 -nobackup || exit 1
else
    echo "nvt.gro already exists. Skipping NVT equilibration."
fi

#############################################
# STEP 3: NPT Equilibration
#############################################

echo "=== STEP 3: Starting NPT equilibration ==="

# Creating NPT settings file
cat << EOF > npt.mdp
title       = NPT equilibration
define      = -DPOSRES

; Run parameters
integrator  = md
nsteps      = 50000
dt          = 0.002

; Output control
nstxout     = 500
nstvout     = 500
nstenergy   = 500
nstlog      = 500

constraints  = h-bonds
constraint_algorithm = lincs

$COMMON_MDP_PARAMS

; Temperature coupling
tcoupl      = V-rescale
tc-grps     = Protein Non-Protein
tau_t       = 0.1     0.1
ref_t       = 310     310

; Pressure coupling
pcoupl      = Parrinello-Rahman
pcoupltype  = isotropic
tau_p       = 2.0
ref_p       = 1.0
compressibility = 4.5e-5
refcoord_scaling = com

; Position restraints
continuation = yes

; Dispersion correction
DispCorr    = EnerPres
EOF

echo "Running NPT equilibration..."
if [ ! -f npt.gro ]; then
    gmx grompp -f npt.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p topol.top -n index.ndx -o npt.tpr -maxwarn 2 -nobackup || exit 1
    gmx mdrun -v -deffnm npt -ntomp $NTOMP -ntmpi 1 -pin on -pinoffset 0 -nobackup || exit 1
else
    echo "npt.gro already exists. Skipping NPT equilibration."
fi

# if [ -f $HOME/.local/gromacs/bin/GMXRC ]; then
# 	    source $HOME/.local/gromacs/bin/GMXRC
# fi

#############################################
# STEP 4: Production Simulation
#############################################

echo "=== STEP 4: Starting production simulation ==="

# Creating simulation settings file
cat << EOF > md.mdp
title       = Production MD simulation

; Run parameters
integrator               = md
nsteps                   = 50000      ; 0.1 ns = 50,000 * 0.002 ps
dt                       = 0.002     ; 2 fs

; Output control
nstxout                  = 50000     ; save coordinates every 100 ps
nstvout                  = 50000     ; save velocities every 100 ps
nstenergy                = 50000     ; save energies every 100 ps
nstlog                   = 50000     ; update log file every 100 ps
nstxout-compressed       = 5000      ; save compressed coordinates every 10 ps
compressed-x-precision   = 1000      ; precision with which to write to the compressed trajectory file

; Bond parameters
continuation            = yes
constraint_algorithm    = lincs
constraints            = h-bonds
lincs_iter             = 1
lincs_order            = 4

; Neighbor searching
cutoff-scheme          = Verlet
nstlist                = 10
rcoulomb               = 1.0
rvdw                   = 1.0

; Electrostatics
coulombtype            = PME
pme_order              = 4
fourierspacing         = 0.16

; Periodic boundary conditions
pbc                    = xyz

; Dispersion correction
DispCorr              = EnerPres

; Velocity generation
gen_vel               = no
EOF

# Running grompp
echo "Running grompp..."
if [ ! -f "md.tpr" ]; then
    gmx grompp -v -f md.mdp -c npt.gro -t npt.cpt -p topol.top -o md.tpr -nobackup
else
    echo "md.tpr already exists. Skipping grompp step."
fi

# Running mdrun
echo "Running mdrun..."
if [ -f "md.cpt" ]; then
    echo "Checkpoint file found. Continuing simulation from checkpoint."
    gmx mdrun -v -deffnm md -cpt 5 -cpi md.cpt -append -ntomp $NTOMP -ntmpi 1 -pin on -pinoffset 0 -nobackup
else
    gmx mdrun -v -deffnm md -ntomp $NTOMP -ntmpi 1 -pin on -pinoffset 0 -nobackup
fi

echo "Simulation has been completed."

# Record end time and calculate duration
END_TIME=$(date +%s)
DURATION=$(calculate_time $START_TIME $END_TIME)
echo "Total simulation time: $DURATION"
