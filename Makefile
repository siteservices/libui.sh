#####
#
#	Makefile - Support for installation
#
#	F Harvell - Sun May 21 17:47:20 EDT 2023
#
#####
#
# This content and associated files as published by siteservices.net, Inc. are
# marked CCO 1.0. Permission is unconditionally granted to anyone with the
# interest, full rights to use, modify, publish, distribute, sublicense, and/or
# sell this content and all associated files. To view a copy of CCO 1.0, visit
# https://creativecommons.org/publicdomain/zero/1.0/.
#
# All content is provided "as is", without warranty of any kind, expressed or
# implied, including but not limited to merchantability, fitness for a
# particular purpose, and noninfringement. In no event shall the authors or
# publishers be liable for any claim, damages, or other liability, whether in an
# action of contract, tort, or otherwise, arising from, out of, or in connection
# with the use of this content or any of the associated files.
#
#####

SHELL?=/bin/zsh

all:

.PHONY: install update verify clean distclean env printenv

install:
	@lib/sh/libui -I "$(COMMONROOT)"

update:
	@lib/sh/libui -u "$(COMMONROOT)"

verify:
	@lib/sh/libui -V "$(COMMONROOT)"

clean distclean::

env printenv::
	@echo "COMMONROOT: '$(COMMONROOT)'"
