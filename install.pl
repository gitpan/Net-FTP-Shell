use User;
use File::Copy;

$n = '.ncfg';

copy($n, sprintf("%s/%s", User->Home, $n));
 
