VERSION=0.1

MAKE ?= make
BUILDDIR ?= .
SRCDIR ?= .
LIBDIR ?= /usr/lib
DESTDIR ?=

.PHONY: all
all: vendor build

.PHONY: vendor
vendor:
	go mod vendor

.PHONY: build
build:
	GOFLAGS="-mod=vendor" CGO_ENABLED=0 go build -ldflags="-s -w" -trimpath -o initrd initrd.go

.PHONY: install
install:
	install -D -m 0755 initrd $(DESTDIR)$(LIBDIR)/osbuild/initrd/initrd

.PHONY: dist
dist: vendor
	mkdir -p osbuild-initrd-$(VERSION)
	git archive HEAD | tar -x -C osbuild-initrd-$(VERSION)
	cp -r vendor osbuild-initrd-$(VERSION)/
	tar -czf osbuild-initrd-$(VERSION).tar.gz osbuild-initrd-$(VERSION)
	rm -rf osbuild-initrd-$(VERSION)

.PHONY: distcheck
distcheck: dist
	rm -rf distcheck-$(VERSION)
	mkdir -p distcheck-$(VERSION)
	tar -xzf osbuild-initrd-$(VERSION).tar.gz -C distcheck-$(VERSION)
	$(MAKE) -C distcheck-$(VERSION)/osbuild-initrd-$(VERSION) build
	$(MAKE) -C distcheck-$(VERSION)/osbuild-initrd-$(VERSION) install DESTDIR=$(CURDIR)/distcheck-$(VERSION)/install
	test -f distcheck-$(VERSION)/install$(LIBDIR)/osbuild/initrd/initrd
	rm -rf distcheck-$(VERSION)
	@echo "distcheck passed"
