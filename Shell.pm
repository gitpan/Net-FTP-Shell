package Net::FTP::Shell;


use strict;


use Net::FTP::Common;
use Config::IniFiles;
use Data::Dumper;
use User;


require Exporter;

use vars qw(%parse $VERSION @ISA);

%parse = (
    'send'   => \&send,
    'get'    => \&get,
    'dir'    => \&dir,
    'mkdir'  => \&mkdir,
    'check'  => \&check,
    'glob'  => \&glob,
    'describe'  => \&describe
	      );

@ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Net::FTP::Shell ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.

$VERSION = '1.2';


# Preloaded methods go here.

sub new {
    my $pkg = shift;
    my $cmdline = shift;
    
    my $self = {};

    $self->{cmdline} = $cmdline;
    bless $self, $pkg;
    return $self;
}

sub parse {
    my ($self) = @_;

    $self->{verb} = shift @{$self->{cmdline}};
    $self->{hkey} = shift @{$self->{cmdline}};
    $self->{ftp}  = $self->prep($self->{hkey});
    
#    print Data::Dumper->Dump([\%parse,$self],['parse','self']);

    &{$parse{$self->{verb}}}($self);
}

sub prep {
    my ($self,$hkey)=@_;
    my $cfg = Config::IniFiles->new
	( 
	  -file    => sprintf("%s/%s", User->Home, ".ncfg"), 
	  -default => 'Default'
	  );

#    print Data::Dumper->Dump([$cfg],['cfg']), $/;

    my %common_cfg;

    map {
	my $tmp = $cfg->val($hkey, $_);
#	$tmp =~   s/^\s+|\s+$//g;
	$self->{Common}->{$_} = $tmp;
    } qw(User Pass Dir Host);
	

    Net::FTP::Common->new({}, $self->{Common});
}

sub help {
    print "Sample usages:

# Login with account terrence, cd to config'ed dir, upload file
please.pl send terrence ezfile.txt

# Login with account terrence, cd to config'ed dir, download file
please.pl get terrence ezfile.txt
    
# Login with account terrence and make directory /download/terrence
please.pl mkdir terrence /download/terrence

# Login with account terrence and check for a file with specific name
";
}

sub send {
    my $obj = shift;
    
    warn 'calling send';

    $obj->{ftp}->send($obj->{Common}->{Host}, File => shift @{$obj->{cmdline}});

}

sub describe {
    my $obj = shift;
    warn 'calling describe';
    print Data::Dumper->Dump([$obj->{ftp}],[$obj->{hkey}]);
    print $/;
}

sub mkdir {
    my $obj = shift;
    
    warn 'calling mkdir';

    $obj->{ftp}->mkdir($obj->{Common}->{Host}, Dir => shift @{$obj->{cmdline}}, Recurse => 1);

}

sub dir {
    my $obj = shift;
    
    my @dir = $obj->{ftp}->dir($obj->{Common}->{Host});

    print join "\n", @dir;

}


sub get {
    my $obj = shift;
    
    warn 'calling get';

    $obj->{ftp}->get($obj->{Common}->{Host}, File => shift @{$obj->{cmdline}});

}

sub result_out {
    my $file   = shift;
    my $result = shift;


    if ($result) {
	print "$file was found";
    } else {
	print "$file not found";
    }
}

sub check {
    my $obj = shift;
    
    warn 'calling check';

    my $file = shift @{$obj->{cmdline}};
    my $result = $obj->{ftp}->check($obj->{Common}->{Host}, File => $file);

    result_out ($file,$result);

}

sub glob {
    my $obj = shift;
    
    warn 'calling glob';
    my $file = shift @{$obj->{cmdline}};

    my $result = $obj->{ftp}->glob($obj->{Common}->{Host}, File => $file);

    result_out ($file,$result);
}


1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Net::FTP::Shell - Perl extension for shell use of Net::FTP::Common

=head1 SYNOPSIS

  # from the DOS/Unix shell...
  shell> please.pl get  gnu emacs.tgz        # ... will ftp a file to gnu acct
  shell> please.pl send gnu vi-sucks.truth   # ... will ftp a file to gnu acct
  shell> please.pl dir  gnu                  # ... will list directory of gnu acct
  shell> please.pl mkdir gnu /new/wares      # ... must use absolute path
  shell> please.pl check gnu 'emacs-30.tar.gz'
  shell> please.pl glob  gnu '.*.tar.gz'     # ... not a glob, but a regexp
  shell> please.pl describe gnu
  ----- account named "gnu" --------
  username:  wareboy
  password:  gnupass
  host:      ftp.gnu.org
  directory: /users/wareboy
  xfer_type: I (binary transfers... ascii is A)
  Debug    : 1
  Timeout  : 240


=head1 DESCRIPTION

This is a module which was designed when point-to-point FTP communication
between two people is not possible (ie, for firewall reasons) but they need
to exchange files and they have a common FTP account somewhere.

=head1 PREREQUISITES

=over 4

=item * Net::FTP::Common (CPAN id: TBONE)

=item * User (CPAN id: TBONE)

=item * Config::IniFiles

note that IniFiles 1.6 has a small problem with the regular expression on
line 399:

  elsif (($parm, $val) = /\s*([\S\s]+?)\s*=\s*(.*)/) {	# new parameter

should be

  elsif (($parm, $val) = /\s*([\S\s]+?)\s*=\s*(\S*)/) {	# new parameter

I have sent in a bug report. Until then, patch your Config::IniFiles 
to the above before sending any problem reports with this module.

=back

=head1 INSTALLATION (Important)

Installing the module is easy:

 perl Makefile.PL
 make install 

Then, you can either type

 perl install.pl 

and have a default .ncfg placed in your home directory or you can do the 
manual process described below:

=head2 Manual Process

You must create a file named ".ncfg" and place in your home 
directory. On Unix, you can find your home directory by typing

 echo $HOME

On Windows, open a command shell and type
 
 set USERPROFILE

The .ncfg file is written in Windows INI-file syntax. Here is a sample one:

 [Default]
 User = heave
 Pass = ho
 Host = 229.117.122.180
 Dir  = /download


 [Instinet]
 Dir = /download/instinet


 [Rydex]
 Dir = /download/rydex

 [Socgen]
 Dir = /download/socgen


 [Linda]
 Dir = /download/linda

 [Terrence]
 Dir = /download/terrence
  
Then you can simply use the please.pl Perl script to send things:

 perl please.pl send Linda love-letter.txt
 perl please.pl send Terrence resume.doc


=head1 AUTHOR

T. M. Brannon, tbone@cpan.org

=head1 SEE ALSO

www.metaperl.com, www.rebol.com, Net::FTP::Common, Net::FTP

=cut
