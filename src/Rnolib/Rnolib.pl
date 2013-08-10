#! /usr/bin/env perl
use Cwd;

my $location = getcwd();
my $cmdtorun = $ARGV[0];
my $scripts = $ARGV[1];
my $unique = $ARGV[2];

print "Starting to run <$cmdtorun> <$scripts> <$unique>\n";
system("df -k");
system("pwd");

my $jobtar = "$unique.tar.gz";

# note this brings in all job related input files
# but not the shared files across jobs.
print "Tar file to extract is <$jobtar>\n";
if(-f "$jobtar") {
	print "Tar files exists. Extract....\n";
	system("tar -zxvf $unique.tar.gz");
}

# do we have dataset shared files to extract?
if(-f "sharedfiles.tar.gz") {
	print "Shared files exist. Extracting.....\n";
	system("tar -zxvf sharedfiles.tar.gz");
	print "Done extracting\n";
}

# do we have an ordered list of libraries to install?
if(-f "LIBRARIES") {
	$ENV{R_LIBS} = "$location/R_libs";
	if(!(-f "LIBRARIES.tar.gz")) {
		die "Library request missing libraries to install!!!\n";
	}
	system("tar -zxvf LIBRARIES.tar.gz");
	open(LB,"<LIBRARIES") or die "Failed to open LIBRARIES:$!\n";
	while(<LB>) {
		chomp();
		print "Installing library $_\n";
		system("./R CMD INSTALL $_");
	}
	close(LB);
	$ENV{R_ENVIRON} = "./rstuff";

	open(RS, ">rstuff") or die "Failed to create R stuff<rstuff>:$!\n";
	print RS "R_LIBS = $location/R_libs\n";
	close(RS);
}

print "Running here: ";
system("hostname");
system("ls -l");

$cmdtorun = "$cmdtorun --no-save ./$scripts $unique";
print "about to execute <<$cmdtorun>>\n";
$res = system("$cmdtorun");

print "Done Running $unique $location Result was <$res>\n";
if($res != 0) {
	print "Non-zero job status so exit(1)....\n";
	system("touch CODEBLOWUP");
	exit(1);
}

$here = getcwd();

print "Results are:";
system("ls -l");
