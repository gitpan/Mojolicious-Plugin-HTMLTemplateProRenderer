package Mojolicious::Plugin::HTMLTemplateProRenderer;

use 5.006;
use Mojo::Base 'Mojolicious::Plugin';

use HTML::Template::Pro;

our $VERSION = '0.02';

sub register {
	my ( $self, $app, $conf ) = @_;
	$self->{plugin_config} = $conf;
	$app->renderer->add_handler( tmpl => sub{ $self->render_tmpl(@_)} );
}

sub render_tmpl {
	my ( $self, $r, $c, $output, $options ) = @_;
	my $conf        = $self->{plugin_config};
	my %tmpl_params = %{ $c->stash };

	unshift @{ $r->paths }, $c->app->home
	  if ( $conf->{tmpl_opts}->{use_home_template}
		|| delete $tmpl_params{use_home_template} );

	my $controller = $c->stash('controller');

	my @template_dirs;

	push @template_dirs, $c->app->home->rel_dir('templates');

	if ($controller) {
		push @template_dirs, $c->app->home->rel_dir("templates/$controller");
	}

	my %t_options;

	$t_options{die_on_bad_params}      = 0;
	$t_options{global_vars}            = 1;
	$t_options{loop_context_vars}      = 1;
	$t_options{path}                   = \@template_dirs;
	$t_options{search_path_on_include} = 1;

	if ( defined( $options->{inline} ) ) {
		$t_options{scalarref} = \$options->{inline};
	}
	elsif ( defined( $options->{template} ) ) {
		if (defined (my $path = $r->template_path($options))) {
			$t_options{filename} = $path;
			$t_options{cache}    = 1;
		} else {
			$t_options{scalarref} = $r->get_data_template($options);
		}

	}

	# sanity params removing scalar inside arrayref
	foreach ( keys %tmpl_params ) {
		delete $tmpl_params{$_}
		  if ( ( ref $tmpl_params{$_} eq 'ARRAY' )
			&& $tmpl_params{$_} > 0
			&& $tmpl_params{$_}->[0] ne 'HASH' );
	}

	my $t = HTML::Template::Pro->new(
		%t_options,
		%{ $conf->{tmpl_opts} || {} },
		%{ delete $tmpl_params{tmpl_opts} || {} }
	);

	unless ($t) { $r->render_exception("ERROR: No template created"); }

	$t->param(%tmpl_params);

	$$output = $t->output();
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::HTMLTemplateProRenderer - Mojolicious Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('HTMLTemplateProRenderer');


  # Mojolicious::Lite
  plugin 'HTMLTemplateProRenderer';

  # Render HTML::Template::Pro handler and post 'utf8 => 1' option for next HTML::Template::Pro->new call
  get '/' => sub{
    my $self = shift;
    $self->render('bender', handler => 'tmpl', tmpl_opts => {utf8 => 1});
  }


  # Set default options for all HTML::Template::Pro->new calls
  plugin 'HTMLTemplateProRenderer', tmpl_opts => {blind_cache => 1, open_mode => '<:encoding(UTF-16)'};

=head1 DESCRIPTION

L<Mojolicious::Plugin::HTMLTemplateProRenderer> is a L<Mojolicious> plugin to use L<HTML::Template::Pro> module in your Mojo projects.

L<HTML::Template::Pro> is a fast lightweight C/Perl+XS reimplementation of L<HTML::Template> (as of 2.9) and L<HTML::Template::Expr> (as of 0.0.7). 
It is not intended to be a complete replacement, but to be a fast implementation of L<HTML::Template> if you don't need querying, the extended facility of L<HTML::Template>.

Designed for heavy upload, resource limitations, abcence of L<mod_perl>.

=head1 METHODS

L<Mojolicious::Plugin::HTMLTemplateProRenderer> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 C<register>

  $plugin->register;

Register plugin in L<Mojolicious> application.

=head1 OPTIONS

These are options for L<Mojolicious::Plugin::HTMLTemplateProRenderer> 

=head2 C<use_home_template>

  $self->render('template', handler => 'tmpl',use_home_template => 1);

Templates are found starting from home base app path other than home_app/templates path.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=head1 COPYRIGHT & LICENSE
 
Copyright 2014 Emiliano Bruni, all rights reserved.

Initially based on L<Mojolicious::Plugin::HTMLTemplateRenderer> code which is 
copyrighted by Bob Faist.
 
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
 
=cut
