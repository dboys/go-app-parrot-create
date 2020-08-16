{{ if .BuildSystem.IsPerl5 }}
__README__
Language '{{ .Name }}' with {{ .BuildSystem }} build system and {{ .TestSystem }} test system.

{{ if or .TestSystem.IsRosellaWindxed .TestSystem.IsRosellaNqp }}
You need to add path to rosella library on you project as a symbolic link:
    ln -s /path/to/Rosella/rosella rosella
{{ end }}
{{ if .TestSystem.IsPerl5 }}
You need to add path to parrot library on you project as a symbolic link:
    ln -s /path/to/parrot/lib lib
And parrot executable file:
    ln -s /path/to/parrot/parrot parrot
{{ end }}

    $ perl setup.pl
    $ perl setup.pl test
    # perl setup.pl install

__setup.pl__
#! perl
use strict;
use warnings;
use lib qw( t . lib ../lib ../../lib );
use Parrot::Config;
use Parrot::Test::Util 'create_tempfile';


sub pir_setup {
    my ($code, $param) = @_;

    my $stuff = sub {
        # Put the string on a file.
        my $string = shift;

        my (undef, $file) = create_tempfile(UNLINK => 1);
        open(my $out, '>', $file)
            or die "Unable to open tempfile for writing: $!";
        binmode $out;
        print $out $string;
        return $file;
    };

    # Write the input and code strings.
    my $input_file = $stuff->('tmp');
    my $code_file = $stuff->($code);

    my $parrot = ".$PConfig{slash}parrot$PConfig{exe}";
    # Slurp and compare the output.
    my $result = do {
        local $/;
        open(my $in, '-|', "$parrot $code_file < $input_file $param")
            or die "Unable to pipe output to us: $!";
        <$in>;
    };
    $result =~ s/(^==\d+==.*\n)//mg if defined $ENV{VALGRIND};
    return $result;
}

my $argv = $ARGV[0] || '';
my $result = pir_setup(<<'CODE',$argv);
.loadlib "io_ops"
# end libs
.namespace [ ]

.sub 'main' :main
        .param pmc __ARG_1
.const 'Sub' WSubId_1 = "WSubId_1"
    root_new $P1, ['parrot';'Hash']
    $P1["name"] = '{{ .Name }}'
    $P1["abstract"] = 'the {{ .Name }} compiler'
    $P1["description"] = 'the {{ .Name }} for Parrot VM.'
    $P1["authority"] = ''
    $P1["copyright_holder"] = ''
    root_new $P3, ['parrot';'ResizablePMCArray']
    assign $P3, 2
    $P3[0] = "parrot"
    $P3[1] = "{{ .Name }}"
    $P1["keywords"] = $P3
    $P1["license_type"] = ''
    $P1["license_uri"] = ''
    $P1["checkout_uri"] = ''
    $P1["browser_uri"] = ''
    $P1["project_uri"] = ''
{{ if .OPS }}
    root_new $P4, ['parrot';'Hash']
    $P4['{{ .Name }}_ops'] = 'src/ops/{{ .Name }}.ops'
    $P1["dynops"] = $P4
{{ end }}
{{if .PMC}}
    root_new $P5, ['parrot';'Hash']
    $P5['{{ .Name }}_group'] = 'src/pmc/{{ .Name }}.pmc'
    $P1["dynpmc"] = $P5
{{ end }}   
    root_new $P6, ['parrot';'Hash']
    $P6['src/gen_actions.pir'] = 'src/{{ .Name }}/Actions.pm'
    $P6['src/gen_compiler.pir'] = 'src/{{ .Name }}/Compiler.pm'
    $P6['src/gen_grammar.pir'] = 'src/{{ .Name }}/Grammar.pm'
    $P6['src/gen_runtime.pir'] = 'src/{{ .Name }}/Runtime.pm'
    $P1["pir_nqprx"] = $P6
    root_new $P7, ['parrot';'Hash']
    $P7['{{ .Name }}/{{ .Name }}.pbc'] = 'src/{{ .Name }}.pir'
    $P7['{{ .Name }}.pbc'] = '{{ .Name }}.pir'
    $P1["pbc_pir"] = $P7
    root_new $P8, ['parrot';'Hash']
    $P8['installable_{{ .Name }}'] = '{{ .Name }}.pbc'
    $P1["exe_pbc"] = $P8
    root_new $P9, ['parrot';'Hash']
    $P9['parrot-{{ .Name }}'] = '{{ .Name }}.pbc'
    $P1["installable_pbc"] = $P9
    root_new $P10, ['parrot';'ResizablePMCArray']
    assign $P10, 2
    $P10[0] = '{{ .Name }}.pbc'
    $P10[1] = 'installable_{{ .Name }}'
    $P1["inst_lang"] = $P10
    root_new $P11, ['parrot';'ResizablePMCArray']
    assign $P11, 2
    $P11[0] = "README"
    $P11[1] = "setup.pir"
    $P1["manifest_includes"] = $P11
    $P3 = __ARG_1[1]
    set $S1, $P3
    ne $S1, "test", __label_1
    WSubId_1()
  __label_1: # endif
    load_bytecode 'distutils.pir'
    get_hll_global $P2, 'setup'
    __ARG_1.'shift'()
    $P2(__ARG_1, $P1)

.end # main


.sub 'do_test' :subid('WSubId_1')
    null $I1
{{ if .TestSystem.IsPerl5 }}
    set $S1, "perl t/{{ .Name }}.t"
{{ else }}
    set $S1, "parrot-nqp t/harness"
{{ end }} 
    spawnw $I1, $S1
    exit $I1

.end # do_test

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
CODE
print $result;
{{ end }}

{{ if .BuildSystem.IsWinxed }}
__README__
Language '{{ .Name }}' with {{ .BuildSystem }} build system and {{ .TestSystem }} test system.

{{ if or .TestSystem.IsRosellaWindxed .TestSystem.IsRosellaNqp  }}
You need to add path to rosella library on you project as a symbolic link:
    ln -s /path/to/Rosella/rosella rosella
{{ end }}
{{ if .TestSystem.IsPerl5 }}
You need to add path to parrot library on you project as a symbolic link:
    ln -s /path/to/parrot/lib lib
And parrot executable file:
    ln -s /path/to/parrot/parrot parrot    
{{ end }}

    $ winxed setup.winxed
    $ winxed setup.winxed test
    # winxed setup.winxed install

__setup.winxed__
$include_const "iglobals.pasm";
$loadlib "io_ops";

function main[main](argv) {
    var parrot_{{ .Name }} = {
        "name"              : '{{ .Name }}',
        "abstract"          : 'the {{ .Name }} compiler',
        "description"       : 'the {{ .Name }} for Parrot VM.',
        "authority"         : '',
        "copyright_holder"  : '',
        "keywords"          : ["parrot","{{ .Name }}"],
        "license_type"      : '',
        "license_uri"       : '',
        "checkout_uri"      : '',
        "browser_uri"       : '',
        "project_uri"       : '',
{{ if .OPS }}
        "dynops"            : {
            '{{ .Name }}_ops'     :'src/ops/{{ .Name }}.ops'
        },
{{ end }}
{{ if .PMC }}
        "dynpmc"            : {
            '{{ .Name }}_group'   :'src/pmc/{{ .Name }}.pmc'
        },
{{ end }}
        "pir_nqprx"         : {
            'src/gen_actions.pir'   : 'src/{{ .Name }}/Actions.pm',
            'src/gen_compiler.pir'  : 'src/{{ .Name }}/Compiler.pm',
            'src/gen_grammar.pir'   : 'src/{{ .Name }}/Grammar.pm',
            'src/gen_runtime.pir'   : 'src/{{ .Name }}/Runtime.pm'},
        "pbc_pir"           : {
            '{{ .Name }}/{{ .Name }}.pbc' : 'src/{{ .Name }}.pir',
            '{{ .Name }}.pbc'       : '{{ .Name }}.pir'
        },
        "exe_pbc"           :{
            'installable_{{ .Name }}' : '{{ .Name }}.pbc'
        },
        "installable_pbc"   : {
            'parrot-{{ .Name }}'  : '{{ .Name }}.pbc'
        },
        "inst_lang"         : [ '{{ .Name }}.pbc', 'installable_{{ .Name }}' ],
        "manifest_includes" : ["README", "setup.winxed"]
    };

    if (argv[1] == "test")
    	do_test();

    load_bytecode('distutils.pir');
    using setup;

    argv.shift();
    setup(argv, parrot_{{ .Name }});
}

function do_test() {
  int result;
{{ if .TestSystem.IsPerl5 }}
  string cmd = "perl t/{{ .Name }}.t";
{{ else }}
  string cmd = "parrot-nqp t/harness";
{{ end }}
  ${ spawnw result, cmd };
  ${ exit result };
}
{{ end }}

{{ if .BuildSystem.IsNqp }}
__README__
Language '{{ .Name }}' with {{ .BuildSystem }} build system and {{ .TestSystem }} test system.

{{ if or .TestSystem.IsRosellaWindxed .TestSystem.IsRosellaNqp }}
You need to add path to rosella library on you project as a symbolic link:
    ln -s /path/to/Rosella/rosella rosella
{{ end }}
{{ if .TestSystem.IsPerl5 }}
You need to add path to parrot library on you project as a symbolic link:
    ln -s /path/to/parrot/lib lib
And parrot executable file:
    ln -s /path/to/parrot/parrot parrot   
{{ end }}

    $ parrot-nqp setup.nqp
    $ parrot-nqp setup.nqp test
    # parrot-nqp setup.nqp install
    
__setup.nqp__
#!/usr/bin/env parrot-nqp

sub MAIN() {
    # Load distutils library
    pir::load_bytecode('distutils.pbc');

    # ALL DISTUTILS CONFIGURATION IN THIS HASH
    my %config := hash(
        # General
        setup            => 'setup.nqp',
        name             => '{{ .Name }}',
        abstract         => 'the {{ .Name }} compiler',
        authority        => '',
        copyright_holder => '',
        description      => 'the {{ .Name }} for Parrot VM.',
        keywords         => < parrot {{ .Name }} >,
        license_type     => '',
        license_uri      => '',
        checkout_uri     => '',
        browser_uri      => '',
        project_uri      => '',

        # Build
        # XXX: Doesn't actually work; need distutils to make any
        #      missing directories before performing compiles
{{ if .OPS }}
        dynops			 => unflatten(
        	'{{ .Name }}_ops'						,'src/ops/{{ .Name }}.ops'
        ),
{{ end }}
{{ if .PMC }}
        dynpmc			 => unflatten(
        	'{{ .Name }}_group'					,'src/pmc/{{ .Name }}.pmc'
        ),
{{ end }}
        pir_nqprx        => unflatten(
            'src/gen_actions.pir'			, 'src/{{ .Name }}/Actions.pm',
            'src/gen_compiler.pir'    		, 'src/{{ .Name }}/Compiler.pm',
            'src/gen_grammar.pir'     		, 'src/{{ .Name }}/Grammar.pm',
            'src/gen_runtime.pir'     		, 'src/{{ .Name }}/Runtime.pm'
        ),
        pbc_pir          => unflatten(
            '{{ .Name }}/{{ .Name }}.pbc', 'src/{{ .Name }}.pir',
            '{{ .Name }}.pbc'         , '{{ .Name }}.pir'
        ),
        exe_pbc          => unflatten(
            'installable_{{ .Name }}' , '{{ .Name }}.pbc'
        ),
        installable_pbc  => unflatten(
            'parrot-{{ .Name }}'      , '{{ .Name }}.pbc'
        ),

        # Test
        prove_exec       => get_nqp(),

        # Dist/Install
        inst_lang         => <
                              {{ .Name }}/{{ .Name }}.pbc
                              installable_{{ .Name }}
                            >,
        inst_data        => glob('metadata/*.json'),
        doc_files        => glob('README doc/*/*.pod'),
    );


    # Boilerplate; should not need to be changed
    my @*ARGS := pir::getinterp__P()[2];
       @*ARGS.shift;

    if @*ARGS[0] eq "test" {
        do_test();
        pir::exit__vI(0);
    }

    setup(@*ARGS, %config);
}

# Work around minor nqp-rx limitations
sub hash     (*%h ) { %h }
sub unflatten(*@kv) { my %h; for @kv -> $k, $v { %h{$k} := $v }; %h }
sub do_test() {
{{ if .TestSystem.IsPerl5 }}
    my $run     := "perl";
    my $file    := " t/{{ .Name }}.t";
{{ else }}
    my $run     := get_nqp();
    my $file    := " t/harness";
{{ end }}
    my $result := pir::spawnw__IS($run ~ $file);
    pir::exit(+$result);
}

# Start it up!
MAIN();


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

{{ end }}

{{ if .BuildSystem.IsPir }}
__README__
Language '{{ .Name }}' with {{ .BuildSystem }} build system and {{ .TestSystem }} test system.

{{ if or .TestSystem.IsRosellaWindxed .TestSystem.IsRosellaNqp }}
You need to add path to rosella library on you project as a symbolic link:
    ln -s /path/to/Rosella/rosella rosella
{{ end }}
{{ if .TestSystem.IsPerl5 }}
You need to add path to parrot library on you project as a symbolic link:
    ln -s /path/to/parrot/lib lib
And parrot executable file:
    ln -s /path/to/parrot/parrot parrot   
{{ end }}

    $ parrot setup.pir
    $ parrot setup.pir test
    # parrot setup.pir install

__setup.pir__
#!/usr/bin/env parrot

=head1 NAME

setup.pir - Python distutils style

=head1 DESCRIPTION

No Configure step, no Makefile generated.

=head1 USAGE

    $ parrot setup.pir
    $ parrot setup.pir test
    # parrot setup.pir install

=cut

.loadlib "io_ops"
# end libs
.namespace [ ]

.sub 'main' :main
        .param pmc __ARG_1
.const 'Sub' WSubId_1 = "WSubId_1"
    root_new $P1, ['parrot';'Hash']
    $P1["name"] = '{{ .Name }}'
    $P1["abstract"] = 'the {{ .Name }} compiler'
    $P1["description"] = 'the {{ .Name }} for Parrot VM.'
    $P1["authority"] = ''
    $P1["copyright_holder"] = ''
    root_new $P3, ['parrot';'ResizablePMCArray']
    assign $P3, 2
    $P3[0] = "parrot"
    $P3[1] = "{{ .Name }}"
    $P1["keywords"] = $P3
    $P1["license_type"] = ''
    $P1["license_uri"] = ''
    $P1["checkout_uri"] = ''
    $P1["browser_uri"] = ''
    $P1["project_uri"] = ''
{{ if .OPS }}
    root_new $P4, ['parrot';'Hash']
    $P4['{{ .Name }}_ops'] = 'src/ops/{{ .Name }}.ops'
    $P1["dynops"] = $P4
{{ end }}
{{ if .PMC }}
    root_new $P5, ['parrot';'Hash']
    $P5['{{ .Name }}_group'] = 'src/pmc/{{ .Name }}.pmc'
    $P1["dynpmc"] = $P5
{{ end }}    
    root_new $P6, ['parrot';'Hash']
    $P6['src/gen_actions.pir'] = 'src/{{ .Name }}/Actions.pm'
    $P6['src/gen_compiler.pir'] = 'src/{{ .Name }}/Compiler.pm'
    $P6['src/gen_grammar.pir'] = 'src/{{ .Name }}/Grammar.pm'
    $P6['src/gen_runtime.pir'] = 'src/{{ .Name }}/Runtime.pm'
    $P1["pir_nqprx"] = $P6
    root_new $P7, ['parrot';'Hash']
    $P7['{{ .Name }}/{{ .Name }}.pbc'] = 'src/{{ .Name }}.pir'
    $P7['{{ .Name }}.pbc'] = '{{ .Name }}.pir'
    $P1["pbc_pir"] = $P7
    root_new $P8, ['parrot';'Hash']
    $P8['installable_{{ .Name }}'] = '{{ .Name }}.pbc'
    $P1["exe_pbc"] = $P8
    root_new $P9, ['parrot';'Hash']
    $P9['parrot-{{ .Name }}'] = '{{ .Name }}.pbc'
    $P1["installable_pbc"] = $P9
    root_new $P10, ['parrot';'ResizablePMCArray']
    assign $P10, 2
    $P10[0] = '{{ .Name }}.pbc'
    $P10[1] = 'installable_{{ .Name }}'
    $P1["inst_lang"] = $P10
    root_new $P11, ['parrot';'ResizablePMCArray']
    assign $P11, 2
    $P11[0] = "README"
    $P11[1] = "setup.pir"
    $P1["manifest_includes"] = $P11
    $P3 = __ARG_1[1]
    set $S1, $P3
    ne $S1, "test", __label_1
    WSubId_1()
  __label_1: # endif
    load_bytecode 'distutils.pir'
    get_hll_global $P2, 'setup'
    __ARG_1.'shift'()
    $P2(__ARG_1, $P1)

.end # main


.sub 'do_test' :subid('WSubId_1')
    null $I1
{{ if .TestSystem.IsPerl5 }}
    set $S1, "perl t/{{ .Name }}.t"
{{ else }}
    set $S1, "parrot-nqp t/harness"
{{ end }}    
    spawnw $I1, $S1
    exit $I1

.end # do_test

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

{{ end }}

__{{ .Name }}.pir__

=head1 TITLE

{{ .Name }}.pir - A {{ .Name }} compiler.

=head2 Description

This is the entry point for the {{ .Name }} compiler.

=head2 Functions

=over 4

=item main(args :slurpy)  :main

Start compilation by passing any command line C<args>
to the {{ .Name }} compiler.

=cut

.sub 'main' :main
    .param pmc args

    load_language '{{ .Name }}'

    $P0 = compreg '{{ .Name }}'
    $P1 = $P0.'command_line'(args)
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

__src/{{ .Name }}.pir__

=head1 TITLE

{{ .Name }}.pir - A {{ .Name }} compiler.

=head2 Description

This is the base file for the {{ .Name }} compiler.

This file includes the parsing and grammar rules from
the src/ directory, loads the relevant PGE libraries,
and registers the compiler under the name '{{ .Name }}'.

=head2 Functions

=over 4

=item onload()

Creates the {{ .Name }} compiler using a C<PCT::HLLCompiler>
object.

=cut

.HLL '{{ .Name }}'

{{ if .PMC }}
.loadlib '{{ .Name }}_group'
{{ end }}

.namespace []

.sub '' :anon :load
    load_bytecode 'HLL.pbc'

    .local pmc hllns, parrotns, imports
    hllns = get_hll_namespace
    parrotns = get_root_namespace ['parrot']
    imports = split ' ', 'PAST PCT HLL Regex Hash'
    parrotns.'export_to'(hllns, imports)
.end

.include 'src/gen_grammar.pir'
.include 'src/gen_actions.pir'
.include 'src/gen_compiler.pir'
.include 'src/gen_runtime.pir'

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:


__PARROT_REVISION__
{{ .Revision }}

{{ if .DOC }}
__doc/{{ .Name }}.pod__

=head1 {{ .Name }}

=head1 Design

=head1 SEE ALSO

=cut

# Local Variables:
#   fill-column:78
# End:
# vim: expandtab shiftwidth=4:

__doc/running.pod__

=head1 Running

This document describes how to use the command line {{ .Name }} program, which
...

=head2 Usage

  parrot {{ .Name }}.pbc [OPTIONS] <input>

or

  parrot-{{ .Name }}     [OPTIONS] <input>

A number of additional options are available:

  -q  Quiet mode; suppress output of summary at the end.

=cut

# Local Variables:
#   fill-column:78
# End:
# vim: expandtab shiftwidth=4:
{{ end }}

__dynext/.ignore__

__{{ .Name }}/.ignore__

__src/{{ .Name }}/Grammar.pm__
=begin overview

This is the grammar for {{ .Name }} in Perl 6 rules.

=end overview

grammar {{ .Name }}::Grammar is HLL::Grammar;

token TOP {
    <statement_list>
    [ $ || <.panic: "Syntax error"> ]
}

## Lexer items

# This <ws> rule treats # as "comment to eol".
token ws {
    <!ww>
    [ '#' \N* \n? | \s+ ]*
}

## Statements

rule statement_list { [ <statement> | <?> ] ** ';' }

rule statement {
    | <statement_control>
    | <EXPR>
}

proto token statement_control { <...> }
rule statement_control:sym<say>   { <sym> [ <EXPR> ] ** ','  }
rule statement_control:sym<print> { <sym> [ <EXPR> ] ** ','  }

## Terms

token term:sym<integer> { <integer> }
token term:sym<quote> { <quote> }

proto token quote { <...> }
token quote:sym<'> { <?[']> <quote_EXPR: ':q'> }
token quote:sym<"> { <?["]> <quote_EXPR: ':qq'> }

## Operators

INIT {
    {{ .Name }}::Grammar.O(':prec<u>, :assoc<left>',  '%multiplicative');
    {{ .Name }}::Grammar.O(':prec<t>, :assoc<left>',  '%additive');
}

token circumfix:sym<( )> { '(' <.ws> <EXPR> ')' }

token infix:sym<*>  { <sym> <O('%multiplicative, :pirop<mul>')> }
token infix:sym</>  { <sym> <O('%multiplicative, :pirop<div>')> }

token infix:sym<+>  { <sym> <O('%additive, :pirop<add>')> }
token infix:sym<->  { <sym> <O('%additive, :pirop<sub>')> }

__src/{{ .Name }}/Actions.pm__
class {{ .Name }}::Actions is HLL::Actions;

method TOP($/) {
    make PAST::Block.new( $<statement_list>.ast , :hll<{{ .Name }}>, :node($/) );
}

method statement_list($/) {
    my $past := PAST::Stmts.new( :node($/) );
    for $<statement> { $past.push( $_.ast ); }
    make $past;
}

method statement($/) {
    make $<statement_control> ?? $<statement_control>.ast !! $<EXPR>.ast;
}

method statement_control:sym<say>($/) {
    my $past := PAST::Op.new( :name<say>, :pasttype<call>, :node($/) );
    for $<EXPR> { $past.push( $_.ast ); }
    make $past;
}

method statement_control:sym<print>($/) {
    my $past := PAST::Op.new( :name<print>, :pasttype<call>, :node($/) );
    for $<EXPR> { $past.push( $_.ast ); }
    make $past;
}

method term:sym<integer>($/) { make $<integer>.ast; }
method term:sym<quote>($/) { make $<quote>.ast; }

method quote:sym<'>($/) { make $<quote_EXPR>.ast; }
method quote:sym<">($/) { make $<quote_EXPR>.ast; }

method circumfix:sym<( )>($/) { make $<EXPR>.ast; }

__src/{{ .Name }}/Compiler.pm__
class {{ .Name }}::Compiler is HLL::Compiler;

INIT {
    {{ .Name }}::Compiler.language('{{ .Name }}');
    {{ .Name }}::Compiler.parsegrammar({{ .Name }}::Grammar);
    {{ .Name }}::Compiler.parseactions({{ .Name }}::Actions);
}
__src/{{ .Name }}/Runtime.pm__
# language-specific runtime functions go here

sub print(*@args) {
    pir::print(pir::join('', @args));
    1;
}

sub say(*@args) {
    pir::say(pir::join('', @args));
    1;
}

{{ if .PMC }}
__src/pmc/{{ .Name }}.pmc__
/*

=head1 NAME

src/pmc/{{ .Name }}.pmc - {{ .Name }}

=head1 DESCRIPTION

These are the vtable functions for the {{ .Name }} class.

=cut

=head2 Helper functions

=over 4

=item INTVAL size(INTERP, PMC, PMC)

*/

#include "parrot/parrot.h"

static INTVAL
size(Interp *interp, PMC* self, PMC* obj)
{
    INTVAL retval;
    INTVAL dimension;
    INTVAL length;
    INTVAL pos;

    if (!obj || PMC_IS_NULL(obj)) {
        /* not set, so a simple 1D */
        return VTABLE_get_integer(interp, self);
    }

    retval = 1;
    dimension = VTABLE_get_integer(interp, obj);
    for (pos = 0; pos < dimension; pos++)
    {
        length = VTABLE_get_integer_keyed_int(interp, obj, pos);
        retval *= length;
    }
    return retval;
}

/*

=back

=head2 Methods

=over 4

=cut

*/

pmclass {{ .Name }}
    extends ResizablePMCArray
    provides array
    group   {{ .Name }}_group
    auto_attrs
    dynpmc
    {
/*

=item C<void class_init()>

initialize the pmc class. Store some constants, etc.

=cut

*/

    void class_init() {
    }


/*

=item C<PMC* init()>

initialize the instance.

=cut

*/

void init() {
    SUPER();
};

=item C<PMC* get()>

Returns a vector-like PMC.

=cut

*/

    METHOD PMC* get() {
        PMC* property;
        INTVAL array_t;
        STRING* property_name;

        property_name = string_from_literal(INTERP, "property");
        shape = VTABLE_getprop(INTERP, SELF, property_name);
        if (PMC_IS_NULL(property)) {
           /*
            * No property has been set yet. This means that we are
            * a simple vector
            *
            * we use our own type here. Perhaps a better way to
            * specify it?
            */
            /*
            array_t = Parrot_pmc_get_type_str(INTERP,
                string_from_literal(INTERP, "{{ .Name }}"));
            */
            property = Parrot_pmc_new(INTERP, VTABLE_type(INTERP, SELF));

            VTABLE_set_integer_native(INTERP, property, 1);
            VTABLE_set_integer_keyed_int(INTERP, property, 0,
                VTABLE_get_integer(INTERP, SELF));
            VTABLE_setprop(INTERP, SELF, property_name, property);
        }
        RETURN(PMC* property);
    }

/*

=item C<PMC* set()>

Change the existing {{ .Name }} by passing in an existing vector.

If the new property is larger than our old property, pad the end of the vector
with elements from the beginning.

If the new property is shorter than our old property, truncate elements from
the end of the vector.

=cut

*/

    METHOD set(PMC *new_property) {
        STRING* property_name;
        PMC*    old_property;
        INTVAL  old_size, new_size, pos;

        /* save the old property momentarily, set the new property */
        property_name = string_from_literal(INTERP, "property");
        old_property = VTABLE_getprop(INTERP, SELF, property_name);
        VTABLE_setprop(INTERP, SELF, property_name, new_property);

        /* how big are these property? */
        old_size = size(INTERP, SELF, old_property);
        new_size = size(INTERP, SELF, new_property);

        if (old_size > new_size) {
            for (; new_size != old_size; new_size++) {
                VTABLE_pop_pmc(INTERP, SELF);
            }
        } else if (new_size > old_size) {
            pos = 0;
            for (; new_size != old_size; old_size++, pos++) {
                VTABLE_push_pmc(INTERP, SELF,
                    VTABLE_get_pmc_keyed_int(INTERP, SELF, pos));
            }
        }
    }

/*

=back

=cut

*/

}

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
{{ end }}

{{ if .OPS }}
__src/ops/{{ .Name }}.ops__
/*
 */

BEGIN_OPS_PREAMBLE

#include "parrot/dynext.h"

END_OPS_PREAMBLE

/* Op to get the address of a PMC. */
inline op {{ .Name }}_pmc_addr(out INT, invar PMC) :base_core {
    $1 = (int) $2;
    goto NEXT();
}

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
{{ end }}

{{ if .TestSystem.IsPerl5 }}
__t/{{ .Name }}.t__
#!perl
# Copyright (C) 2001-2009, Parrot Foundation.

use strict;
use warnings;
use lib qw( t . .. lib ../lib ../../lib ../../../lib ../../../../lib );
use Test::More;
use Parrot::Test;
use Parrot::Config;

=head1 NAME

{{ .Name }}.t - test harness for Parrot {{ .Name }}

=head1 DESCRIPTION

This file is the current implementation for the {{ .Name }} test harness. The
tests are actually in simple text files, this harness given this list of
tests sources, executes all the tests.

The test source is a plain text file divided in three columns. The
columns are separated by three white spaces C<\s{3,}> or at least one
tab C<\t+>. The three columns are:

=over 4

=item B<expression>

The exact expression that is passed to the {{ .Name }} compiler as source code.
This input is pasted as a double quotes delimited string into PIR code.
This means that you can use \n to indicate newlines.

=item B<expected>

The expected result for the compiled source. Note that you can (and
probably should) use C<\n> in the expected result to represent newlines.

=item B<description>

This should be a string describing the test that is being made.

=back

Since this is supposed to be a temporary harness. We're expecting to be
able to capture the result of the compilation to write this file in PIR.
The skip and todo tests are defined in the test source file itself, so
that later when the harness is changed we don't have to bother to convert
the skip/todo tests list. So, you can simply set a test to be todo or
skipped by adding the C<SKIP> or C<TODO> keywords in the begin of the
test description. For example:

1+2+3           6       SKIP no add operation yet
1-2-3           6       TODO no minus operation yet

B<NOTE:> to add more source test files remember to update the C<@files>
array in this file.

=head1 SYNOPSIS

$ prove t/{{ .Name }}.t

=cut

# {{ .Name }} build directory
my ${{ .Name }}dir = "./";

# files to load tests from
my @files = qw(
    {{ .Name }}_basic
);

# for each test file given calculate full path
my @test_files = map { "${{ .Name }}dir/t/$_" } @files;

# calculate total number of tests
my $numtests = 0;
foreach my $f (@test_files) {
    open my $TEST_FILE, '<', $f;

    # for each line in the given files if it's not a comment line
    # or an empty line, the it's a test
    while (<$TEST_FILE>) { $numtests++ unless ( ( $_ =~ m/^#/ ) or ( $_ =~ m/^\s*$/ ) ); }
}

# set plan
plan tests => $numtests;

# main loop
foreach my $file (@test_files) {
    open my $TEST_FILE, '<', $file or die "can't open file";
    while (<$TEST_FILE>) {
        chomp;
        s/\r//g;

        # skip comment lines
        $_ =~ /^#/ and next;

        # skip empty lines
        $_ =~ /^\s*$/ and next;

        # split by tabs or 3+ spaces
        my ( $expr, $expect, $description ) = split / *\t\s*|\s{3,}/, $_;

        # do some simple checking
        if ( $expr eq '' or $expect eq '' or $description eq '' ) {
            warn "$file line $. doesn't match a valid test!";
            next;
        }

        $expr =~ s/"/\\"/g;           # Escape the '"', as $expr will be
                                      # enclosed by '"' in the generated PIR

        $expect =~ s/^'(.*)'$/$1/;    # remove surrounding quotes (for '')
        $expect =~ s/\\n/\n/g;        # treat \n as newline

        # build pir code
        my $pir_code = {{ .Name }}_template();
        $pir_code =~ s/<<EXPR>>/$expr/g;

        # check if we need to skip this test
        if ( $description =~ m/^(SKIP|skip)\s+(.*)/ ) {
        SKIP: {
                skip $2, 1;
                pir_output_is( $pir_code, $expect, $description );
            }
            next;
        }

        # check if we need to todo this test
        if ( $description =~ m/^(TODO|todo)\s+(.*)/ ) {
            my @todo = ();
            push @todo, todo => $2;
            pir_output_is( $pir_code, $expect, $description, @todo );
            next;
        }

        # no skip or todo -- run test
        pir_output_is( $pir_code, $expect, $description );
    }
}

# end
exit;

sub {{ .Name }}_template {
    return <<"PIR";
.sub 'main' :main
    load_bytecode '{{ .Name }}/{{ .Name }}.pbc'
    .local pmc compiler, code, result
    compiler = compreg '{{ .Name }}'
    code = compiler.'compile'("<<EXPR>>")
    result = code()
    say result
.end
PIR
}

=head1 AUTHOR

Nuno 'smash' Carvalho  <mestre.smash@gmail.com>

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:


__t/{{ .Name }}_basic__
# single non-negative integer
1                       1\n             positive int 1
0                       0\n             zero
2                       2\n             positive int
12345678                12345678\n      another positive int


# binary plus
1+2                     3\n             two summands
1+2+3                   6\n             three summands
1+0+3                   4\n             three summands including 0
1+2+3+4+5+6+7+8+9+10    55\n            ten summands

# binary minus
2-1                      1\n            subtraction with two operands
1-1                      0\n            subtraction with two operands
1-2                     -1\n            subtraction with two operands

{{ end }}

{{ if .TestSystem.IsRosellaWindxed }}
__t/harness__
#! parrot-nqp
INIT {
	my $rosella := pir::load_bytecode__ps('rosella/core.pbc');
	Rosella::initialize_rosella("harness");
}

my $harness := Rosella::construct(Rosella::Harness);

$harness.add_test_dirs("Winxed", "t/winxed", :recurse(1)).setup_test_run;

$harness.run();
$harness.show_results;

__t/winxed/00-sanity.t__
$load "rosella/test.pbc";
$load "{{ .Name }}/{{ .Name }}.pbc";

class Test_Winxed_Tests {
    function number_test() {
        var compiler = compreg('{{ .Name }}');
        var code= compiler.compile("1");
        var result=code();
        self.assert.equal(result,1);
        
        code= compiler.compile("0");
        result=code();
        self.assert.equal(result,0);
        
        code= compiler.compile("2");
        result=code();
        self.assert.equal(result,2);
        
        code= compiler.compile("12345678");
        result=code();
        self.assert.equal(result,12345678);
    }

    function pluses_test() {
        var compiler = compreg('{{ .Name }}');
        var code= compiler.compile("1+2");
        var result=code();
        self.assert.equal(result,3);
        
        code= compiler.compile("1+2+3");
        result=code();
        self.assert.equal(result,6);
        
        code= compiler.compile("1+0+3");
        result=code();
        self.assert.equal(result,4);
        
        code= compiler.compile("1+2+3+4+5+6+7+8+9+10");
        result=code();
        self.assert.equal(result,55);
    }
    
    function minuses_test() {
        var compiler = compreg('{{ .Name }}');
        var code= compiler.compile("2-1");
        var result=code();
        self.assert.equal(result,1);
        
        code= compiler.compile("1-1");
        result=code();
        self.assert.equal(result,0);
        
        code= compiler.compile("1-2");
        result=code();
        self.assert.equal(result,-1);
    }
}

function main[main]() {
    using Rosella.Test.test;
    test(class Test_Winxed_Tests);
}

{{ end }}

{{ if .TestSystem.IsRosellaNqp }}
__t/harness__
#! parrot-nqp
INIT {
	my $rosella := pir::load_bytecode__ps('rosella/core.pbc');
	Rosella::initialize_rosella("harness");
}

my $harness := Rosella::construct(Rosella::Harness);

$harness.add_test_dirs("NQP", "t/nqp", :recurse(1)).setup_test_run;

$harness.run();
$harness.show_results;

__t/nqp/00-sanity.t__
INIT {
    my $rosella := pir::load_bytecode__PS("rosella/core.pbc");
    Rosella::initialize_rosella("test");
    Rosella::load_bytecode_file('{{ .Name }}/{{ .Name }}.pbc', "load");
}

Rosella::Test::test(Test_NQP_Tests);

class Test_NQP_Tests {

    method number_test() {
        my $compiler := Q:PIR { %r = compreg '{{ .Name }}' };
        my $code := $compiler.compile("1");
        my $result := $code();
        $!assert.equal($result,1);
        
        $code := $compiler.compile("0");
        $result := $code();
        $!assert.equal($result,0);
        
        $code := $compiler.compile("2");
        $result := $code();
        $!assert.equal($result,2);
        
        $code := $compiler.compile("12345678");
        $result := $code();
        $!assert.equal($result,12345678);
    }
    
    method pluses_test() {
        my $compiler := Q:PIR { %r = compreg '{{ .Name }}' };
        my $code := $compiler.compile("1+2");
        my $result := $code();
        $!assert.equal($result,3);
        
        $code := $compiler.compile("1+2+3");
        $result := $code();
        $!assert.equal($result,6);
        
        $code := $compiler.compile("1+0+3");
        $result := $code();
        $!assert.equal($result,4);
        
        $code := $compiler.compile("1+2+3+4+5+6+7+8+9+10");
        $result := $code();
        $!assert.equal($result,55);
    }
    
    method minuses_test() {
        my $compiler := Q:PIR { %r = compreg '{{ .Name }}' };
        my $code := $compiler.compile("2-1");
        my $result := $code();
        $!assert.equal($result,1);
        
        $code := $compiler.compile("1-1");
        $result := $code();
        $!assert.equal($result,0);
        
        $code := $compiler.compile("1-2");
        $result := $code();
        $!assert.equal($result,-1);
    }

}

{{ end }}
__END__