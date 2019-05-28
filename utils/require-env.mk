
###
# Generates an error if a variable is not defined.
# Use as an order-only prerequisite to targets, i.e. after a pipe (|) character.
#  e.g. target: prereq | require-env-BUILD_HOME
#
DEBUG_REQUIRE_ENV = # leave empty for false
require-env-%:
	@ $(if ${${*}},, $(error required env $* is not defined))
	@ $(if $(strip ${DEBUG_REQUIRE_ENV}),echo '$$${*} is "${${*}}"')

###
# Generates an error if a variable is not defined.
# Use to generate an error for all targets, or for a single target in a recipe.
# e.g. $(call require-env, PROJ_ROOT)
#
define require-env
$(if ${${strip $1}},,$(error required env ${1} is not defined))
endef
