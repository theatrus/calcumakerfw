TOP := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

ifeq ($TARGET,host)
	CC=gcc
	CXX=g++
	LIBPREFIX=$(TOP)/hostlib
else
	CC=gcc
endif
