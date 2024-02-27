package App::ISMN::Format;

use strict;
use warnings;

use Business::ISMN qw(ean_to_ismn);
use Class::Utils qw(set_params);
use Error::Pure qw(err);
use Getopt::Std;

our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Process parameters.
	set_params($self, @params);

	# Object.
	return $self;
}

# Run.
sub run {
	my $self = shift;

	# Process arguments.
	$self->{'_opts'} = {
		'h' => 0,
	};
	if (! getopts('h', $self->{'_opts'}) || @ARGV < 1
		|| $self->{'_opts'}->{'h'}) {

		print STDERR "Usage: $0 [-h] [--version] ismn_string\n";
		print STDERR "\t-h\t\tPrint help.\n";
		print STDERR "\t--version\tPrint version.\n";
		print STDERR "\tismn_string\tISMN string.\n";
		return 1;
	}
	my $ismn_input = shift @ARGV;

	my $ismn = $ismn_input;
	my $ismn_is_ean = 0;
	if ($ismn =~ m/^979/ms) {
		$ismn = ean_to_ismn($ismn);
		$ismn_is_ean = 1;
	}

	my $ismn_obj = Business::ISMN->new($ismn);
	if (! $ismn_obj) {
		err "ISMN '$ismn_input' is bad.";
		return 1;
	}

	# Validation.
	if (! $ismn_obj->is_valid) {
		$ismn_obj->fix_checksum;

		# Check again.
		if (! $ismn_obj->is_valid) {
			err "ISMN '$ismn_input' is not valid.";
			return 1;
		}
	}

	my $ismn_output;
	if ($ismn_is_ean) {
		$ismn_output = $ismn_obj->as_ean;
	} else {
		$ismn_output = $ismn_obj->as_string;
	}
	
	print $ismn_input.' -> '.$ismn_output, "\n";
	
	return 0;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::ISMN::Format - Base class for ismn-format script.

=head1 SYNOPSIS

 use App::ISMN::Format;

 my $app = App::ISMN::Format->new;
 my $exit_code = $app->run;

=head1 METHODS

=head2 C<new>

 my $app = App::ISMN::Format->new;

Constructor.

=head2 C<run>

 my $exit_code = $app->run;

Run.

Returns 1 for error, 0 for success.

=head1 ERRORS

 new():
         From Class::Utils::set_params():
                 Unknown parameter '%s'.

 run():
         ISMN '%s' is bad.
         ISMN '%s' is not valid.

=head1 EXAMPLE

=for comment filename=format_example_ismn.pl

 use strict;
 use warnings;

 use App::ISMN::Format;

 # Arguments.
 @ARGV = (
         '9790660556481',
 );

 # Run.
 exit App::ISMN::Format->new->run;

 # Output:
 # TODO

=head1 DEPENDENCIES

L<Business::ISMN>,
L<Class::Utils>,
L<Error::Pure>,
L<Getopt::Std>.

=head1 REPOSITORY

L<https://github.com/michal-josef-spacek/App-ISMN-Format>

=head1 AUTHOR

Michal Josef Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

© 2024 Michal Josef Špaček

BSD 2-Clause License

=head1 VERSION

0.01

=cut
