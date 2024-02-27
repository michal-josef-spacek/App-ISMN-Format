use strict;
use warnings;

use App::ISMN::Format;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($App::ISMN::Format::VERSION, 0.01, 'Version.');
