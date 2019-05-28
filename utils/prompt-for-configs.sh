#!/bin/sh

# # #
# Generates an include file for Gnu Make using scoped environment variables to replace tokens in a template.
# 
# Example implicit rule for generating .conf files from .tpl files:
# %.conf: 
#	./prompt-for-configs.sh ${*}.tpl ${@}
#
# Values can only come from the environment, or from user-prompt.
# To re-configure a file, including the config file will cause the existing values to be used by default.
#
# WARNING: ignores lines that do not contain an 'export'.
# SAMPLE: export PROJECT_ROOT ?= /var/www/# comments like this are used in user-prompts.
#	prompt: export PROJECT_ROOT ( comments liek this are used in user-prompts. ) = [/var/www/]?
#
# TIP: include a trailing-slash when configuring paths. 
# TIP: terminate paths with a hash/sharp to avoid the error of trailing-white-space.
#
# Example re-configure target where ${CONFIG_INCLUDES} contains a list of .conf files:
# configure:
#	$(MAKE) -RrB ${CONFIG_INCLUDES} 	# -Rr, doesn't load special vars or targets; -B forces re-building (the config files)
#
# # #

printf '\nGenerating Configuration of %s.\n' "$1"
printf 'Continue? (Y/N) [N]'
read yes
if ( [ "$yes" = 'n' ] || [ "$yes" = 'N' ] || [ -z "$yes" ] ); then
	exit 0
fi
printf '\nLeave blank for default [value].\n'

# get vars to set from the tpl:
while IFS= read -r conf; do
	test "${conf#*export}" = "$conf" && continue;	# discard lines that don't begin with 'export'

	the_var=$(echo "$conf" | sed -s 's/export[[:space:]]*\([^[:space:]]*\).*/\1/')
	help=$(echo "$conf" | sed -s 's/[^#]*#*\([^#]*\)$/\1/')
	test -n "$help" && help="($help ) "
	default=$(eval echo -n \"'$'$the_var\")
	# dev detritus:
	#echo found the_var="$the_var"
	#echo found help="$help"
	#echo found default="$default"
	printf 'export %s %s= [%s]? ' "$the_var" "$help" "$default"
	read reply </dev/tty
	if [ -z "$reply" ]; then
		reply="$default"
	fi
	eval ${the_var}="'$reply'"
done < "$1"


printf '\nReview Changes:\n'
while IFS= read -r conf; do
	test "${conf#*export}" = "$conf" && continue;
	the_var=$(echo "$conf" | sed -s 's/export[[:space:]]*\([^[:space:]]*\).*/\1/')
	help=$(echo "$conf" | sed -s 's/[^#]*#*\([^#]*\)$/\1/')
	test -n "$help" && help="#($help ) "
	default=$(eval echo -n \"'$'$the_var\")
	printf 'export %s = %s%s\n' "$the_var" "$default" "$help" 
done < "$1"

printf '\nCommit these changes? (Y/N) [N]'
read yes

if ( [ "$yes" = 'Y' ] || [ "$yes" = 'y' ] ); then
	perl -p -e 's#\{\{([^}]+)\}\}#defined $ENV{$1} ? $ENV{$1} : $&#eg' < "$1" >"$2"
else
	echo - aborted -
fi
