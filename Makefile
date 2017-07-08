.PHONY: all clean bootstrap
all: bootstrap

bootstrap: bootstrap-complete
bootstrap-complete: bootstrap.sh
	./bootstrap.sh

clean:
	rm -f bootstrap-complete
	rm -rf buildtmp
	rm -rf extlib
	rm -rf hostlib
