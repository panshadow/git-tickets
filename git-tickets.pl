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

sub getPattern {
    my $val = defaultPattern();
    my $isDefault = 1;
    if ( exists $git{ 'config' }->{'pattern'} ){
        $val = $git{ 'config' }->{'pattern'};
        $isDefault = 0;
    }
    return wantarray() ? ($val,$isDefault) : $val;
}

sub hookCommitMessage {
    my $msgfile = shift;
    if ( -f $msgfile ){
        open my $fd,'<',$msgfile 
            or error "can't open commitMessage file: $msgfile";
        my @msglines = <$fd>;
        close $fd;

        my $val = getPattern(); 
        print "Check commit-msg. Used pattern /$val/\n";
        my $pattern = qr/${val}/;

        for ( @msglines ) {
            if ( /${pattern}/ ){
                exit 0;
            }
        }
        error "Wrong commit message." ;
    }
    error "Not exists commitMessage file: $msgfile";
}

sub cmdHelp {
    local $\ = "\n";
    my ($pattern,$isDefault) = getPattern();

    print "git tickets init\t\t\t\t\t-- add hook";
    print "git tickets remove\t\t\t\t-- remove hook";
    print "git tickets status\t\t\t\t-- get hook status";
    print "git tickets pattern\t\t\t\t-- show current pattern";
    print "git tickets pattern NEW_PATTERN\t-- change pattern";
    print "current pattern is /$pattern/ ".($isDefault ? '(default)' : '(custom)' );
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

sub cmdRemove {
    if(_hasHook()){
        unlink $git{'root'}.'/hooks/commit-msg';
        print "hook has removed\n";
    }
    else{
        print "hook not installed\n";
    }
}

sub _hasHook {
    my $hook = $git{'root'}.'/hooks/commit-msg';
    if( -f $hook && -l $hook ){
        my $origin = readlink($hook);
        if( $origin eq $script ){
            return 1;
        }
    }
    return 0;
}

sub cmdStatus {
    if( _hasHook() ){
        print "hook installed\n";
        cmdPattern();
    }
    else{
        print "hook doesn't installed\n";
        print "use 'git tickets init' to install it\n";
    }
}

sub cmdPattern {
    unless( $_[0] ){
        my $pattern = $git{config}->{pattern} || defaultPattern();
        print "Current pattern is: /$pattern/\n";
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
        remove  => \&cmdRemove,
        status  => \&cmdStatus,
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
