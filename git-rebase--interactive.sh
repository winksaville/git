#!/bin/sh
# This shell script fragment is sourced by git-rebase to implement
# its interactive mode.  "git rebase --interactive" makes it easy
# to fix up commits in the middle of a series and rearrange commits.
#
# Copyright (c) 2006 Johannes E. Schindelin
#
# The original idea comes from Eric W. Biederman, in
# https://public-inbox.org/git/m1odwkyuf5.fsf_-_@ebiederm.dsl.xmission.com/

. git-rebase--interactive--lib

# The whole contents of this file is run by dot-sourcing it from
# inside a shell function.  It used to be that "return"s we see
# below were not inside any function, and expected to return
# to the function that dot-sourced us.
#
# However, older (9.x) versions of FreeBSD /bin/sh misbehave on such a
# construct and continue to run the statements that follow such a "return".
# As a work-around, we introduce an extra layer of a function
# here, and immediately call it after defining it.
git_rebase__interactive () {

	initiate_action "$action"
	ret=$?
	if test $ret = 0; then
		return 0
	fi

	setup_reflog_action
	init_basic_state

	merges_option="--no-merges --cherry-pick"

	shorthead=$(git rev-parse --short $orig_head)
	shortonto=$(git rev-parse --short $onto)
	if test -z "$rebase_root"
		# this is now equivalent to ! -z "$upstream"
	then
		shortupstream=$(git rev-parse --short $upstream)
		revisions=$upstream...$orig_head
		shortrevisions=$shortupstream..$shorthead
	else
		revisions=$onto...$orig_head
		shortrevisions=$shorthead
	fi

	git rebase--helper --make-script ${keep_empty:+--keep-empty} \
		$revisions ${restrict_revision+^$restrict_revision} >"$todo" ||
	    die "$(gettext "Could not generate todo list")"

	complete_action
}
# ... and then we call the whole thing.
git_rebase__interactive
