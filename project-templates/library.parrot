{{ if .BuildSystem.IsPerl5 }}
__README__
Library '{{ .Name }}' with {{ .BuildSystem }} build system and {{ .TestSystem }} test system.

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
    $P1["abstract"] = 'the {{ .Name }} library'
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
    root_new $P4, ['parrot';'Hash']
    $P4['{{ .Name }}/{{ .Name }}.pbc'] = 'src/{{ .Name }}.pir'
    $P1["pbc_pir"] = $P4
    root_new $P5, ['parrot';'ResizablePMCArray']
    assign $P5, 1
    $P5[0] = '{{ .Name }}/{{ .Name }}.pbc'
    $P1["inst_lib"] = $P5
    root_new $P6, ['parrot';'ResizablePMCArray']
    assign $P6, 2
    $P6[0] = "README"
    $P6[1] = "setup.pl"
    $P1["manifest_includes"] = $P6
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
{{ if .TestSystem.IsPerl5}}
    set $S1, "perl t/{{ .Name }}.t"
{{ else }}
    set $S1, "parrot-nqp t/harness"
{{ end }} 
    spawnw $I1, $S1
    exit $I1

.end # do_test
CODE

print $result;

{{ end }}

{{ if .BuildSystem.IsWinxed }}
__README__
Library '{{ .Name }}' with {{ .BuildSystem }} build system and {{ .TestSystem }} test system.

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

    $ winxed setup.winxed
    $ winxed setup.winxed test
    # winxed setup.winxed install

__setup.winxed__
$include_const "iglobals.pasm";
$loadlib "io_ops";

function main[main](argv) {
    var parrot_{{ .Name }} = {
        "name"              : '{{ .Name }}',
        "abstract"          : 'the {{ .Name }} library',
        "description"       : 'the {{ .Name }} for Parrot VM.',
        "authority"         : '',
        "copyright_holder"  : '',
        "keywords"          : ["parrot","{{ .Name }}"],
        "license_type"      : '',
        "license_uri"       : '',
        "checkout_uri"      : '',
        "browser_uri"       : '',
        "project_uri"       : '',
        "pbc_pir"           : {
            '{{ .Name }}/{{ .Name }}.pbc' : 'src/{{ .Name }}.pir'
        },
        "inst_lib"         : [ '{{ .Name }}/{{ .Name }}.pbc' ],
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
{{ if .TestSystem.IsPerl5}}
  string cmd = "perl t/{{ .Name }}.t";
{{ else }}
  string cmd = "parrot-nqp t/harness";
{{ end }}
  ${ spawnw result, cmd };
  ${ exit result };
}
{{ end }}

{{ if .BuildSystem.IsNqp}}
__README__
Library '{{ .Name }}' with {{ .BuildSystem }} build system and {{ .TestSystem }} test system.

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
        abstract         => 'the {{ .Name }} library',
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
        pbc_pir          => unflatten(
            '{{ .Name }}/{{ .Name }}.pbc', 'src/{{ .Name }}.pir'
        ),

        # Test
        prove_exec       => get_nqp(),

        # Dist/Install
        inst_lib         => <
                              {{ .Name }}/{{ .Name }}.pbc
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
{{ if .TestSystem.IsPerl5}}
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
Library '{{ .Name }}' with {{ .BuildSystem }} build system and {{ .TestSystem }} test system.

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

    $ parrot setup.pir build
    $ parrot setup.pir test
    $ sudo parrot setup.pir install

=cut

.loadlib "io_ops"
# end libs
.namespace [ ]

.sub 'main' :main
        .param pmc __ARG_1
.const 'Sub' WSubId_1 = "WSubId_1"
    root_new $P1, ['parrot';'Hash']
    $P1["name"] = '{{ .Name }}'
    $P1["abstract"] = 'the {{ .Name }} library'
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
    root_new $P4, ['parrot';'Hash']
    $P4['{{ .Name }}/{{ .Name }}.pbc'] = 'src/{{ .Name }}.pir'
    $P1["pbc_pir"] = $P4
    root_new $P5, ['parrot';'ResizablePMCArray']
    assign $P5, 1
    $P5[0] = '{{ .Name }}/{{ .Name }}.pbc'
    $P1["inst_lib"] = $P5
    root_new $P6, ['parrot';'ResizablePMCArray']
    assign $P6, 2
    $P6[0] = "README"
    $P6[1] = "setup.pir"
    $P1["manifest_includes"] = $P6
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
{{ if .TestSystem.IsPerl5}}
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

__src/{{ .Name }}.pir__

# Copyright (C) 2009, Parrot Foundation.

=head1 NAME

{{ .Name }}/{{ .Name }}.pir - the ANSI C rand pseudorandom number generator

=head1 DESCRIPTION

The C<rand> function computes a sequence of pseudo-random integers in the
range 0 to C<RAND_MAX>.

The C<srand> function uses the argument as a seed for a new sequence of
pseudo-random numbers to be returned by subsequent calls to C<rand>.
If C<srand> is then called with the same seed value, the sequence of
pseudo-random numbers shall be repeated. If C<rand> is called before any calls
to C<srand> have been made, the same sequence shall be generated as when
C<srand> is first called with a seed value of 1.

Portage of the following C implementation, given as example by ISO/IEC 9899:1999.

  static unsigned long int next = 1;
  //
  int rand(void)
  {
      next = next * 1103515245 + 12345;
      return (unsigned int)(next/65536) % 32768;
  }
  //
  void srand(unsigned int seed)
  {
      next = seed;
  }

=head1 USAGE

    load_bytecode '{{ .Name }}/{{ .Name }}.pbc'
    .local pmc rand
    rand = get_global [ '{{ .Name }}'; '{{ .Name }}' ], 'rand'
    .local pmc srand
    srand = get_global [ '{{ .Name }}'; '{{ .Name }}' ], 'srand'
    .local int seed
    srand(seed)
    $I0 = rand()
    .local pmc rand_max
    rand_max = get_global [ '{{ .Name }}'; '{{ .Name }}' ], 'RAND_MAX'
    .local int RAND_MAX
    RAND_MAX = rand_max()

=cut

.namespace [ '{{ .Name }}'; '{{ .Name }}' ]

.sub '__onload' :anon :load
    $P0 = box 1
    set_global 'next', $P0
.end

.sub 'RAND_MAX'
    .return (32767)
.end

.sub 'rand'
    $P0 = get_global 'next'
    $I0 = $P0
    $I0 *= 1103515245
    $I0 += 12345
    ge $I0, 0, noadj
    $I0 += 0x80000000 # not hit for 64bit int
    goto done
noadj:
    $I0 &= 0xffffffff # noop for 32bit int
done:
    set $P0, $I0
    $I0 /= 65536
    $I0 %= 32768
    .return ($I0)
.end

.sub 'srand'
    .param int seed
    $P0 = get_global 'next'
    set $P0, seed
.end


=head1 AUTHORS

Francois Perrad

=cut


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:


__PARROT_REVISION__
[% Revision %]

__{{ .Name }}/.ignore__

{{ if .TestSystem.IsPerl5}}
__t/{{ .Name }}.t__
#! perl
use strict;
use warnings;
use lib qw( t . lib ../lib ../../lib );

use Test::More;
use Parrot::Test tests => 1;

pir_output_is( <<'CODE', <<'OUT', "{{ .Name }};{{ .Name }}" );
.sub main :main
    load_bytecode '{{ .Name }}/{{ .Name }}.pbc'

    test_rand()
    test_srand()
    test_rand_max()
.end

.sub test_rand
    .local pmc rand
    rand = get_global [ '{{ .Name }}'; '{{ .Name }}' ], 'rand'
    $I0 = rand()
.end

.sub test_srand
	.local pmc srand
    srand = get_global [ '{{ .Name }}'; '{{ .Name }}' ], 'srand'
    srand(1)
.end

.sub test_rand_max
    .local pmc rand_max
    rand_max = get_global [ '{{ .Name }}'; '{{ .Name }}' ], 'RAND_MAX'
    $I0 = rand_max()
.end
CODE
OUT

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

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
    function test_rand() {
        using {{ .Name }}.{{ .Name }}.rand;
        int rnd = rand();
        self.assert.defined(rnd);
    }

    function test_srand() {
        using {{ .Name }}.{{ .Name }}.srand;
        int seed;
        srand(seed);
    }

    function test_rand_max() {
        using {{ .Name }}.{{ .Name }}.RAND_MAX;
        self.assert.equal(RAND_MAX(),32767);
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

    method test_rand() {
        my $rnd := {{ .Name }}::{{ .Name }}::rand();
        $!assert.defined($rnd);
    }

    method test_srand() {
        my $seed;
        {{ .Name }}::{{ .Name }}::srand($seed);
    }

    method test_rand_max() {
        $!assert.equal({{ .Name }}::{{ .Name }}::RAND_MAX(),32767);
    }

}

{{ end }}
__END__