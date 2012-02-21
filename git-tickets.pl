#!/usr/bin/perl

use strict;
use Cwd;
use Data::Dumper;


sub defaultPattern { return '(refs|fixes)\s+#\d+'; }
my $script = $0;
my %git = ();

sub error {
    my $msg = shift;
    print $msg."\n";
    exit 1;
}

sub hookCommitMessage {
    my $msgfile = shift;
    if ( -f $msgfile ){
        open my $fd,'<',$msgfile 
            or error "can't open commitMessage file: $msgfile";
        my @msglines = <$fd>;
        close $fd;

        my $pattern = qr{ defaultPattern() };
        if ( exists $git{ 'config' }->{'pattern'} ){
            my $val = $git{ 'config' }->{'pattern'};
            $pattern = qr/${val}/;
        }

        for ( @msglines ) {
            if ( /${pattern}/ ){
                exit 0;
            }
        }
        error "Wrong commit message" ;
    }
    error "Not exists commitMessage file: $msgfile";
}

sub cmdHelp {
    local $\ = "\n";
    print "git tickets init -- add hook";
    print "git tickets pattern -- show current pattern";
    print "git tickets pattern NEW_PATTERN -- change pattern";
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

sub cmdPattern {
    unless( $_[0] ){
        my $pattern = $git{config}->{pattern} || defaultPattern();
        print "Current pattern is: /$pattern/";
        exit;
    }

    my $pattern = shift;
    eval {
        'commit-msg' =~ /$pattern/;
    };

    if( $@ ){
        error "Broken pattern. Use regexp patterns only";
    }

    git("config --file=".$git{'root'}."/config tickets.pattern '".$pattern."'");
    print "Pattern changed to /$pattern/\n";
}

sub git {
    my $args = shift;
    my $out = `git $args`;
    chomp $out;
    return $out;
}


sub gitConfig {
    my $out = git('config --get-regexp tickets.*');
    my %conf = ( map {
        if( /^tickets\.(.*)\s+(.*)$/ ){
            +( $1 => $2 );
        }
    } split /\s*\n\s*/, $out );

    $git{ 'config' } = \%conf;
    $git{ 'root' } = git('rev-parse --git-dir');
}


gitConfig();
if ( $script =~ /commit-msg$/ ){
    my $msgfile = shift 
        or error "commit-msg hook need 1 argument";
    hookCommitMessage( $msgfile );
}
elsif ( $script =~ /git-tickets$/ ){
    my $cmd = shift or 'help';

    

    my %commands = (
        help    => \&cmdHelp,
        init    => \&cmdInit,
        pattern => \&cmdPattern,
    );


    unless( exists $commands{$cmd} ){
        $cmd = 'help';
        $commands{$cmd}->();
    }

    $commands{$cmd}( @ARGV );
}
else{
    print "direct run: $script\n";
    cmdHelp();
}
