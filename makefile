.PHONY: install
install:
	cp -nv ./clip-view/clip-view.sh /home/$(USER)/.local/bin/clip-view
	chmod +x /home/$(USER)/.local/bin/clip-view

.PHONY: uninstall
uninstall:
	rm -v /home/$(USER)/.local/bin/clip-view

.PHONY: tests
tests:
	env -C md-to-clip bats tests.bats
