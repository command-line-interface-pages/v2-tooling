SHELL=/bin/sh

# PREFIX: sets the installation prefix
PREFIX?=/home/$(USER)/.local/bin

script=md-to-clip
input_config=placeholders
output_config=.md-to-clip

man_name=$(script).1
man_directory=/usr/local/man/man1

download_url=https://raw.githubusercontent.com/command-line-interface-pages/v2-tooling/main/md-to-clip

define __install
	@echo "\e[32m- Installing script from $(1) to $(PREFIX)...\e[0m"
	@cp -nv "$(1)/$(script).sh" "$(PREFIX)/$(script)"
	@cp -nv "$(1)/$(input_config).yaml" "$(HOME)/$(output_config).yaml"
	@chmod +x "$(PREFIX)/$(script)"
	@echo "\e[32m- Installing man page from $(1) to $(PREFIX)...\e[0m"
	@pandoc "$(1)/$(man_name).md" -s -t man -o "$(man_name)"
	@sudo mkdir -pv "$(man_directory)"
	@sudo cp -v "$(man_name)" "$(man_directory)"
	@sudo gzip "$(man_directory)/$(man_name)"
	@rm "$(1)/$(man_name)"
endef

.PHONY: install
install:
	$(call __install,.)

.PHONY: uninstall
uninstall:
	@echo "\e[31m- Uninstalling script from $(PREFIX)...\e[0m"
	@rm -vf "$(PREFIX)/$(script)"
	@echo "\e[31m- Uninstalling man page from $(PREFIX)...\e[0m"
	@rm -vf "$(HOME)/$(output_config)"
	@sudo rm -vf "$(man_directory)/$(man_name).gz"

.PHONY: reinstall
reinstall: uninstall install

.PHONY: tests
tests:
	@echo "\e[33m- Running all tests...\e[0m"
	@bats --print-output-on-failure $(shell find ./tests/ -type f -name '*.bats')

.PHONY: remote-install
remote-install:
	@echo "\e[34m- Downloading files...\e[0m"
	$(eval download_directory := $(shell mktemp -d))
	@wget -nv -P "$(download_directory)" "$(download_url)/$(script).sh" \
		"$(download_url)/$(input_config).yaml" \
		"$(download_url)/$(man_name).md"
	$(call __install,$(download_directory))

.PHONY: remote-reinstall
remote-reinstall: uninstall remote-install
