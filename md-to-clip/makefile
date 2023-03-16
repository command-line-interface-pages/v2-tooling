# PREFIX: sets the installation prefix
PREFIX?=/home/$(USER)/.local/bin

script=md-to-clip
input_config=placeholders
output_config=.md-to-clip

man_name=$(script).1
man_directory=/usr/local/man/man1

.PHONY: install
install:
	@echo "\e[32m- Installing script...\e[0m"
	@cp -nv "./$(script).sh" "$(PREFIX)/$(script)"
	@cp -nv "./$(input_config).yaml" "$(HOME)/$(output_config).yaml"
	@chmod +x "$(PREFIX)/$(script)"
	@echo "\e[32m- Installing man page...\e[0m"
	@pandoc "./$(man_name).md" -s -t man -o "$(man_name)"
	@sudo mkdir -pv "$(man_directory)"
	@sudo cp -v "$(man_name)" "$(man_directory)"
	@sudo gzip "$(man_directory)/$(man_name)"
	@rm "./$(man_name)"

.PHONY: uninstall
uninstall:
	@echo "\e[31m- Uninstalling script...\e[0m"
	@rm -vf "$(PREFIX)/$(script)"
	@echo "\e[31m- Uninstalling man page...\e[0m"
	@rm -vf "$(HOME)/$(output_config)"
	@sudo rm -vf "$(man_directory)/$(man_name).gz"

.PHONY: reinstall
reinstall: uninstall install

.PHONY: tests
tests:
	@echo "\e[33m- Running all tests...\e[0m"
	@bats --print-output-on-failure $(shell find ./tests/ -type f -name '*.bats')
