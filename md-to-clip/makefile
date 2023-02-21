# PREFIX: sets the installation prefix
PREFIX?=/home/$(USER)/.local/bin

script=md-to-clip
input_config=placeholders.yaml
output_config=.md-to-clip.yaml
man_name=$(script).1
man_directory=/usr/local/man/man1

.PHONY: install
install:
	cp -nv ./$(script).sh $(PREFIX)/$(script)
	cp -nv ./$(input_config) $(HOME)/$(output_config)
	chmod +x $(PREFIX)/$(script)

	pandoc ./$(man_name).md -s -t man -o $(man_name)
	sudo mkdir -pv $(man_directory)
	sudo cp -v $(man_name) $(man_directory)
	sudo gzip $(man_directory)/$(man_name)
	rm ./$(man_name)

.PHONY: uninstall
uninstall:
	rm -v $(PREFIX)/$(script)
	rm -v $(HOME)/$(output_config)
	sudo rm -v $(man_directory)/$(man_name).gz

.PHONY: reinstall
reinstall: uninstall install

.PHONY: tests
tests:
	bats tests.bats
