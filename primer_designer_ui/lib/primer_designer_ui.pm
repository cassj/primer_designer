package primer_designer_ui;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple

    StackTrace

    Authentication

    Session
    Session::Store::FastMmap
    Session::State::Cookie
/;

extends 'Catalyst';

our $VERSION = '0.01';
$VERSION = eval $VERSION;

# Configure the application.
#
# Note that settings in primer_designer_ui.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'primer_designer_ui',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
);

# Configure SimpleDB Authentication
__PACKAGE__->config->{'Plugin::Authentication'} = {
						   default => {
							       class           => 'SimpleDB',
							       user_model      => 'DB::User',
							       password_type   => 'clear',
							      },
						  };

# Start the application
__PACKAGE__->setup();


=head1 NAME

primer_designer_ui - Catalyst based application

=head1 SYNOPSIS

    script/primer_designer_ui_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<primer_designer_ui::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Cass

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
