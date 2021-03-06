.PHONY: all clean bootstrap calccore_host
all: bootstrap calccore_host

bootstrap: bootstrap-complete
bootstrap-complete: bootstrap.sh
	./bootstrap.sh

clean:
	rm -f bootstrap-complete
	rm -rf buildtmp
	rm -rf extlib
	rm -rf hostlib

calccore_host:
	$(MAKE) -C calccore TARGET=host
