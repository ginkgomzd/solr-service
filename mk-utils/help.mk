# # #
# Define a target called, help.
#
# Tries really hard to find text to output. Provides an (un)helpful default message.
#
# Override the file that will be output by setting the variable, README.
# Uses README.md, or README, by default.
# If Pandoc is available, will convert Markdown to Plain Text.
# 
# Provide HELP_TEXT as a variable if you do not want to use text from a file.
#
# # #

CACHED_DG := ${.DEFAULT_GOAL}# don't mess with defualt goal

README ?= README
HELP_FILE = $(or $(wildcard ${README}.md),$(wildcard ${README}))
HELP_FILE := $(or ${HELP_FILE},NOFILE)# because empty will cause erroneous checks later.

pandoc != command -v pandoc 2>/dev/null

# Un-set pandoc if README is not a markdown file.
ifneq (.md,$(findstring .md,${HELP_FILE}))
pandoc := 
endif

# Nota Bene:
# compound-conditionals( $(and ...) ) achieved by detecting false as an empty-string
# So, true is not-equal to empty:
#
help:
ifdef HELP_TEXT
	@ $(info ${HELP_TEXT})
else ifneq (,$(and ${pandoc},$(wildcard ${HELP_FILE})))	# we can use pandoc and the file exists
	@ pandoc -f markdown -t plain ${HELP_FILE}
else ifeq (${HELP_FILE},$(wildcard ${HELP_FILE}))	# a file is configured and exists
	@ cat ${HELP_FILE}
else
	$(info Use the source, Luke.)			# we tried our best, sorry
endif

.DEFAULT_GOAL := ${CACHED_DG}

