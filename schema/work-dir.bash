#
#  Synopsis:
#	Create, change to and destroy a work directory.
#  Usage:
#	export SETSPACE_KEEP_WORK_DIR=1
#
#	. $SETSPACE_ROOT/libexec/work-dir.bash || exit 2
#

error_setspace_work_dir()
{
	echo "setcore-work-dir: ERROR: $@" >&2
}

leave_setspace_work_dir()
{
	test -d $SETSPACE_WORK_DIR -o -n "$SETSPACE_KEEP_WORK_DIR"	||
				return

	cd ..
	rm --force --recursive "$SETSPACE_WORK_DIR"			||
	      error_setspace_work_dir "rm work dir failed: exit status=$?"
}

if [ -n "$SETSPACE_WORK_DIR" ];  then
	error_setspace_work_dir "env already defined: SETSPACE_WORK_DIR"
	return 1
fi
export SETSPACE_WORK_DIR=${TMPDIR:=TMPDIR:=/tmp}/$(basename $0)-$$.d

if [ -d "$SETSPACE_WORK_DIR" ];  then
	error_setspace_work_dir "work dir exists: $SETSPACE_WORK_DIR"
	return 1
fi

mkdir --parents "$SETSPACE_WORK_DIR"
STATUS=$?
if [ $STATUS != 0 ];  then
	error_setspace_work_dir "mkdir work failed: exit status=$?"
	return 1
fi

#
#  tack on the cleanup function for various signals
#
#  Note: prefix with true cause bash chokes on empty statement
#
_TRAP=$(trap -p EXIT | cut -f2 -d \')
case "$_TRAP" in
'')
	_TRAP=leave_setspace_work_dir
	;;
*)
	_TRAP="$_TRAP; leave_setspace_work_dir"
	;;
esac

trap "$_TRAP" EXIT INT QUIT TERM

cd $SETSPACE_WORK_DIR || die "cd work dir failed: exit status=$?"
