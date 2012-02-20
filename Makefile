#! /usr/bin/make -f
DESTDIR?=/usr/local
prefix?=${DESTDIR}

# files that need mode 755
SRC_FILES=git-tickets.pl
EXEC_FILES=git-tickets

all:
	@echo "usage: make install"
	@echo "       make uninstall"

install:
	install -d -m 0755 $(prefix)/bin
	install -m 0755 $(SRC_FILES) $(prefix)/bin/$(EXEC_FILES)

uninstall:
	test -d $(prefix)/bin && \
	cd $(prefix)/bin && \
	rm -f $(EXEC_FILES)
