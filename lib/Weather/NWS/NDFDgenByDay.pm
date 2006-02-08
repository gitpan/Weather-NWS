package Weather::NWS::NDFDgenByDay;

use warnings;
use strict;

use SOAP::Lite;
use SOAP::DateTime;

use Readonly;

use Class::Std;

=pod 

=head1 NAME

Weather::NWS::NDFDgenByDay - Object interface to the NWS NDFDgenByDay Web Service.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=pod

=head1 SYNOPSIS

    use Weather::NWS::NDFDgenByDay;

    my $NDFDgenByDay = Weather::NWS::NDFDgenByDay->new();

    my $NDFDgenByDay = Weather::NWS::NDFDgenByDay->new(
        'Format' => 'Day',
        'Latitude' => 42,
        'Longitude' => -88,
    );
    
    my $latitude = 42;
    $NDFDgenByDay->set_latitude($latitude);
    $latitude = $NDFDgenByDay->get_latitude();
    
    my $longitude = -88;
    $NDFDgenByDay->set_longitude($longitude);
    $longitude = $NDFDgenByDay->get_longitude();   

    my $format = 'Day';
    $NDFDgenByDay->set_format($format);
    $format = $NDFDgenByDay->get_format();
    
    my $start_date = scalar localtime;
    $NDFDgenByDay->set_start_date($start_date);
    $start_date = $NDFDgenByDay->get_start_date();
    
    my $num_days = 3;
    $NDFDgenByDay->set_set_number_of_days($num_days);
    $num_days = $NDFDgenByDay->get_number_of_days();
    
    my $xml = $NDFDgenByDay->get_forecast_xml();
    
    my $xml = $NDFDgenByDay->get_forecast_xml(
        'Format' => 'Day',
        'Latitude' => 42,
        'Longitude' => -88,
    );

    my @formats = $NDFDgen->get_available_formats();

=cut

=pod

=head1 NDFDgenByDay

=cut

Readonly my $SERVICE =>
    'http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl';

Readonly my %NAME_TO_ARGUMENT => (
    'Latitude'           => 'latitude',
    'Longitude'          => 'longitude',
    'Start Date'         => 'startDate',
    'Number of Days'     => 'numDays',
    'Format'             => 'format',
);
Readonly my @ARGUMENTS => keys %NAME_TO_ARGUMENT;

Readonly my %NAME_TO_FORMAT => (
  'Day'      => '24 hourly',
  'Half-Day' => '12 hourly', 
);
Readonly my @FORMATS => keys %NAME_TO_FORMAT;

Readonly my $DEFAULT_FORMAT     => 'Day';
Readonly my $DEFAULT_START_DATE => ConvertDate(scalar localtime);
Readonly my $DEFAULT_NUM_DAYS   => 1;
=pod

=head1 METHODS

=cut

{
  my %forecaster         : ATTR;
  my %forecast_xml       : ATTR;
  my %default_num_days   : ATTR;
  my %default_format     : ATTR;
  my %default_start_date : ATTR;
  my %default_latitude   : ATTR;
  my %default_longitude  : ATTR;

=pod

=head2 BUILD (new)

Constructor for new NDFDgenByDay objects.  If called with no parameters, it will
return a new object initialized with the 'Day' format, the current date as the 
start date, and the default number of days equal to one.  All other parameters 
are left unintialized. Values can be provided for 'Latitude', 'Longitude', 
'Format', 'Start Time', and 'Number of Days'.

=cut

  sub BUILD {
    my ($self, $ident, $arg_ref) = @_;

    my %args = %{$arg_ref};

    $forecaster{$ident} = 
        SOAP::Lite->service($SERVICE);
    
    $self->set_latitude      ($args{'Latitude'}       || undef              );
    $self->set_longitude     ($args{'Longitude'}      || undef              );
    $self->set_start_date    ($args{'Start Date'}     || $DEFAULT_START_DATE);
    $self->set_number_of_days($args{'Number of Days'} || $DEFAULT_NUM_DAYS  );
    $self->set_format        ($args{'Format'}         || $DEFAULT_FORMAT    );
  }

=pod

=head2 set_latitude

Sets the latitude for the object.  This is a decimal value.

=cut

  sub set_latitude {
    my ($self, $new_latitude) = @_;
    return $default_latitude{ident $self} = $new_latitude;
  }
  
=pod

=head2 get_latitude

Returns the latitude stored in the object.

=cut

  sub get_latitude {
    my ($self) = @_;
    return $default_latitude{ident $self};
  }

=pod

=head2 set_longitude

Sets the longitude for the object.  This is a decimal value.

=cut

  sub set_longitude {
    my ($self, $new_longitude) = @_;
    return $default_longitude{ident $self} = $new_longitude;
  }
  
=pod

=head2 get_longitude

Returns the longitude stored in the object.

=cut

  sub get_longitude {
    my ($self) = @_;
    return $default_longitude{ident $self};
  }

=pod

=head2 set_format

Sets the format for the object.  This is either 'Day' or 'Half-Day'.

=cut

  sub set_format {
    my ($self, $new_format) = @_;

    die("Invalid format ($new_format)")
      unless(grep {/^${new_format}$/} @FORMATS);

    return $default_format{ident $self} = $new_format;
  }
  
=pod

=head2 get_format

Returns the format stored in the object.

=cut

  sub get_format {
    my ($self) = @_;
    return $default_format{ident $self};
  }

=pod

=head2 set_start_date

Sets the start date for the object.

=cut

  sub set_start_date {
    my ($self, $new_start_date) = @_;
    
    return unless $new_start_date;
    
    return $default_start_date{ident $self} = ConvertDate($new_start_date);
  }
  
=pod

=head2 get_start_date

Gets the start date stored in the object.

=cut

  sub get_start_date {
    my ($self) = @_;
    return $default_start_date{ident $self};
  }

=pod

=head2 set_number_of_days

Sets the number of days for the object.  This is an integer value
between 1 and 7.

=cut

  sub set_number_of_days {
    my ($self, $new_number_of_days) = @_;
    
    die("Non-numeric number of days ($new_number_of_days)")
      if($new_number_of_days =~ /\D/);
    
    die("Only 1-7 days are allowed")
      if($new_number_of_days < 1 || $new_number_of_days > 7);
      
    return $default_num_days{ident $self} = $new_number_of_days;
  }
  
=pod

=head2 get_number_of_days

Returns the number_of_days stored in the object.

=cut

  sub get_number_of_days {
    my ($self) = @_;
    return $default_num_days{ident $self};
  }

=pod

=head2 get_available_formats

Return a list of all formats available through this service.

=cut

  sub get_available_formats {
    my ($self) = @_;
    return @FORMATS;
  }

=pod

=head2 get_forecast_xml

Return the NWS NDFD XML as described in 
L<http://products.weather.gov/PDD/Extensible_Markup_Language.pdf>.  The data
returned depends on the state of the NDFDgenByDay object at the date of the call
to this method.  Any parameters can be overridden by being passed in as 
arguments to this method.

=cut

  sub get_forecast_xml {
    my ($self, %args) = @_;

    my ($ident) = ident $self;

    my ($latitude,
        $longitude, 
        $format, 
        $start_date, 
        $num_days
    );

    die("Latitude required")
      unless $latitude = $args{'Latitude'} || $default_latitude{$ident};
      
    die("Longitude required")
      unless $longitude = $args{'Longitude'} || $default_longitude{$ident};
      
    die("Format required")
      unless $format = $args{'Format'} || $default_format{$ident};

    die("Start date required")
      unless $start_date = $args{'Start Time'} || $default_start_date{$ident};
    
    die("Number of days required")
      unless $num_days = $args{'Number of Days'} || $default_num_days{$ident};
    
    my $resp = $forecaster{$ident}->NDFDgenByDay(
        SOAP::Data->name('latitude'  => $latitude),
        SOAP::Data->name('longitude' => $longitude),
        SOAP::Data->name('startDate' => $start_date),
        SOAP::Data->name('numDays'   => $num_days),
        SOAP::Data->name('format'    => $NAME_TO_FORMAT{$format}),
      );

    die("A fault (", $resp->faultcode, ") occurred: ", $resp->faultstring) 
        if (ref $resp and $resp->fault);

    $forecast_xml{$ident} = $resp; 

    return $resp;
  }
}

=pod

=head1 AUTHOR

Josh McAdams, C<< <josh dot mcadams at gmail dot com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-weather-nws-ndfdgenbyday at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Weather-NWS-NDFDgenByDay>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Weather::NWS::NDFDgenByDay

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Weather-NWS-NDFDgenByDay>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Weather-NWS-NDFDgenByDay>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Weather-NWS-NDFDgenByDay>

=item * Search CPAN

L<http://search.cpan.org/dist/Weather-NWS-NDFDgenByDay>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Josh McAdams, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Weather::NWS::NDFDgenByDay
