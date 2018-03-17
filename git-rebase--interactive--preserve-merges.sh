#!/bin/sh
# This shell script fragment is sourced by git-rebase to implement
# its interactive mode with --preserve-merges flag.
# "git rebase --interactive" makes it easy to fix up commits in the
# middle of a series and rearrange commits and adding --preserve-merges
# requests it to preserve merges while rebase.
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
git_rebase__interactive__preserve_merges () {
	initiate_action "$action"
	ret=$?
	if test $ret == 0; then
		return 0
	fi

	setup_reflog_action
	init_basic_state

	if test -z "$rebase_root"
	then
		mkdir "$rewritten" &&
		for c in $(git merge-base --all $orig_head $upstream)
		do
			echo $onto > "$rewritten"/$c ||
			    die "$(gettext "Could not init rewritten commits")"
		done
	else
		mkdir "$rewritten" &&
		echo $onto > "$rewritten"/root ||
			die "$(gettext "Could not init rewritten commits")"
	fi

	# No cherry-pick because our first pass is to determine
	# parents to rewrite and skipping dropped commits would
	# prematurely end our probe
	merges_option=

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

	# The 'rev-list .. | sed'
	#   requires %m to parse; where as the the instruction
	#   requires %H to parse
	format=$(git config --get rebase.instructionFormat)
	git rev-list $merges_option --format="%m%H ${format:-%s}" \
		--reverse --left-right --topo-order \
		$revisions ${restrict_revision+^$restrict_revision} | \
		sed -n "s/^>//p" |
	while read -r sha1 rest
	do
		if test -z "$keep_empty" \
			&& is_empty_commit $sha1 \
			&& ! is_merge_commit $sha1
		then
			comment_out="$comment_char "
		else
			comment_out=
		fi

		if test -z "$rebase_root"
		then
			preserve=t
			for p in $(git rev-list --parents -1 $sha1 | \
				cut -d' ' -s -f2-)
			do
				if test -f "$rewritten"/$p
				then
					preserve=f
				fi
			done
		else
			preserve=f
		fi
		if test f = "$preserve"
		then
			touch "$rewritten"/$sha1
			printf '%s\n' "${comment_out}pick $sha1 $rest" >>"$todo"
		fi
	done

	mkdir "$dropped"
	# Save all non-cherry-picked changes
	git rev-list $revisions --left-right --cherry-pick | \
		sed -n "s/^>//p" > "$state_dir"/not-cherry-picks
	# Now all commits and note which ones are missing in
	# not-cherry-picks and hence being dropped
	git rev-list $revisions |
	while read rev
	do
		if test -f "$rewritten"/$rev &&
		   ! sane_grep "$rev" "$state_dir"/not-cherry-picks >/dev/null
		then
			# Use -f2 because if rev-list is telling us this commit
			# is not worthwhile, we don't want to track its
			# multiple heads, just the history of its first-parent
			# for others that will be rebasing on top of it.
			git rev-list --parents -1 $rev | \
				cut -d' ' -s -f2 > "$dropped"/$rev
			sha1=$(git rev-list -1 $rev)
			sane_grep -v "^[a-z][a-z]* $sha1" <"$todo" > "${todo}2"
			mv "${todo}2" "$todo"
			rm "$rewritten"/$rev
		fi
	done

	complete_action
}
# ... and then we call the whole thing.
git_rebase__interactive__preserve_merges
