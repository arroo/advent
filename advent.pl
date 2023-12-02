#!/usr/bin/env perl

use strict;
use warnings;

use DBI;
use Data::Dumper;

sub DefaultSettings {
	return {
		'driver' => 'SQLite',
		'name' => 'aoc.sqlite',
		'user' => '',
		'pass' => '',
	};
}

sub DSN {
	my ($settings) = @_;

	my ($driver, $name) = @{$settings}{qw(driver name)};

	return "DBI:$driver:dbname=$name";
}

sub ConnectToDB {
	my ($settings) = @_;

	my $dsn = DSN($settings);

	my $dbh = DBI->connect($dsn, @{$settings}{qw(user pass)}, { 'RaiseError' => 1 })
		or die $DBI::errstr;

	return $dbh;
}

sub EnsureSchema {
	my ($dbh) = @_;

	my $sth = $dbh->table_info(undef, undef, 'cookies', 'TABLE', {});

	my $rv = $sth->execute() or die $DBI::errstr;
	if ($rv < 0) {
		die $DBI::errstr;
	}

	while (my @row = $sth->fetchrow_array()) {
		print Dumper(\@row);
	}

	return;
}

sub nothing {
	my $dbh;
	# get existing tables
	my $q = q|
		tables
	|;

	my $sth = $dbh->prepare($q);

	my $rv = $dbh->execute() or die $DBI::errstr;
	if ($rv < 0) {
		die $DBI::errstr;
	}

	while (my @row = $sth->fetchrow_array()) {
		print Dumper(\@row);
	}

	# API credentials
	
}

sub main {

	my $settings = DefaultSettings();
	my $dbh = ConnectToDB($settings);

	EnsureSchema($dbh);

}

main();
