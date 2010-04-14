use strict;
use warnings;
use inc::Module::Install;
name 'Plient';
author   'sunnavy <sunnavy@bestpractical.com>';
license  'perl';

tests('t/*.t t/*/*.t');
#recursive_author_tests('xt/');

auto_install;
WriteAll;
