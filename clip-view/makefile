# PREFIX: sets the installation prefix
PREFIX?=/home/$(USER)/.local/bin

script=clip-view
script-download-url=https://raw.githubusercontent.com/command-line-interface-pages/v2-tooling/main/clip-view/clip-view.sh

.PHONY: install
install:
	cp -nv ./$(script).sh $(PREFIX)/$(script)
	chmod +x $(PREFIX)/$(script)

.PHONY: uninstall
uninstall:
	rm -v $(PREFIX)/$(script)

.PHONY: remote-install
remote-install:
	$(eval download := $(shell mktemp))
	wget -O "$(download)" "$(script-download-url)"
	cp -nv "$(download)" $(PREFIX)/$(script)
	chmod +x $(PREFIX)/$(script)

.PHONY: tests
tests:
	echo No tests available yet.
