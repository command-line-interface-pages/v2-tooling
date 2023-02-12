# PREFIX: sets the installation prefix
PREFIX?=/home/$(USER)/.local/bin

.PHONY: install
install:
	cp -nv ./clip-view/clip-view.sh $(PREFIX)/clip-view
	chmod +x $(PREFIX)/clip-view

.PHONY: uninstall
uninstall:
	rm -v $(PREFIX)/clip-view

.PHONY: tests
tests:
	env -C md-to-clip bats tests.bats
