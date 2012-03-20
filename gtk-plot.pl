#!/usr/bin/perl
use strict;
use warnings;

use Glib qw/TRUE FALSE/; # import TRUE and FALSE constants for readability
use Gtk2 '-init';
my $window = Gtk2::Window->new ('toplevel'); # create a new window

# Here we connect the "destroy" event to a signal handler.
# This event occurs when we call Gtk2::Widget::destroy on the window.
# Perl supports anonymous subs, so we can use one of them for one line
# callbacks.
$window->signal_connect (destroy => sub { Gtk2->main_quit; });

# Sets the border width of the window.
$window->set_border_width (10);

$window->set_position ('center');

# Основной контейнер
my $vbox = Gtk2::VBox->new (FALSE, 5);

# Контейнер для строки с именем выходного файла
my $hboutf = Gtk2::HBox->new (FALSE, 5);

my $lname = Gtk2::Label->new_with_mnemonic ("Name: ");
my $ename = Gtk2::Entry->new ();
my $lformat = Gtk2::Label->new_with_mnemonic ("Format: ");
my $fc = Gtk2::ComboBox->new_text;
$fc->append_text ("jpeg");
$fc->append_text ("png");
$fc->append_text ("bmp");
$fc->set_active (0);
ename_update ();
my $fname = $ename->get_text . "." . $fc->get_active_text;

$hboutf->pack_start ($lname, FALSE, FALSE, 0);
$hboutf->pack_start ($ename, TRUE, TRUE, 0);
$hboutf->pack_start ($lformat, FALSE, FALSE, 0);
$hboutf->pack_start ($fc, FALSE, FALSE, 0);

# Контейнер для указания размера графика
my $hbsize = Gtk2::HBox->new (FALSE, 5);
my $lsize = Gtk2::Label->new_with_mnemonic ("Size: ");
my $ew = Gtk2::ComboBoxEntry->new_text;
$ew->append_text ("800");
$ew->append_text ("1024");
$ew->append_text ("2048");
$ew->set_active (0);
#$eh->set_size_request (60, 20);

my $eh = Gtk2::ComboBoxEntry->new_text;
$eh->append_text ("600");
$eh->append_text ("768");
$eh->append_text ("1024");
$eh->set_active (0);
#$ew->set_size_request (60, 20);


#my $spacer = Gtk2::Label->new_with_mnemonic (" ");
#$spacer->set_size_request (100, 0);

$hbsize->pack_start ($lsize, FALSE, FALSE, 0);
$hbsize->pack_start ($ew, FALSE, FALSE, 0);
$hbsize->pack_start (Gtk2::Label->new_with_mnemonic ("x"), FALSE, FALSE, 0);
$hbsize->pack_start ($eh, FALSE, FALSE, 0);
# $hbsize->pack_start ($spacer, TRUE, TRUE, 0);

# Контейнер для указания входного файла
my $hbinf = Gtk2::HBox->new (FALSE, 5);
my $linf = Gtk2::Label->new_with_mnemonic ("Input data file");
my $binf = Gtk2::FileChooserButton->new ("select a file", "open");
$binf->set_filename ("data");
$hbinf->pack_start ($linf, FALSE, FALSE, 0);
$hbinf->pack_start ($binf, TRUE, TRUE, 0);

my $imgframe = Gtk2::Frame->new ("Preview");
$imgframe->set_border_width (5);
my $prev = Gtk2::Image->new;
$imgframe->add ($prev);

my $mb = Gtk2::Button->new ("Mail to");
$mb->signal_connect (clicked => sub { show_mail_dialog ($window, $fname)});
$mb->set_sensitive (FALSE);

my $button = Gtk2::Button->new ("Create plot");
$button->signal_connect (clicked => sub {
    my ($button) = @_;
    my $name = $ename->get_text ();
    my $format = $fc->get_active_text ();
    $fname = "$name.$format";
    my $height = $eh->get_active_text ();
    my $width = $ew->get_active_text ();
    my $in = $binf->get_filename ();
    my $status = system ("sh plot-graph.sh -o $fname -f $format -i $in -w $width -h $height");
    print "$status\n";
    $prev->set_from_pixbuf (Gtk2::Gdk::Pixbuf->new_from_file_at_size("$fname", 480, 320));
    $imgframe->show ();
    $mb->set_sensitive (TRUE);
    ename_update ();
			 });

my $qb = Gtk2::Button->new_from_stock ('gtk-quit');
$qb->signal_connect (clicked => sub { Gtk2->main_quit; });

my $hbb = Gtk2::HBox->new (FALSE, 5);
$hbb->pack_start ($mb, FALSE, FALSE, 0);
$hbb->pack_end ($qb, FALSE, FALSE, 0);
$hbb->pack_end ($button, FALSE, FALSE, 0);

$vbox->pack_start ($hboutf, FALSE, FALSE, 0);
$vbox->pack_start ($hbsize, FALSE, FALSE, 0);
$vbox->pack_start ($hbinf, FALSE, FALSE, 0);
$vbox->pack_start ($imgframe, TRUE, TRUE, 0);
$vbox->pack_start ($hbb, FALSE, FALSE, 0);
$vbox->show_all ();
$imgframe->hide ();

$window->add ($vbox);
$window->show;

Gtk2->main;

0;

sub ename_update {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    $year += 1900;
    ($sec =~ m/\d{2}/)||($sec = "0".$sec);
    ($min =~ m/\d{2}/)||($min = "0".$min);
    ($hour =~ m/\d{2}/)||($hour = "0".$hour);
    $mon = $mon +1;
    ($mon =~ m/\d{2}/)||($mon = "0".$mon);
    $ename->set_text ("image-$mday-$mon-$year\_$hour:$min:$sec");
}

sub show_mail_dialog {
    my ($parent, $filename) = @_;
    print "$filename\n";
    my $dialog = Gtk2::Dialog->new ("Mail to...", $parent, [qw/modal destroy-with-parent/],
			    'gtk-ok' => 'accept',
			    'gtk-cancel' => 'reject');
    my $vbox = $dialog->vbox;
    my $counter = 1;

    my $h1 = Gtk2::HBox->new (FALSE, 5);
    my $l1 = Gtk2::Label->new_with_mnemonic ("Mail $counter: ");

    my $e1 = Gtk2::ComboBoxEntry->new_text;
    $e1->grab_focus;

    open FILE, ">>".$ENV{HOME}."/.plot_mail_cache" or die $!;
    open FILE, "<".$ENV{HOME}."/.plot_mail_cache" or die $!;
    my @mcache = <FILE>;

    # удаление переводов строк
    foreach (@mcache) {
	$_ =~ s/\R//g;
	$e1->append_text ($_);
    }
    close FILE;

    $h1->pack_start ($l1, FALSE, FALSE, 0);
    $h1->pack_start ($e1, TRUE, TRUE, 0);
    $h1->show_all;

    $vbox->pack_start ($h1, FALSE, FALSE, 0);

    my %mhash = ($counter => [\$h1, \$e1]);

    my $addb = Gtk2::Button->new_from_stock ('gtk-add');
    my $delb = Gtk2::Button->new_from_stock ('gtk-delete');
    $delb->set_sensitive (FALSE);

    $addb->signal_connect (clicked => sub {
	$counter++;
	if ($counter > 1) { $delb->set_sensitive (TRUE); }
	my $hbox = Gtk2::HBox->new (FALSE, 5);
	my $label = Gtk2::Label->new_with_mnemonic ("Mail $counter: ");
	my $entry = Gtk2::ComboBoxEntry->new_text;

	foreach (@mcache) {
	    $entry->append_text ($_);
	}

	$hbox->pack_start ($label, FALSE, FALSE, 0);
	$hbox->pack_start ($entry, TRUE, TRUE, 0);
	$hbox->show_all;

	$vbox->pack_start ($hbox, FALSE, FALSE, 0);
	$entry->grab_focus;

	$mhash{$counter} = [\$hbox, \$entry];
			   });

    $delb->signal_connect (clicked => sub {
	my $dhb = $mhash{$counter}[0];
	$$dhb->destroy ();
	$dialog->resize (1, 1);
	delete ($mhash{$counter});
	$counter--;
	if ($counter <= 1) { $delb->set_sensitive (FALSE); }
			   });

    my $hb1 = Gtk2::HBox->new (FALSE, 5);
    $hb1->pack_end ($addb, FALSE, FALSE, 0);
    $hb1->pack_end ($delb, FALSE, FALSE, 0);
    $vbox->pack_end ($hb1, FALSE, FALSE, 0);
    $vbox->show_all ();
    if ('accept' eq $dialog->run) {
	my @marr = (); # массив выбранных почтовых ящиков
	for (my $i = 1; $i <= $counter; $i++) {
	    my $mail = $mhash{$i}[1];
	    push (@marr, $$mail->get_active_text);
	}
	# преобразование массива в строку
	my $str = "<" . join (">,<", @marr) . ">";
	print "$str\n";

	# Удаление дубликатов из массива и его сортировка
	push (@mcache, @marr);
	my %hash   = map { $_, 1 } @mcache;
	@mcache = keys %hash;
	@mcache = sort (@mcache);

	# запись массива в файл
	open FILE, ">", $ENV{HOME}."/.plot_mail_cache" or die $!;
	foreach (@mcache) {
	    print FILE $_."\n";
	}
	close FILE;

	print "mail sent\n";
    } else {
	print "canceled\n";
    }
    $dialog->destroy;
}
