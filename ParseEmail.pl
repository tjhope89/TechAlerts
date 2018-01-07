#! /usr/bin/perl

use lib "/usr/local/share/perl5";
require "../bin/common-finance.pl"; 
use HTML::Parse;
use HTML::FormatText;
use  HTML::TableExtract;
use DateTime::Format::Strptime; 
use DBI;
use DBD::mysql;

# HTTP Header
print "Content-type: text/html \n\n";

#CONFIG VARIABLES
$platform="mysql";
$database="invest";
$host="localhost";
$port="3306";
#$tablename="z1filtered";
$user="tim";
$pw="jus05tin";

#DATASOURCE NAME
$dsn="dbi:$platform:$database:$host:$port";
#print $dsn . "\n";

# PERL DBI CONNECT
$dbstore=DBI->connect($dsn, $user, $pw) or die "Unable to connect : DBI::errstr\n";


@flist=`ls TechAlerts*.html`;
for ($i=0; $i<@flist; $i++) {
  $ifile=@flist[$i];
  chomp($ifile);
  print "Processing $ifile...\n";
  ParseAlert();
}

sub ParseAlert {

  my $te = new HTML::TableExtract();
  $te->parse_file($ifile);
  my ($ts,$row);

  foreach $ts ($te->table_states) {
    foreach $row ($ts->rows) {
        if ( @$row[0] =~ /Technical Alerts -/ ) {
            ($tt, $yr, $mn, $dy) = split("-", @$row[0]);
            chomp $dy;
            $rdt=$yr . "-" . $mn . "-" . substr($dy,0,2);
            $rdt=~s/ //g ;
	    $rdt=add_days($rdt);
        }
	if ( @$row[6] =~ /Term Bullish/ ) {
            $pat=`sed -f ../bin/term.sed <<< "@$row[3]"`;
            chomp $pat;
            $opp=`sed -f ../bin/term.sed <<< "@$row[6]"`;
            chomp $opp;
            $rnsql="insert into recog_new values ('" . $rdt . "','" . @$row[0] . "','" . $pat . "','" . $opp . "',0);";
            $rssql="insert into recog_sell values ('" . $rdt . "','" . @$row[0] . "','" . $pat . "',0,0,0,0);";
           print $rnsql . "\n";
           print $rssql . "\n";
#           $stmt1=$dbstore->prepare($rnsql);
#           $stmt1->execute();
#           $stmt2=$dbstore->prepare($rssql);
#           $stmt2->execute();

        }
     }
  }
  return ;
}

