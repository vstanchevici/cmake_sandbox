
# Copyright (c) 2021, PostgreSQL Global Development Group

package Mkvcbuild;

#
# Package that generates build files for msvc build
#
# src/tools/msvc/Mkvcbuild.pm
#
use strict;
use warnings;

use Carp;
use if ($^O eq "MSWin32"), 'Win32';
use Project;
use Solution;
use Cwd;
use File::Copy;
use Config;
use VSObjectFactory;
use List::Util qw(first);

use Exporter;
our (@ISA, @EXPORT_OK);
@ISA       = qw(Exporter);
@EXPORT_OK = qw(Mkvcbuild);

my $solution;
my $libpgport;
my $libpgcommon;
my $libpgfeutils;
my $postgres;
my $libpq;
my @unlink_on_exit;

# Set of variables for modules in contrib/ and src/test/modules/
my $contrib_defines = { 'refint' => 'REFINT_VERBOSE' };
my @contrib_uselibpq =
  ('dblink', 'oid2name', 'postgres_fdw', 'vacuumlo', 'libpq_pipeline');
my @contrib_uselibpgport   = ('libpq_pipeline', 'oid2name', 'vacuumlo');
my @contrib_uselibpgcommon = ('libpq_pipeline', 'oid2name', 'vacuumlo');
my $contrib_extralibs     = { 'libpq_pipeline' => ['ws2_32.lib'] };
my $contrib_extraincludes = { 'dblink'         => ['src/backend'] };
my $contrib_extrasource   = {
	'cube' => [ 'contrib/cube/cubescan.l', 'contrib/cube/cubeparse.y' ],
	'seg'  => [ 'contrib/seg/segscan.l',   'contrib/seg/segparse.y' ],
};
my @contrib_excludes = (
	'bool_plperl',      'commit_ts',
	'hstore_plperl',    'hstore_plpython',
	'intagg',           'jsonb_plperl',
	'jsonb_plpython',   'ltree_plpython',
	'pgcrypto',         'sepgsql',
	'brin',             'test_extensions',
	'test_misc',        'test_pg_dump',
	'snapshot_too_old', 'unsafe_tests');

# Set of variables for frontend modules
my $frontend_defines = { 'initdb' => 'FRONTEND' };
my @frontend_uselibpq =
  ('pg_amcheck', 'pg_ctl', 'pg_upgrade', 'pgbench', 'psql', 'initdb');
my @frontend_uselibpgport = (
	'pg_amcheck',    'pg_archivecleanup',
	'pg_test_fsync', 'pg_test_timing',
	'pg_upgrade',    'pg_waldump',
	'pgbench');
my @frontend_uselibpgcommon = (
	'pg_amcheck',    'pg_archivecleanup',
	'pg_test_fsync', 'pg_test_timing',
	'pg_upgrade',    'pg_waldump',
	'pgbench');
my $frontend_extralibs = {
	'initdb'     => ['ws2_32.lib'],
	'pg_amcheck' => ['ws2_32.lib'],
	'pg_restore' => ['ws2_32.lib'],
	'pgbench'    => ['ws2_32.lib'],
	'psql'       => ['ws2_32.lib']
};
my $frontend_extraincludes = {
	'initdb' => ['src/timezone'],
	'psql'   => ['src/backend']
};
my $frontend_extrasource = {
	'psql' => ['src/bin/psql/psqlscanslash.l'],
	'pgbench' =>
	  [ 'src/bin/pgbench/exprscan.l', 'src/bin/pgbench/exprparse.y' ]
};
my @frontend_excludes = (
	'pgevent',    'pg_basebackup', 'pg_rewind', 'pg_dump',
	'pg_waldump', 'scripts');

sub mkvcbuild
{
	our $config = shift;

	chdir('../../..') if (-d '../msvc' && -d '../../../src');
	die 'Must run from root or msvc directory'
	  unless (-d 'src/tools/msvc' && -d 'src');

	my $vsVersion = DetermineVisualStudioVersion();

	$solution = CreateSolution($vsVersion, $config);

	our @pgportfiles = qw(
	  chklocale.c explicit_bzero.c fls.c getpeereid.c getrusage.c inet_aton.c random.c
	  srandom.c getaddrinfo.c gettimeofday.c inet_net_ntop.c kill.c open.c
	  erand48.c snprintf.c strlcat.c strlcpy.c dirmod.c noblock.c path.c
	  dirent.c dlopen.c getopt.c getopt_long.c link.c
	  pread.c preadv.c pwrite.c pwritev.c pg_bitutils.c
	  pg_strong_random.c pgcheckdir.c pgmkdirp.c pgsleep.c pgstrcasecmp.c
	  pqsignal.c mkdtemp.c qsort.c qsort_arg.c bsearch_arg.c quotes.c system.c
	  strerror.c tar.c thread.c
	  win32env.c win32error.c win32security.c win32setlocale.c win32stat.c);

	push(@pgportfiles, 'strtof.c') if ($vsVersion < '14.00');

	if ($vsVersion >= '9.00')
	{
		push(@pgportfiles, 'pg_crc32c_sse42_choose.c');
		push(@pgportfiles, 'pg_crc32c_sse42.c');
		push(@pgportfiles, 'pg_crc32c_sb8.c');
	}
	else
	{
		push(@pgportfiles, 'pg_crc32c_sb8.c');
	}

	our @pgcommonallfiles = qw(
	  archive.c base64.c checksum_helper.c
	  config_info.c controldata_utils.c d2s.c encnames.c exec.c
	  f2s.c file_perm.c file_utils.c hashfn.c ip.c jsonapi.c
	  keywords.c kwlookup.c link-canary.c md5_common.c
	  pg_get_line.c pg_lzcompress.c pgfnames.c psprintf.c relpath.c rmtree.c
	  saslprep.c scram-common.c string.c stringinfo.c unicode_norm.c username.c
	  wait_error.c wchar.c);

	if ($solution->{options}->{openssl})
	{
		push(@pgcommonallfiles, 'cryptohash_openssl.c');
		push(@pgcommonallfiles, 'hmac_openssl.c');
		push(@pgcommonallfiles, 'protocol_openssl.c');
	}
	else
	{
		push(@pgcommonallfiles, 'cryptohash.c');
		push(@pgcommonallfiles, 'hmac.c');
		push(@pgcommonallfiles, 'md5.c');
		push(@pgcommonallfiles, 'sha1.c');
		push(@pgcommonallfiles, 'sha2.c');
	}

	our @pgcommonfrontendfiles = (
		@pgcommonallfiles, qw(fe_memutils.c
		  logging.c restricted_token.c sprompt.c));

	our @pgcommonbkndfiles = @pgcommonallfiles;

	our @pgfeutilsfiles = qw(
	  archive.c cancel.c conditional.c connect_utils.c mbprint.c option_utils.c
	  parallel_slot.c print.c psqlscan.l psqlscan.c query_utils.c simple_list.c
	  string_utils.c recovery_gen.c);

	$libpgport = $solution->AddProject('libpgport', 'lib', 'misc');
	$libpgport->AddDefine('FRONTEND');
	$libpgport->AddFiles('src/port', @pgportfiles);

	$libpgcommon = $solution->AddProject('libpgcommon', 'lib', 'misc');
	$libpgcommon->AddDefine('FRONTEND');
	$libpgcommon->AddFiles('src/common', @pgcommonfrontendfiles);

	$libpq = $solution->AddProject('libpq', 'lib', 'interfaces',
		'src/interfaces/libpq');
	$libpq->AddDefine('FRONTEND');
	$libpq->AddDefine('UNSAFE_STAT_OK');
	$libpq->AddIncludeDir('src/port');
	$libpq->AddLibrary('secur32.lib');
	$libpq->AddLibrary('ws2_32.lib');
	$libpq->AddLibrary('wldap32.lib') if ($solution->{options}->{ldap});
	$libpq->UseDef('src/interfaces/libpq/libpqdll.def');
	$libpq->AddReference($libpgcommon, $libpgport);

	# The OBJS scraper doesn't know about ifdefs, so remove appropriate files
	# if building without OpenSSL.
	if (!$solution->{options}->{openssl})
	{
		$libpq->RemoveFile('src/interfaces/libpq/fe-secure-common.c');
		$libpq->RemoveFile('src/interfaces/libpq/fe-secure-openssl.c');
	}
	if (!$solution->{options}->{gss})
	{
		$libpq->RemoveFile('src/interfaces/libpq/fe-gssapi-common.c');
		$libpq->RemoveFile('src/interfaces/libpq/fe-secure-gssapi.c');
	}


	$solution->Save();
	return $solution->{vcver};
}

#####################
# Utility functions #
#####################

# Add a simple frontend project (exe)
sub AddSimpleFrontend
{
	my $n        = shift;
	my $uselibpq = shift;

	my $p = $solution->AddProject($n, 'exe', 'bin');
	$p->AddDir('src/bin/' . $n);
	$p->AddReference($libpgfeutils, $libpgcommon, $libpgport);
	if ($uselibpq)
	{
		$p->AddIncludeDir('src/interfaces/libpq');
        $p->AddLibrary('secur32.lib');
        $p->AddLibrary('ws2_32.lib');
        $p->AddLibrary('wldap32.lib') if ($solution->{options}->{ldap});
		$p->AddReference($libpq);
	}

	# Adjust module definition using frontend variables
	AdjustFrontendProj($p);

	return $p;
}

# Add a simple transform module
sub AddTransformModule
{
	my $n            = shift;
	my $n_src        = shift;
	my $pl_proj_name = shift;
	my $pl_src       = shift;
	my $type_name    = shift;
	my $type_src     = shift;

	my $type_proj = undef;
	if ($type_name)
	{
		foreach my $proj (@{ $solution->{projects}->{'contrib'} })
		{
			if ($proj->{name} eq $type_name)
			{
				$type_proj = $proj;
				last;
			}
		}
		die "could not find base module $type_name for transform module $n"
		  if (!defined($type_proj));
	}

	my $pl_proj = undef;
	foreach my $proj (@{ $solution->{projects}->{'PLs'} })
	{
		if ($proj->{name} eq $pl_proj_name)
		{
			$pl_proj = $proj;
			last;
		}
	}
	die "could not find PL $pl_proj_name for transform module $n"
	  if (!defined($pl_proj));

	my $p = $solution->AddProject($n, 'dll', 'contrib', $n_src);
	for my $file (glob("$n_src/*.c"))
	{
		$p->AddFile($file);
	}
	$p->AddReference($postgres);

	# Add PL dependencies
	$p->AddIncludeDir($pl_src);
	$p->AddReference($pl_proj);
	$p->AddIncludeDir($pl_proj->{includes});
	foreach my $pl_lib (@{ $pl_proj->{libraries} })
	{
		$p->AddLibrary($pl_lib);
	}

	# Add base module dependencies
	if ($type_proj)
	{
		$p->AddIncludeDir($type_src);
		$p->AddIncludeDir($type_proj->{includes});
		foreach my $type_lib (@{ $type_proj->{libraries} })
		{
			$p->AddLibrary($type_lib);
		}
		$p->AddReference($type_proj);
	}

	return $p;
}

# Add a simple contrib project
sub AddContrib
{
	my $subdir = shift;
	my $n      = shift;
	my $mf     = Project::read_file("$subdir/$n/Makefile");

	if ($mf =~ /^MODULE_big\s*=\s*(.*)$/mg)
	{
		my $dn = $1;
		my $proj = $solution->AddProject($dn, 'dll', 'contrib', "$subdir/$n");
		$proj->AddReference($postgres);
		AdjustContribProj($proj);
	}
	elsif ($mf =~ /^MODULES\s*=\s*(.*)$/mg)
	{
		foreach my $mod (split /\s+/, $1)
		{
			my $proj =
			  $solution->AddProject($mod, 'dll', 'contrib', "$subdir/$n");
			my $filename = $mod . '.c';
			$proj->AddFile("$subdir/$n/$filename");
			$proj->AddReference($postgres);
			AdjustContribProj($proj);
		}
	}
	elsif ($mf =~ /^PROGRAM\s*=\s*(.*)$/mg)
	{
		my $proj = $solution->AddProject($1, 'exe', 'contrib', "$subdir/$n");
		AdjustContribProj($proj);
	}
	else
	{
		croak "Could not determine contrib module type for $n\n";
	}

	# Are there any output data files to build?
	GenerateContribSqlFiles($n, $mf);
	return;
}

sub GenerateContribSqlFiles
{
	my $n  = shift;
	my $mf = shift;
	$mf =~ s{\\\r?\n}{}g;
	if ($mf =~ /^DATA_built\s*=\s*(.*)$/mg)
	{
		my $l = $1;

		# Strip out $(addsuffix) rules
		if (index($l, '$(addsuffix ') >= 0)
		{
			my $pcount = 0;
			my $i;
			for ($i = index($l, '$(addsuffix ') + 12; $i < length($l); $i++)
			{
				$pcount++ if (substr($l, $i, 1) eq '(');
				$pcount-- if (substr($l, $i, 1) eq ')');
				last      if ($pcount < 0);
			}
			$l =
			  substr($l, 0, index($l, '$(addsuffix ')) . substr($l, $i + 1);
		}

		foreach my $d (split /\s+/, $l)
		{
			my $in  = "$d.in";
			my $out = "$d";

			if (Solution::IsNewer("contrib/$n/$out", "contrib/$n/$in"))
			{
				print "Building $out from $in (contrib/$n)...\n";
				my $cont = Project::read_file("contrib/$n/$in");
				my $dn   = $out;
				$dn =~ s/\.sql$//;
				$cont =~ s/MODULE_PATHNAME/\$libdir\/$dn/g;
				my $o;
				open($o, '>', "contrib/$n/$out")
				  || croak "Could not write to contrib/$n/$d";
				print $o $cont;
				close($o);
			}
		}
	}
	return;
}

sub AdjustContribProj
{
	my $proj = shift;
	AdjustModule(
		$proj,                    $contrib_defines,
		\@contrib_uselibpq,       \@contrib_uselibpgport,
		\@contrib_uselibpgcommon, $contrib_extralibs,
		$contrib_extrasource,     $contrib_extraincludes);
	return;
}

sub AdjustFrontendProj
{
	my $proj = shift;
	AdjustModule(
		$proj,                     $frontend_defines,
		\@frontend_uselibpq,       \@frontend_uselibpgport,
		\@frontend_uselibpgcommon, $frontend_extralibs,
		$frontend_extrasource,     $frontend_extraincludes);
	return;
}

sub AdjustModule
{
	my $proj                  = shift;
	my $module_defines        = shift;
	my $module_uselibpq       = shift;
	my $module_uselibpgport   = shift;
	my $module_uselibpgcommon = shift;
	my $module_extralibs      = shift;
	my $module_extrasource    = shift;
	my $module_extraincludes  = shift;
	my $n                     = $proj->{name};

	if ($module_defines->{$n})
	{
		foreach my $d ($module_defines->{$n})
		{
			$proj->AddDefine($d);
		}
	}
	if (grep { /^$n$/ } @{$module_uselibpq})
	{
		$proj->AddIncludeDir('src\interfaces\libpq');
        $proj->AddLibrary('secur32.lib');
        $proj->AddLibrary('ws2_32.lib');
        $proj->AddLibrary('wldap32.lib') if ($solution->{options}->{ldap});		
		$proj->AddReference($libpq);
	}
	if (grep { /^$n$/ } @{$module_uselibpgport})
	{
		$proj->AddReference($libpgport);
	}
	if (grep { /^$n$/ } @{$module_uselibpgcommon})
	{
		$proj->AddReference($libpgcommon);
	}
	if ($module_extralibs->{$n})
	{
		foreach my $l (@{ $module_extralibs->{$n} })
		{
			$proj->AddLibrary($l);
		}
	}
	if ($module_extraincludes->{$n})
	{
		foreach my $i (@{ $module_extraincludes->{$n} })
		{
			$proj->AddIncludeDir($i);
		}
	}
	if ($module_extrasource->{$n})
	{
		foreach my $i (@{ $module_extrasource->{$n} })
		{
			print "Files $i\n";
			$proj->AddFile($i);
		}
	}
	return;
}

END
{
	unlink @unlink_on_exit;
}

1;
