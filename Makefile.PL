use ExtUtils::MakeMaker;
WriteMakefile(
	NAME         => 'Mojolicious::Plugin::HTMLTemplateProRenderer',
	VERSION_FROM => 'lib/Mojolicious/Plugin/HTMLTemplateProRenderer.pm', # finds \$VERSION
	AUTHOR       => 'Emiliano Bruni (info@ebruni.it)',
	ABSTRACT     => 'A Mojoliciuos plugin to render templates using HTML::Template::Pro module',
	PREREQ_PM    => {
                     	'Test::Simple' => 0.44,
			'Mojolicious' => '4.0', 
			'HTML::Template::Pro' => '0.45'
                    },
	MIN_PERL_VERSION => '5.006',
	test         => {TESTS => 't/*.t'}
);
