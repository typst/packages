# SPDX-FileCopyrightText: 2024 Olivier Charvin <git@olivier.pfad.fr>
#
# SPDX-License-Identifier: CC0-1.0

dev:
	typst watch --root="." tests/autobreak2.typ

clean:
	find -name '*.pdf' -delete

test-spdx: clean
	reuse lint

XDG_DATA_HOME ?= $(HOME)/.local/share
install:
	@mkdir -p $(XDG_DATA_HOME)/typst/packages/local/songb
	ln -snf "$(PWD)" "$(XDG_DATA_HOME)/typst/packages/local/songb/0.1.0"
