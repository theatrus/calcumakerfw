TOP := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

ifeq ($(TARGET),host)
	CC=gcc
	CXX=g++
	LIBPREFIX=$(TOP)/hostlib
	CFLAGS="-Os"
	ENABLE_TESTS=1
else
	CC=$(TOP)/_gcc/bin/arm-none-eabi-gcc
	CXX=$(TOP)/_gcc/bin/arm-none-eabi-g++
	LIBPREFIX=$(TOP)/extlib
	CFLAGS="-nostartfiles -ffunction-sections -fdata-sections --specs=nosys.specs -mcpu=cortex-m4 -Os -mfloat-abi=hard -mfpu=fpv4-sp-d16"
endif

CFLAGS += -I$(LIBPREFIX)/include
LDFLAGS += -L$(LIBPREFIX)/lib

$(info CC=$(CC))
$(info CFLAGS=$(CFLAGS))
