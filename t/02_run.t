use strict;
use warnings;
use Test::More;

use IPC::ShellCmd;
use IPC::ShellCmd::Generic;

my ($isc, $stdin, $stdout, $stderr, $status);

# Check that stdin can be passed in from a variable

$isc = IPC::ShellCmd->new(["/bin/sh", '-c', 'cat'])
    ->stdin('testing 1, 2, 3...')
    ->run();

$stdout = $isc->stdout();
$stderr = $isc->stderr();
$status = $isc->status();

is ($stdout, "testing 1, 2, 3...", 'string passed into shell command on stdin and picked up on stdout');
is ($stderr, '', 'nothing leaked out on stderr');
is ($status, 0, 'check exit status');


# Check that output from stderr can be picked up

$isc = IPC::ShellCmd->new(["/bin/sh", '-c', 'cat >&2'])
    ->stdin('testing 1, 2, 3...')
    ->run();

$stdout = $isc->stdout();
$stderr = $isc->stderr();
$status = $isc->status();

is ($stderr, "testing 1, 2, 3...", 'string passed into shell command on stdin and output picked up on stderr');
is ($stdout, '', 'nothing leaked out on stdout');
is ($status, 0, 'check exit status');


# Check that environment variables are passed through

$isc = IPC::ShellCmd->new(["/bin/sh", '-c', 'echo $ANSWER1-$ANSWER2'])
    ->add_envs(ANSWER1 => '42', ANSWER2 => '22')
    ->run();

$stdout = $isc->stdout();
$status = $isc->status();

like ($stdout, qr{42-22}, 'environment variables picked up');
is ($status, 0, 'check exit status');

# Check that working directory is acted upon
# (use a directory that exists on Linux, BSD, and MacOS)

$isc = IPC::ShellCmd->new(["/bin/sh", '-c', 'pwd'])
    ->working_dir('/etc')
    ->run();

$stdout = $isc->stdout();
$status = $isc->status();

like ($stdout, qr{^/etc\s*$}, 'working directory set');
is ($status, 0, 'check exit status');


# Check that umask is acted upon

$isc = IPC::ShellCmd->new(["/bin/sh", '-c', 'umask'])
    ->set_umask(oct(321))
    ->run();

$stdout = $isc->stdout();
$status = $isc->status();

like ($stdout, qr{^0321\s*$}, 'umask set');
is ($status, 0, 'check exit status');

# Check that environment variables are passed through

$isc = IPC::ShellCmd->new(["/bin/sh", '-c', 'echo -n $ANSWER1-$ANSWER2'])
    ->chain_prog(IPC::ShellCmd::Generic->new( Prog => 'time' ),
                 '-include-stdout' => 1)
    ->add_envs(ANSWER1 => '42', ANSWER2 => '22')
    ->run();

$stdout = $isc->stdout();
$stderr = $isc->stderr();
$status = $isc->status();

is ($stdout, "42-22", 'environment variables picked up');
like ($stderr, qr{\d+\.\d+\s*user.*\d+\.\d+\s*sys}, 'stderr contains timing info');
is ($status, 0, 'check exit status');



done_testing;
