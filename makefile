clip_view_output_path=/home/$(USER)/.local/bin/clip-view

.PHONY: install
install:
	cp -nv ./clip-view/clip-view.sh $(clip_view_output_path)
	chmod +x /home/$(USER)/.local/bin/clip-view

.PHONY: uninstall
uninstall:
	rm -v $(clip_view_output_path)

.PHONY: tests
tests:
	env -C md-to-clip bats tests.bats
