URL ?= https://busybox.net/downloads/busybox-1.32.0.tar.bz2

#ROOT = $(CURDIR)

source/busybox.tar.gz:
	mkdir -p source/busybox
	wget -nc $(URL) -O source/busybox.tar.gz

build/native/busybox: source/busybox.tar.gz
	mkdir -p build/native
	tar -xf source/busybox.tar.gz --strip-components=1 --directory=build/native
	cp .config build/native
	$(MAKE) -C build/native

build/wasm/busybox_unstripped.js: source/busybox.tar.gz
	mkdir -p build/wasm/arch/em
	tar -xf source/busybox.tar.gz --strip-components=1 --directory=build/wasm
	cp .config build/wasm
	echo 'cmd_busybox__ = $$(CC) -o $$@.js -Wl,--start-group -s ERROR_ON_UNDEFINED_SYMBOLS=0 -O2 $(CURDIR)/em-shell.c -include $(CURDIR)/em-shell.h --js-library $(CURDIR)/em-shell.js $$(CFLAGS) $$(CFLAGS_busybox) $$(LDFLAGS) $$(EM_LDFLAGS) $$(EXTRA_LDFLAGS) $$(core-y) $$(libs-y) $$(patsubst %,-l%,$$(subst :, ,$$(LDLIBS))) -Wl,--end-group && cp $$@.js $$@' > build/wasm/arch/em/Makefile
	ln -s $(shell which emcc.py) build/wasm/emgcc
	PATH=$(CURDIR)/build/wasm:$$PATH $(MAKE) -C build/wasm ARCH=em CROSS_COMPILE=em SKIP_STRIP=y
