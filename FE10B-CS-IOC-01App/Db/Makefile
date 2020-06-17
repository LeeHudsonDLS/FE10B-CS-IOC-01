TOP=../..
include $(TOP)/configure/CONFIG
.PHONY : build clean
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE

#----------------------------------------------------
#  Optimization of db files using dbst (DEFAULT: NO)
#DB_OPT = YES

DB += FE10B-CS-IOC-01.db


include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

FE10B: ../O.Common/FE10B-CS-IOC-01.db
	/dls_sw/prod/tools/RHEL5/bin/epicsparser.py ../O.Common/FE10B-CS-IOC-01.db -r FE10B -s as > FE10B
	@echo "Installing postprocessor files:... INSTALL_PRODUCT=$(INSTALL_PRODUCT) - INSTALL_DATA=$(INSTALL_DATA)"
	-@$(INSTALL_PRODUCT) -d -m 555 *.req $(INSTALL_DATA)

#FE10B-CS-IOC-01-VM.substitutions: ../build-3.14.xml ../control.vm ../fe.vm
#	ant -DFE=$(FE) -f ../build-3.14.xml
#	mv ../$@ .

buildInstall: FE10B

build : ../FE10B-CS-IOC-01-MASTER.substitutions\
	../FE10B-CS-IOC-01-AI.substitutions\
	../FE10B-CS-IOC-01-PT100.substitutions\
	../FE10B-CS-IOC-01.substitutions\
	../FE10B-CS-IOC-01-VM.substitutions\
	../build.substitutions\
	Makefile

../FE10B-CS-IOC-01-MASTER.substitutions : ../FE10B-CS-IOC-01-MASTER.velocity
	cd ..; velocity FE10B-CS-IOC-01-MASTER.velocity > FE10B-CS-IOC-01-MASTER.substitutions
../FE10B-CS-IOC-01-AI.substitutions : ../FE10B-CS-IOC-01-AI.velocity
	cd ..; velocity FE10B-CS-IOC-01-AI.velocity > FE10B-CS-IOC-01-AI.substitutions
../FE10B-CS-IOC-01-VM.substitutions : ../fe.vm
	cd ..; ant -DFE=$(FE) -f build-3.14.xml

../FE10B-CS-IOC-01.substitutions: ../FE10B-CS-IOC-01-MASTER.substitutions ../FE10B-CS-IOC-01-AI.substitutions ../build.substitutions ../FE10B-CS-IOC-01-VM.substitutions 
	cd ..; cat FE10B-CS-IOC-01-MASTER.substitutions \
	FE10B-CS-IOC-01-AI.substitutions \
	FE10B-CS-IOC-01-VM.substitutions \
	build.substitutions \
	> FE10B-CS-IOC-01.substitutions
	cd ..; rm -f FE10B-CS-IOC-01-MASTER.substitutions FE10B-CS-IOC-01-AI.substitutions

clean::
	rm -f FE10B-CS-IOC-01-MASTER.substitutions
	rm -f FE10B-CS-IOC-01-AI.substitutions
	rm -f FE10B-CS-IOC-01-VM.substitutions
	rm -f FE10B-CS-IOC-01.substitutions

