#!/usr/bin/perl

use strict;
use Cwd;


my $script = $0;
my %git = ();

sub hookCommitMessage {
    my $msgfile = shift;
    if ( -f $msgfile ){
        open my $fd,'<',$msgfile 
            or die "can't open commitMessage file: $msgfile";
        my @msglines = <$fd>;
        close $fd;
        for ( @msglines ) {
            if ( /(refs|fixes)\s+#\d+/ ){
                exit 0;
            }
        }
        die "Wrong commit message" ;
        exit 1;
    }
    die "Not exists commitMessage file: $msgfile";
}

sub cmdHelp {
    print "git tickets init -- add hook";
    exit;
}

sub cmdInit {

    if ( symlink($script,$git{'root'}.'/hooks/commit-msg' ) ){
        print  "hook added\n";
    }
    else{
        print "hook commit-msg already exists\n";
    }
}



if ( $script =~ /commit-msg$/ ){
    my $msgfile = shift 
        or die "commit-msg hook need 1 argument";
    hookCommitMessage( $msgfile );
}
elsif ( $script =~ /git-tickets$/ ){
    my $cmd = shift or 'help';

    $git{ 'root' } = `git rev-parse --git-dir`;
    chomp $git{ 'root' };

    my %commands = (
        help    => \&cmdHelp,
        init     => \&cmdInit,
    );

    unless( exists $commands{$cmd} ){
        $cmd = 'help';
        $commands{$cmd}->();
    }

    $commands{$cmd}();
}
else{
    print "direct run: $script\n";
    cmdHelp();
}
