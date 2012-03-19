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
ename_update ();
my $lformat = Gtk2::Label->new_with_mnemonic ("Format: ");
my $fc = Gtk2::ComboBox->new_text;
$fc->append_text ("png");
$fc->append_text ("jpeg");
$fc->append_text ("bmp");
$fc->set_active (0);

$hboutf->pack_start ($lname, FALSE, FALSE, 0);
$hboutf->pack_start ($ename, TRUE, TRUE, 0);
$hboutf->pack_start ($lformat, FALSE, FALSE, 0);
$hboutf->pack_start ($fc, FALSE, FALSE, 0);

# Контейнер для указания размера графика
my $hbsize = Gtk2::HBox->new (FALSE, 5);
my $lsize = Gtk2::Label->new_with_mnemonic ("Size: ");
my $eh = Gtk2::ComboBoxEntry->new_text;
$eh->append_text ("800");
$eh->append_text ("1024");
$eh->append_text ("2048");
$eh->set_active (0);
#$eh->set_size_request (60, 20);

my $ew = Gtk2::ComboBoxEntry->new_text;
$ew->append_text ("600");
$ew->append_text ("768");
$ew->append_text ("1024");
$ew->set_active (0);
#$ew->set_size_request (60, 20);


#my $spacer = Gtk2::Label->new_with_mnemonic (" ");
#$spacer->set_size_request (100, 0);

$hbsize->pack_start ($lsize, FALSE, FALSE, 0);
$hbsize->pack_start ($eh, FALSE, FALSE, 0);
$hbsize->pack_start (Gtk2::Label->new_with_mnemonic ("x"), FALSE, FALSE, 0);
$hbsize->pack_start ($ew, FALSE, FALSE, 0);
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

# Creates a new button with a label "Hello World".
my $button = Gtk2::Button->new ("Create plot");

$button->signal_connect (clicked => sub {
    my ($button) = @_;
    my $name = $ename->get_text ();
    my $format = $fc->get_active_text ();
    my $height = $eh->get_active_text ();
    my $width = $ew->get_active_text ();
    my $in = $binf->get_filename ();
    #print "$name $format $height $width $in\n";
    my $status = system ("sh plot-graph.sh -o $name -f $format -i $in -w $width -h $height");
    print "$status\n";
    $prev->set_from_pixbuf (Gtk2::Gdk::Pixbuf->new_from_file_at_size("$name.$format", 480, 320));
    $imgframe->show ();
    ename_update ();
			 });

my $qb = Gtk2::Button->new ("Quit");
$qb->signal_connect (clicked => sub { Gtk2->main_quit; });

my $hbb = Gtk2::HBox->new (FALSE, 5);
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
