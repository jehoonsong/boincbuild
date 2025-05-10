all: 
	nohup sh run.sh 2>&1 | tee run.log  

clean:
	rm -rf INPUT.tgz OUTPUT.tgz gromacs fraction_done
	rm -rf em.* protein.pdb step*.pdb
	rm -rf ions.*
	rm -rf npt.*
	rm -rf nvt.*
	rm -rf posre.*
	rm -rf solv.*
	rm -rf topol.*
	rm -rf *.gro
	rm -rf *.itp
	rm -rf *.top
	rm -rf *.cpt
	rm -rf *.xtc
	rm -rf *.edr md.log *.log
	rm -rf *.mdp *.tpr *.trr *.xvg *.ndx *.gp *.png make_ndx.input
	rm -f \#*  
