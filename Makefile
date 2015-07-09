# Cluster options
Cluster_Name = master
Cluster_GNode = gnode70
Cluster_Node = node10
Cluster_Nb_Nodes = 01
Cluster_ppn = 1
Cluster_Id_Computation = 40
Cluster_walltime = 300:00:00
Cluster_pvmem = 31gb
Cluster_pvmem_bigmem = 63gb
Cluster_List_Gnodes = 70 71 72 73 74 75 76 77 78
# Cluster_Reseau = IB (Infiniband), TCP (Ethernet)
Cluster_Reseau = TCP
Script_Name = launch_make
# Node_Dir
Node_Dir = /usrtmp/$(USER)
# Cluster_Dir = /data1/$(USER), /data2/$(USER), /nutmp/$(Cluster_Node)/$(USER)
Cluster_Dir  = /data1/$(USER)
Cluster_List_Data = 1 2 3 4 5 6
# LMT_Dir, METIL_Dir, DIC_Dir
ERROR_ESTIMATION_Dir   = https://github.com/fpled/ERROR_ESTIMATION.git
LMT_Dir   = git://gitosis.lmt.ens-cachan.fr/LMTpp-test.git
METIL_Dir = git://gitosis.lmt.ens-cachan.fr/METIL.git
DIC_Dir = git://gitosis.lmt.ens-cachan.fr/dic.git
qsub_Dir = /usr/local/torque-current/bin/
scons_file = SConstruct
scons_file_PGD = SConstruct_PGD
# Options for the compilation
debug = 0 
opt = 0
timdavis = 0
nb_pro = 8
machine_arch = ''
# Name of machine
List_Machine_Names = pommard chablis
Machine_Name = pommard
Machine_Name_Results = pommard
# Name of station
Station_Name = stationmeca18
# Name of problem
Pb_Name = error_estimation
Pb_Name_Space = space
Pb_Name_Parameter = parameter

# Default ---------------------------
default:
# 	export METILPATH=../METIL/MET; ../METIL-install/bin/metil formulation.met
	cd LMT/include/codegen; scons -j 1
	scons --sconstruct=$(scons_file) -j $(nb_pro) arch=$(machine_arch) debug=$(debug) opt=$(opt) timdavis=$(timdavis)
	time ./main
	
PGD:
# 	export METILPATH=../METIL/MET; ../METIL-install/bin/metil formulation_PGD.met
	cd LMT/include/codegen; scons -j 1
	scons --sconstruct=$(scons_file_PGD) -j $(nb_pro) arch=$(machine_arch) debug=$(debug) opt=$(opt) timdavis=$(timdavis)
	time ./main_PGD

# Codegen ---------------------------
codegen:
	cd LMT/include/codegen; scons -j 1

# Codegen_Cluster ---------------------------
codegen_cluster:
	ssh $(Cluster_Name) "cd $(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/; make codegen"

# Compile ---------------------------
compile:
# 	export METILPATH=../METIL/MET; ../METIL-install/bin/metil formulation.met
	cd LMT/include/codegen; scons -j 1
	scons --sconstruct=$(scons_file) -j $(nb_pro) arch=$(machine_arch) debug=$(debug) opt=$(opt) timdavis=$(timdavis)

compile_PGD:
# 	export METILPATH=../METIL/MET; ../METIL-install/bin/metil formulation_PGD.met
	cd LMT/include/codegen; scons -j 1
	scons --sconstruct=$(scons_file_PGD) -j $(nb_pro) arch=$(machine_arch) debug=$(debug) opt=$(opt) timdavis=$(timdavis)

# Test ---------------------------
test:
	export METILPATH=../METIL/MET; ../METIL-install/bin/metil TESTS/Test_metil.met

# Move ---------------------------
move_results:
	-mv *.vtu RESULTS
	-mv *.pvd RESULTS
	-mv *.log RESULTS

# Clean ---------------------------
clean:
	scons -c
	-rm -r build

clean_codegen:
	cd LMT/include/codegen; scons -c

clean_results:
	-rm -r RESULTS/*

clean_all:
	scons -c
	cd LMT/include/codegen; scons -c
	-rm -r build
	-rm -r RESULTS/*
	-rm  ./*.o

clean_generated:
	-rm -r generated

# Clean Cluster---------------------------
clean_cluster:
	ssh $(Cluster_Name) "cd $(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/; make clean"

clean_codegen_cluster:
	ssh $(Cluster_Name) "cd $(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/; make clean_codegen"

clean_all_cluster:
	ssh $(Cluster_Name) "cd $(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/; make clean_all"

# Clean GNode---------------------------
clean_gnode:
	ssh $(Cluster_GNode) "cd $(Node_Dir)/ERROR_ESTIMATION/; make clean"

clean_codegen_gnode:
	ssh $(Cluster_Gnode) "cd $(Node_Dir)/ERROR_ESTIMATION/; make clean_codegen"

clean_all_gnode:
	ssh $(Cluster_GNode) "cd $(Node_Dir)/ERROR_ESTIMATION/; make clean_all"

# Gdb ---------------------------
debug_gdb:
	gdb --args make

# LMT ---------------------------
clone_LMT:
	-git clone $(LMT_Dir) ../LMTpp

# Metil ---------------------------
clone_METIL:
	-rm -fr ../METIL
	-rm -fr ../METIL-build
	-rm -fr ../METIL-install
	-git clone $(METIL_Dir) ../METIL
	mkdir ../METIL-build; cd ../METIL-build; cmake -i ../METIL

install_METIL:
	cd ../METIL-build; make -j4 install

# excludes for rsync
exclude = --exclude '*.o' --exclude 'core' --exclude '*.log' --exclude '*.eps' --exclude '*.dvi' --exclude '*.pdf' --exclude '*.tex' --exclude '*.aux' --exclude '*.patch' --exclude '*.kdevelop' --exclude '*.kdev4' --exclude '*.filelist' --exclude '*.pcs' --exclude '*.kdevses' --exclude '*.m' --exclude '*.pyc' --exclude '*.cc' --exclude '*.bz2' --exclude '*.cache' --exclude '*.dblite' --exclude '*.git' --exclude '.sconsign' --exclude 'LMT/.git' --exclude 'Doxyfile' --exclude 'build' --exclude 'TESTS' --exclude 'RESULTS' --exclude 'i686.tok'
exclude_main_formulation = --exclude 'main.cpp' --exclude 'formulation.met'
exclude_Makefile = --exclude 'Makefile'
exclude_LMT = --exclude '*.o' --exclude '*.patch' --exclude '*.git' --exclude 'i686.tok' --exclude '*.cache'
exclude_METIL = --exclude '*.patch' --exclude '*.git' --exclude 'i686.tok' --exclude '*.cache' --exclude '*.bz2'
exclude_generated = --exclude 'i686.tok'

# Station ---------------------------

all_to_station:
	rsync -auv ../LMTpp        $(Station_Name): $(exclude_LMT)
	rsync -auv ../METIL      $(Station_Name): $(exclude_METIL)
	rsync -auv ../ERROR_ESTIMATION     $(Station_Name): $(exclude)
# 	rsync -auv ../ERROR_ESTIMATION/main.cpp     $(Cluster_GNode):$(Node_Dir)/ERROR_ESTIMATION
	ssh $(Station_Name) "cd ~/ERROR_ESTIMATION/; rm -fr LMT"
	ssh $(Station_Name) "cd ~/ERROR_ESTIMATION/; ln -s ../LMTpp LMT"

LMT_to_station:
	rsync -auv ../LMTpp        $(Station_Name): $(exclude_LMT)

METIL_to_station:
	rsync -auv ../METIL        $(Station_Name): $(exclude_METIL)

EE_to_station:
	rsync -auv ../ERROR_ESTIMATION     $(Station_Name): $(exclude)
	ssh $(Station_Name) "cd ~/ERROR_ESTIMATION/; rm -fr LMT"
	ssh $(Station_Name) "cd ~/ERROR_ESTIMATION/; ln -s ../LMTpp LMT"

generated_to_station:
	rsync -auv ../ERROR_ESTIMATION/generated     $(Station_Name):~/ERROR_ESTIMATION $(exclude_generated)

main_to_station:
	rsync -auv ../ERROR_ESTIMATION/main.cpp     $(Station_Name):~/ERROR_ESTIMATION

formulation_to_station:
	rsync -auv ../ERROR_ESTIMATION/formulation.met     $(Station_Name):~/ERROR_ESTIMATION

install_METIL_on_station:
	ssh $(Station_Name) "cd ~/METIL-build; make -j4 install"

# Machine ---------------------------

LMT_to_all_machines:
	$(foreach i, $(List_Machine_Names), \
	rsync -auv /utmp/$(Machine_Name)/$(USER)/LMTpp        $(i):$(Node_Dir) $(exclude_LMT);)

METIL_to_all_machines:
	$(foreach i, $(List_Machine_Names), \
	rsync -auv /utmp/$(Machine_Name)/$(USER)/METIL      $(i):$(Node_Dir) $(exclude_METIL);)

EE_to_all_machines:
	$(foreach i, $(List_Machine_Names), \
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION        $(i):$(Node_Dir) $(exclude); \
	ssh $(i) "cd $(Node_Dir)/ERROR_ESTIMATION/; rm -fr LMT"; \
	ssh $(i) "cd $(Node_Dir)/ERROR_ESTIMATION/; ln -s $(Node_Dir)/LMTpp LMT";)

main_to_all_machines:
	$(foreach i, $(List_Machine_Names), \
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/main.cpp     $(i):$(Node_Dir)/ERROR_ESTIMATION;)

formulation_to_all_machines:
	$(foreach i, $(List_Machine_Names), \
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/formulation.met     $(i):$(Node_Dir)/ERROR_ESTIMATION;)

install_METIL_on_all_machines:
	$(foreach i, $(List_Machine_Names), \
	ssh $(i) "cd $(Node_Dir)/METIL-build/; make -j4 install";)

# Cluster ---------------------------

all_to_cluster:
	rsync -auv /utmp/$(Machine_Name)/$(USER)/LMTpp        $(Cluster_Name):$(Cluster_Dir) $(exclude_LMT)
	rsync -auv /utmp/$(Machine_Name)/$(USER)/METIL      $(Cluster_Name):$(Cluster_Dir) $(exclude_METIL)
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/*     $(Cluster_Name):$(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation) $(exclude) $(exclude_main_formulation)
# 	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/main.cpp     $(Cluster_Name):$(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation) $(exclude) $(exclude_main_formulation)
# 	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/$(Script_Name)     $(Cluster_Name):$(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation) $(exclude) $(exclude_main_formulation)
	ssh $(Cluster_Name) "cd $(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/; rm -fr LMT"
	ssh $(Cluster_Name) "cd $(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/; ln -s $(Cluster_Dir)/LMTpp LMT"
#	ssh $(Cluster_Name) "mv $(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/$(Script_Name) ./"

all_cluster: all_to_cluster
# 	ssh $(Cluster_Name) 'rsh $(Cluster_Node) "hostname; cd $(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation); make"'
	ssh $(Cluster_Name) "hostname; $(qsub_Dir)/qsub -k eo -l nodes=$(Cluster_Nb_Nodes):ppn=$(Cluster_ppn):$(Cluster_Reseau),walltime=$(Cluster_walltime),pvmem=$(Cluster_pvmem) -v REP='$(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/' $(Script_Name)"
#	ssh $(Cluster_Name) "hostname; $(qsub_Dir)/qsub -k eo -q bigmem -l walltime=$(Cluster_walltime),pvmem=$(Cluster_pvmem_bigmem) -v REP='$(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/' $(Script_Name)"

LMT_to_cluster:
	rsync -auv /utmp/$(Machine_Name)/$(USER)/LMTpp        $(Cluster_Name):$(Cluster_Dir) $(exclude_LMT)

LMT_to_all_cluster:
	$(foreach i, $(Cluster_List_Data), \
	rsync -auv /utmp/$(Machine_Name)/$(USER)/LMTpp        $(Cluster_Name):/data$(i)/$(USER) $(exclude_LMT);)

METIL_to_cluster:
	rsync -auv /utmp/$(Machine_Name)/$(USER)/METIL      $(Cluster_Name):$(Cluster_Dir) $(exclude_METIL)

METIL_to_all_cluster:
	$(foreach i, $(Cluster_List_Data), \
	rsync -auv /utmp/$(Machine_Name)/$(USER)/METIL        $(Cluster_Name):/data$(i)/$(USER) $(exclude_METIL);)

install_METIL_on_cluster:
	ssh $(Cluster_GNode) "cd $(Cluster_Dir)/METIL-build; make -j4 install"

install_METIL_on_all_cluster:
	$(foreach i, $(Cluster_List_Data), \
	ssh $(Cluster_GNode) "cd /data$(i)/$(USER)/METIL-build; make -j4 install";)

EE_to_cluster:
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/*     $(Cluster_Name):$(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/ $(exclude)
	ssh $(Cluster_Name) "cd $(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/; rm -fr LMT"
	ssh $(Cluster_Name) "cd $(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/; ln -s $(Cluster_Dir)/LMTpp LMT"

generated_to_cluster:
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/generated     $(Cluster_Name):$(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation) $(exclude_generated)

main_to_cluster:
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/main.cpp     $(Cluster_Name):$(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)

formulation_to_cluster:
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/formulation.met     $(Cluster_Name):$(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)

cluster:
	ssh $(Cluster_Name) "hostname; $(qsub_Dir)/qsub -k eo -l nodes=$(Cluster_Nb_Nodes):ppn=$(Cluster_ppn):$(Cluster_Reseau),walltime=$(Cluster_walltime),pvmem=$(Cluster_pvmem) -v REP='$(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/' $(Script_Name)"

cluster_node:
	ssh $(Cluster_Name) "hostname; $(qsub_Dir)/qsub -k eo -l host=$(Cluster_Node):ppn=$(Cluster_ppn):$(Cluster_Reseau),walltime=$(Cluster_walltime),pvmem=$(Cluster_pvmem) -v REP='$(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/' $(Script_Name)"

cluster_bigmem:
	ssh $(Cluster_Name) "hostname; $(qsub_Dir)/qsub -k eo -q bigmem -l walltime=$(Cluster_walltime),pvmem=$(Cluster_pvmem_bigmem) -v REP='$(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/' $(Script_Name)"

results_from_cluster:
	rsync -auv $(Cluster_Name):$(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/*.vtu  /utmp/$(Machine_Name_Results)/$(USER)/RESULTS
	rsync -auv $(Cluster_Name):/u/$(USER)/*.out  /utmp/$(Machine_Name_Results)/$(USER)/RESULTS

# GNode ---------------------------

all_to_gnode:
	rsync -auv /utmp/$(Machine_Name)/$(USER)/LMTpp        $(Cluster_GNode):$(Node_Dir) $(exclude_LMT)
	rsync -auv /utmp/$(Machine_Name)/$(USER)/METIL      $(Cluster_GNode):$(Node_Dir) $(exclude_METIL)
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION     $(Cluster_GNode):$(Node_Dir) $(exclude) $(exclude_main_formulation)
# 	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/main.cpp     $(Cluster_GNode):$(Node_Dir)/ERROR_ESTIMATION
	ssh $(Cluster_GNode) "cd $(Node_Dir)/ERROR_ESTIMATION/; rm -fr LMT"
	ssh $(Cluster_GNode) "cd $(Node_Dir)/ERROR_ESTIMATION/; ln -s $(Node_Dir)/LMTpp LMT"

all_gnode: all_to_gnode
	ssh $(Cluster_GNode) "hostname; cd $(Node_Dir)/ERROR_ESTIMATION; make"

LMT_to_gnode:
	rsync -auv /utmp/$(Machine_Name)/$(USER)/LMTpp        $(Cluster_GNode):$(Node_Dir) $(exclude_LMT)

LMT_to_all_gnodes:
	$(foreach i, $(Cluster_List_Gnodes), \
	rsync -auv /utmp/$(Machine_Name)/$(USER)/LMTpp        gnode$(i):$(Node_Dir) $(exclude_LMT);)	

METIL_to_gnode:
	rsync -auv /utmp/$(Machine_Name)/$(USER)/METIL      $(Cluster_GNode):$(Node_Dir) $(exclude_METIL)

METIL_to_all_gnodes:
	$(foreach i, $(Cluster_List_Gnodes), \
	rsync -auv /utmp/$(Machine_Name)/$(USER)/METIL      gnode$(i):$(Node_Dir) $(exclude_METIL);)

install_METIL_on_gnode:
	ssh $(Cluster_GNode) "cd $(Node_Dir)/METIL-build; make -j4 install"

install_METIL_on_all_gnodes:
	$(foreach i, $(Cluster_List_Gnodes), \
	ssh gnode$(i) "cd $(Node_Dir)/METIL-build; make -j4 install";)

EE_to_gnode:
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION     $(Cluster_GNode):$(Node_Dir) $(exclude) $(exclude_main_formulation)
	ssh $(Cluster_GNode) "cd $(Node_Dir)/ERROR_ESTIMATION/; rm -fr LMT"
	ssh $(Cluster_GNode) "cd $(Node_Dir)/ERROR_ESTIMATION/; ln -s $(Node_Dir)/LMTpp LMT"

EE_to_all_gnodes:
	$(foreach i, $(Cluster_List_Gnodes), \
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION     gnode$(i):$(Node_Dir) $(exclude) $(exclude_main_formulation); \
	ssh gnode$(i) "cd $(Node_Dir)/ERROR_ESTIMATION/; rm -fr LMT"; \
	ssh gnode$(i) "cd $(Node_Dir)/ERROR_ESTIMATION/; ln -s $(Node_Dir)/LMTpp LMT";)

generated_to_gnode:
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/generated     $(Cluster_GNode):$(Node_Dir)/ERROR_ESTIMATION $(exclude_generated)

generated_to_all_gnodes:
	$(foreach i, $(Cluster_List_Gnodes), \
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/generated     gnode$(i):$(Node_Dir)/ERROR_ESTIMATION $(exclude_generated);)

SConstruct_to_gnode:
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/SConstruct     $(Cluster_GNode):$(Node_Dir)/ERROR_ESTIMATION

SConstruct_to_all_gnodes:
	$(foreach i, $(Cluster_List_Gnodes), \
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/SConstruct     gnode$(i):$(Node_Dir)/ERROR_ESTIMATION;)

main_to_gnode:
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/main.cpp     $(Cluster_GNode):$(Node_Dir)/ERROR_ESTIMATION

main_to_all_gnodes:
	$(foreach i, $(Cluster_List_Gnodes), \
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/main.cpp     gnode$(i):$(Node_Dir)/ERROR_ESTIMATION;)

formulation_to_gnode:
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/formulation.met     $(Cluster_GNode):$(Node_Dir)/ERROR_ESTIMATION

formulation_to_all_gnodes:
	$(foreach i, $(Cluster_List_Gnodes), \
	rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/formulation.met     gnode$(i):$(Node_Dir)/ERROR_ESTIMATION;)

gnode:
	ssh $(Cluster_GNode) "hostname; cd $(Node_Dir)/ERROR_ESTIMATION; make"

results_from_gnode:
	rsync -auv $(Cluster_GNode):$(Node_Dir)/ERROR_ESTIMATION/*.vtu  /utmp/$(Machine_Name_Results)/$(USER)/RESULTS/
	rsync -auv $(Cluster_GNode):$(Node_Dir)/ERROR_ESTIMATION/*.pvd  /utmp/$(Machine_Name_Results)/$(USER)/RESULTS/
	rsync -auv $(Cluster_GNode):$(Node_Dir)/ERROR_ESTIMATION/*.log  /utmp/$(Machine_Name_Results)/$(USER)/RESULTS/
# 	scp $(Cluster_GNode):$(Node_Dir)/ERROR_ESTIMATION/*.vtu  /utmp/$(Machine_Name_Results)/$(USER)/RESULTS/
# 	scp $(Cluster_GNode):$(Node_Dir)/ERROR_ESTIMATION/*.pvd  /utmp/$(Machine_Name_Results)/$(USER)/RESULTS/
# 	scp $(Cluster_GNode):$(Node_Dir)/ERROR_ESTIMATION/*.log  /utmp/$(Machine_Name_Results)/$(USER)/RESULTS/

# Copy ---------------------------

copy_to_gnode:
    rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/main.cpp     $(Cluster_GNode):$(Node_Dir)/ERROR_ESTIMATION/ $(exclude)

copy_to_cluster:
    rsync -auv /utmp/$(Machine_Name)/$(USER)/ERROR_ESTIMATION/main.cpp     $(Cluster_Name):$(Cluster_Dir)/ERROR_ESTIMATION_$(Cluster_Id_Computation)/ $(exclude)
