# # #
# Utilities for using and managing environment configuration files.
# This make script is self-contained and can be copied into your project.
#
# TO USE:
# Insert the following at the begining of your Makefile, listing all 
# of your config files:
#
#	CONFIG_INCLUDES = conf/project.conf conf/db.conf
#	include utils/configure-utils.mk
#
# IMPORTANT: each of your config files must have a template file (.tpl).
# Config files must have a .conf file-extension.
#
# To declare defaults for your project, include a .conf file, or include
# another defaults file loaded before the config. 
#
# Example Config File Declaration: 
#	export PROJECT_ROOT ?= /var/www/# comments are used in user-prompts.
# Interactive Prompt: 
#	PROJECT_ROOT ( comments are used in user-prompts. ) = [/var/www/]?
#
# TIP: include a trailing-slash when configuring paths. 
# TIP: terminate paths with a hash/sharp to avoid the error of
# trailing-white-space.
# WARNING: escape spaces in paths in your config-include list. 
#
# FEATURES:
# Includes the files in the CONFIG_INCLUDES list.
#
# Set AUTO_INCLUDE_CONFS instead of CONFIG_INCLUDES to include files that 
# have a .tpl file in conf/. 
# If the files conf/project.tpl, conf/db.tpl exist:
# CONFIG_INCLUDES will contain conf/project.conf conf/db.conf
#
# e.g. AUTO_INCLUDE_CONFS = true 
# i.e. empty is false 
#
# Provides an implicit recipe for %.conf files. This causes missing
# configuration files to be automatically (and interactively) generated.
#
# Generating or updating `.conf` files requires a `.tpl` file. When an included
# conf file does not exist, the make rule for `%.conf` is used to generate it
# from the `.tpl` file. If a variable is defined in the environment, the value
# will be offered as the default.
#
# Use the `conf-save` or `non-interactive` targets to update any config files
# listed in CONFIG_INCLUDES. This will have no effect unless your variable
# declarations use the conditional assignment operator, `?=` to allow the
# environment precedence over the file.
#
# The target, `reconfigure` will interactively prompt you to enter the config
# values. Since the config file is always loaded first, you can run configure
# multiple times, and existing configs will be loaded as default values.
#
# Use `add-config` to easily add new configs to your template. Specify the
# basename of your config file, and your new variable will be appended to the
# template file.
#
# Several other useful utils for working with configs or generating files.
# Use the source. Several awk scripts distributed in this package are embedded
# as macros, including the scripts for embedding macros. See `update-embeds.mk`
# for an example of how to package an awk script as a macro in your makefile.
#
# # #

CACHED_DG := ${.DEFAULT_GOAL}# ensure we don't interfere with the default goal

AWK := awk --posix

ifdef AUTO_INCLUDE_CONFS
CONFIG_INCLUDES = $(subst .tpl,.conf,$(shell find conf -name '*.tpl'))
endif

ifndef CONFIG_INCLUDES
$(error CONFIG_INCLUDES must be set before including configure-utils.mk)
endif
include ${CONFIG_INCLUDES}

recipe-escape:
	$(eval INFILE ?= ${--in})
	$(eval OUTFILE ?= ${--out})
	$(recipe-escape.awk) <${INFILE} >${OUTFILE};
.PHONY: recipe-escape

recipe-unescape:
	$(eval INFILE ?= ${--in})
	$(eval OUTFILE ?= ${--out})
	${recipe-unescape.awk} <${INFILE} >${OUTFILE};
.PHONY: recipe-unescape

recipe-minify:
	$(eval INFILE ?= ${--in})
	$(eval OUTFILE ?= ${--out})
	$(info processing ${INFILE})
	@echo 
	@$(minify.awk) <${INFILE} | $(recipe-escape.awk) >${OUTFILE}
.PHONY: recipe-minify

# # #
# Creates a config file from a tpl.
#
# Exports the variables to be replaced before calling the interactive
# shell script.
#
%.conf:
	$(info )
	$(info Generating configuration of ${@}.)
	@$(eval THEVARS := $(shell $(parse-conf-vars.awk) < ${*}.tpl))
	@$(foreach var,${THEVARS},$(eval export ${var})) \
	$(interactive-config.awk) ${*}.tpl ${@}

%.conf-save:
	@$(eval THEVARS := $(shell $(parse-conf-vars.awk) < ${*}.tpl))
	@$(foreach var,${THEVARS},$(eval export ${var})) \
	$(REPLACE_TOKENS) <${*}.tpl >${*}.conf

# # #
# -Rr, doesn't load special vars or targets; 
# -B forces re-building (the config files);
reconfigure:
	@$(MAKE) -RrBs ${CONFIG_INCLUDES}
.PHONY: reconfigure

save-conf non-interactive: $(foreach conf,${CONFIG_INCLUDES},${conf}-save)
.PHONY: noninteractive

# # #
# Prompts to declare a new variable and append to a template.
#
add-config: 
	@${add-config.awk}
.PHONY: add-config

# # #
# Shell command to replace {{TOKENs}} in a file
# 
# ${REPLACE_TOKENS} <file.in >file.out
REPLACE_TOKENS = perl -p -e 's%\{\{([^}]+)\}\}%defined $$ENV{$$1} ? $$ENV{$$1} : $$&%eg'

# # #
# Shell-escape spaces.
# e.g. $(call escape-spaces, string with spaces)
#
space := 
space += # hack that exploits implicit space added when concatenating assignment
escape-spaces = $(subst ${space},\${space},$(strip $1))

# # #
# generate a list of variable names by parsing strings on stdin
# e.g. $(eval THEVARS := $(shell $(parse-conf-vars.awk) < ${*}.tpl))
#
define parse-conf-vars.awk
$(AWK) '/=/ { print parse_var($$0); }function parse_var(s, var) { var = parse_declaration(s); sub("export","",var); return trim(var); }function parse_declaration(s) { match(s,/[^?=]*/); return substr(s,RSTART, RLENGTH); }function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }function rtrim(s) { sub(/[ \t\r\n]+$$/, "", s); return s }function trim(s) { return rtrim(ltrim(s)); }function alert(label, txt) { print label " [" txt "]" } '
endef
define interactive-config.awk
$(AWK) 'BEGIN {FILENAME = ARGV[1];CONF_FILE = (ARGC > 2) ? ARGV[2] : "/dev/fd/1";prompt("( Press Enter to continue. C to cancel. )\n") ;if ( ! getline usrReply < "-" || usrReply ) { exit 0; }blnYes = 0;while ( ! blnYes ) {prompt("\nReview Changes:" get_conf_values() "\n"); usrReply = "";prompt("\nIs this correct? [Y/n]");if ( getline usrReply < "-" == 0 ) { exit 0; }blnYes = ( usrReply == "Y" || usrReply == "y" );if ( blnYes ) {close(FILENAME); print "" > CONF_FILE;while ( (getline line < FILENAME) > 0 ) { emit_config(line); }prompt("Configuration saved.\n\n");}}exit;}function get_conf_values() {prompt("Leave blank for default [value].\n") ;preview = "";close(FILENAME); while ( (getline line < FILENAME) > 0 ) {if (match(line,/=/)) {preview = preview prompt_for_var(line);}}return preview;}function prompt_for_var(line) {declaration = parse_declaration(line);the_var = parse_var(line);default_val = trim(( (configs[the_var]) ? configs[the_var] : ENVIRON[the_var] ));helptext = parse_help(line);if (helptext) { helptext = "(" helptext ") "; }prompt( helptext declaration "? [" default_val "] ");if ( ! getline usrReply < "-" ) { exit 0; }configs[the_var] = (usrReply) ? usrReply : default_val ;return sprintf("\n%s = %s# %s", declaration, configs[the_var], helptext) ;}function parse_var(s, var) {var = parse_declaration(s);sub("export","",var); return trim(var);}function parse_declaration(s) {match(s,/[^?=]*/); return substr(s,RSTART, RLENGTH); }function parse_help(s) {match(s,"[^#}]+$$"); return trim(substr(s,RSTART,RLENGTH));}function emit_config(line) {if ( match(line,/=/)) {the_var = parse_var(line);token = "\\{\\{" the_var "\\}\\}";gsub( token, configs[the_var], line );} print line >> CONF_FILE;}function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }function rtrim(s) { sub(/[ \t\r\n]+$$/, "", s); return s }function trim(s) { return rtrim(ltrim(s)); }function alert(label, txt) { printf "\n%s [%s]", label, txt | "cat 1>&2" }function prompt(s) { printf "%s", s | "cat 1>&2" } '
endef
define recipe-escape.awk
$(AWK) '{ gsub(/\$$/, "$$$$"); gsub(/'\''/, "'\''\\'\'''\''"); print $$$$0 " \\" ;} '
endef
define recipe-unescape.awk
$(AWK) '{ gsub(/[\$$]{2}/, "$$"); gsub(/[[:blank:]]?\\[[:blank:]]?$$/, ""); gsub(/'\''\'\'''\''/, "'\''"); print ; } '
endef
define minify.awk
$(AWK) '{ if ( match($$0, /^[[:blank:]]*#/) ) { next; } gsub(/#[^"};]*$$/, "");  gsub(/[\n\r]+$$/, ""); gsub(/[\t]+/, ""); gsub(/[[:blank:]]{2,}/, " "); printf "%s", $$0; } '
endef
define embed-script-in-make.awk
$(AWK) 'BEGIN { DEFINE_BODY = readfile(ENVIRON["SOURCE_FILE"]);  DEFINE_NAME = ENVIRON["DEFINE_NAME"]; if (! DEFINE_NAME ) { DEFINE_NAME = ENVIRON["SOURCE_FILE"]; } DEFINE_BODY = rtrim(DEFINE_BODY); gsub(/\\$$/, "", DEFINE_BODY);  DEFINE_BODY = "$$(AWK) '\''" DEFINE_BODY "'\''";  start_define = "define[[:blank:]]+" DEFINE_NAME; definition = "define " DEFINE_NAME "\n" DEFINE_BODY "\nendef";}/define/,/^endef/ { if ( $$0 ~ start_define ) { found = replacing = 1; } if ( replacing && $$0 ~ /^endef/ ) { replacing = 0; print definition; next; }}{ if (! replacing ) { print } }END { if ( ! found ) { print "\n" definition; }}function rtrim(s) { sub(/[ \t\r\n]+$$/, "", s); return s }function readfile(file, contents){ while ((getline line < file) > 0) contents = contents line close(file) return contents} '
endef
define replace.awk
$(AWK) 'BEGIN { BLOCK_START = ENVIRON["SEARCH"]; BLOCK_END = ENVIRON["BLOCK_END"]; if ( ! BLOCK_END ) { BLOCK_END = BLOCK_START; } REPLACE = ENVIRON["REPLACE"];}BLOCK_START,BLOCK_END { if ( $$0 ~ BLOCK_START ) { replacing = 1; } if ( $$0 ~ BLOCK_START && $$0 ~ BLOCK_END ) { if ( BLOCK_START == BLOCK_END ) { search = BLOCK_START; } else { search = BLOCK_START ".*" BLOCK_END; } gsub(search, REPLACE); replacing = 0; } if ( replacing && $$0 ~ BLOCK_END ) { replacing = 0; print REPLACE; next; }}{ if (! replacing ) { print } } '
endef
define add-config.awk
$(AWK) 'BEGIN {STDIN = "-";filename = "";prompt("\nFile-name? "); getline filename <STDIN;if ( filename == "" ) { exit; }if ( match(filename,/\.conf$$|\.tpl$$/) ) {gsub(/\.conf$$|\.tpl$$/, "", filename); }filename = filename ".tpl";while ( 1 ) {name = "";prompt("\nConfig Name? "); getline name <STDIN;if ( name == "" ) { exit; }prompt("Help text? "); getline help <STDIN;prompt("export? [yes] "); getline noex <STDIN;prefix = (noex) ? "" : "export ";print prefix name " ?= {{" name "}}# " help >> filename;prompt(prefix name " ?= {{" name "}}# " help " >>" filename);}exit;}function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }function rtrim(s) { sub(/[ \t\r\n]+$$/, "", s); return s }function trim(s) { return rtrim(ltrim(s)); }function alert(label, txt) { printf "\n%s [%s]", label, txt | "cat 1>&2" }function prompt(s) { printf "%s", s | "cat 1>&2" } '
endef

.DEFAULT_GOAL := ${CACHED_DG}
