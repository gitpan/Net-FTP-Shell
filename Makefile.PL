


use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

use lib '/u/tbrannon/perl/inetcrossftp/src/lib/site_perl/5.005';

WriteMakefile
  (
   'NAME'		=> 'Net::FTP::Shell',
   'VERSION_FROM'	=> 'Shell.pm', # finds $VERSION
   'PREREQ_PM'	=> 
   { 
    Config::IniFiles => 1.6, 
    User             => 1.0
   }
  );
