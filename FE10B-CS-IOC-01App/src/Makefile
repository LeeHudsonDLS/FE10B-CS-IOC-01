TOP=../..

include $(TOP)/configure/CONFIG

USR_CXXFLAGS_DEFAULT += -fno-operator-names
USR_CXXFLAGS_DEFAULT += -pedantic

# ------------------------
# Build an IOC Application
# ------------------------

PROD_IOC = FE10B-CS-IOC-01

# FE10B-CS-IOC-01.dbd will be installed into <top>/dbd
DBD += FE10B-CS-IOC-01.dbd



# FE10B-CS-IOC-01.dbd will be created from these files
FE10B-CS-IOC-01_DBD += base.dbd
FE10B-CS-IOC-01_DBD += calcSupport.dbd
FE10B-CS-IOC-01_DBD += genSubRecord.dbd
FE10B-CS-IOC-01_DBD += drvAsynIPPort.dbd
FE10B-CS-IOC-01_DBD += devIocStats.dbd
FE10B-CS-IOC-01_DBD += ecAsyn.dbd
FE10B-CS-IOC-01_DBD += drvAsynSerialPort.dbd
FE10B-CS-IOC-01_DBD += stream.dbd
FE10B-CS-IOC-01_DBD += FINS.dbd
FE10B-CS-IOC-01_DBD += asynRecord.dbd
FE10B-CS-IOC-01_DBD += as.dbd
FE10B-CS-IOC-01_DBD += busySupport.dbd
FE10B-CS-IOC-01_DBD += FERegistrar.dbd
FE10B-CS-IOC-01_DBD += blcon_state_machine.dbd

# FE10B-CS-IOC-01_registerRecordDeviceDriver.cpp will be created
# FE10B-CS-IOC-01.dbd
FE10B-CS-IOC-01_SRCS += FE10B-CS-IOC-01_registerRecordDeviceDriver.cpp

# These two lines are needed for non-vxWorks builds, such as Linux
FE10B-CS-IOC-01_SRCS_DEFAULT += FE10B-CS-IOC-01Main.cpp
FE10B-CS-IOC-01_SRCS_vxWorks += -nil-

# Add locally compiled object code
#FE10B-CS-IOC-01_SRCS +=

# The following adds object code from base/src/vxWorks
FE10B-CS-IOC-01_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# This line says that this IOC Application depends on the
# xxx Support Module
FE10B-CS-IOC-01_LIBS += ecAsyn
FE10B-CS-IOC-01_LIBS += devIocStats
FE10B-CS-IOC-01_LIBS += FINS
FE10B-CS-IOC-01_LIBS += calc
FE10B-CS-IOC-01_LIBS += genSub
FE10B-CS-IOC-01_LIBS += sscan
FE10B-CS-IOC-01_LIBS += asyn
FE10B-CS-IOC-01_LIBS += FELib
FE10B-CS-IOC-01_LIBS += pv
FE10B-CS-IOC-01_LIBS += seq
FE10B-CS-IOC-01_LIBS += stream
FE10B-CS-IOC-01_LIBS += autosave
FE10B-CS-IOC-01_LIBS += busy
FE10B-CS-IOC-01_LIBS += pcre

ifneq ($(SNCSEQ),)
    # This builds sncExample as a component of SR12I-CS-IOC-01
    FE10B-CS-IOC-01_SNCFLAGS += +r
    FE10B-CS-IOC-01_SRCS += blcon_state_machine.st
    FE10B-CS-IOC-01_LIBS += seq pv
endif

# We need to link this IOC Application against the EPICS Base libraries
FE10B-CS-IOC-01_LIBS += $(EPICS_BASE_IOC_LIBS)

# ---------------------------------------------------

include $(TOP)/configure/RULES
