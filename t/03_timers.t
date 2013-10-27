use strict;
use warnings;
use Test::More;
use Time::HiRes qw(time);

use IPC::ShellCmd;
use IPC::ShellCmd::Generic;

our ($isc, $stdin, $stdout, $stderr, $status, $cb_isc, $then, $runtime, $n_callback_calls);

our $DEBUG        = 0;
our $timeout      = 4;
our $cb_interval  = 0.4;

$then = time;
$isc = IPC::ShellCmd->new(["sleep", 2 * $timeout], -debug => $DEBUG)
    ->add_timers($cb_interval => \&callback,
                 $timeout     => 'KILL')
    ->run();
$runtime = time - $then;

$status = $isc->status();

is ($status, 9,    'check exit status (9 = SIGKILL)');
cmp_ok ($runtime, '<', 1.5 * $timeout, 'upper limit on runtime (less than 1.5 * timeout)');
cmp_ok ($runtime, '>=', $timeout,      'lower limit on runtime (at least timeout)');
cmp_ok ($n_callback_calls, '<', $timeout/$cb_interval + 3, 'upper limit on callback calls');
cmp_ok ($n_callback_calls, '>', $timeout/$cb_interval - 3, 'lower limit on callback calls');
is ($cb_isc, $isc, 'callback passed in the $isc object');

done_testing;

sub callback {
    my ($isc, $pid, $time) = @_;
    $isc->add_timers(0.5 => \&callback);
    $cb_isc = $isc;
    $n_callback_calls++;
    return 1;
}
