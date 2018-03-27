#!/bin/sh

. ../bdl--lib.sh
bdl_dst=output

test_description='test bash debug logger'

. ./test-lib.sh

test_expect_success 'bdl_nsl only prints nothing' '
	printf "" >output &&
	bdl_nsl &&
	printf "" >expected &&
	test_cmp expected output
'

test_expect_success 'bdl_nsl with string prints string only' '
	printf "" >output &&
	bdl_nsl "test 1" &&
	printf "test 1\n" >expected &&
	test_cmp expected output
'

test_lineno=$LINENO
test_expect_success 'bdl only print source and linenumber' '
	printf "" >output &&
	bdl &&
	printf "t0014-bdl--lib.sh:$((test_lineno+3)):\n" >expected &&
	test_cmp expected output
'

test_lineno=$LINENO
test_expect_success 'bdl with string prints source and linenumber and string' '
	printf "" >output &&
	bdl "test 1" &&
	printf "t0014-bdl--lib.sh:$((test_lineno+3)): test 1\n" >expected &&
	test_cmp expected output
'

test_expect_success 'bdl 0 "nothing printed"' '
	printf "" >output &&
	printf "" >expected &&
	bdl 0 "nothing printed" &&
	test_cmp expected output
'

# Save current bdl_dst and restore when test completes
bdl_dst_save=$bdl_dst
bdl_stdout_save=$bdl_stdout
test_expect_success 'bdl bdl_dst empty bdl_stdout=0 nothing printed' '
	bdl_dst= &&
	bdl_stdout=0 &&
	printf "" >output &&
	printf "" >expected &&
	bdl "nothing printed" &&
	test_cmp expected output
'
bdl_dst=$bdl_dst_save
bdl_stdout=$bdl_stdout_save

# Testing subroutine calls from a test verify bdl_save/restore works
# for direct calls and nested calls
subsub_lineno=$LINENO
subsub () {
	bdl_save
	bdl "subsub line"
	bdl_restore
	return "0"
}

sub_lineno=$LINENO
sub () {
	bdl_save
	bdl "sub line"
	subsub
	bdl_restore
	return "0"
}

test_expect_success 'test calls subsub' '
	printf "" >output &&
	subsub &&
	printf "t0014-bdl--lib.sh:$((subsub_lineno+3)): subsub line\n" >expected &&
	test_cmp expected output
'

test_expect_success 'test sub calls subsub' '
	printf "" >output &&
	sub &&
	printf "t0014-bdl--lib.sh:$((sub_lineno+3)): sub line
t0014-bdl--lib.sh:$((subsub_lineno+3)): subsub line\n" >expected &&
	test_cmp expected output
'

test_done
