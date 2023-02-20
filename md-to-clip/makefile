# PREFIX: sets the installation prefix
PREFIX?=/home/$(USER)/.local/bin

script=md-to-clip
input_config=placeholders.yaml
output_config=.md-to-clip.yaml

.PHONY: install
install:
	cp -nv ./$(script).sh $(PREFIX)/$(script)
	cp -nv ./$(input_config) $(HOME)/$(output_config)
	chmod +x $(PREFIX)/$(script)

.PHONY: uninstall
uninstall:
	rm -v $(PREFIX)/$(script)
	rm -v $(HOME)/$(output_config)

.PHONY: tests
tests:
	bats tests.bats
