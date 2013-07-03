package WebAxs::Path;

use File::Basename ();
use Scalar::Util qw(blessed);

use overload '""' => 'clean';

sub new {
    my ($class, $base, $path) = @_;
    return $path  if blessed $path && $path->isa(__PACKAGE__) && $path->{base} eq $base;
    bless {
        base => $base,
        orig => $path,
    }, $class;
}

sub clean {
    my $self = shift;
    return $self->{clean}  if exists $self->{clean};
    my @parts;
    foreach ( split "/", $self->{orig} ) {
        if ( $_ eq '.' || $_ eq '' ) {
            # Ignore
        } elsif ( $_ eq '..') {
            pop @parts;
        } else {
            push @parts, $_;
        }
    }
    $self->{clean} = "/" . join "/", @parts;
}

sub realpath {
    my $self = shift;
    return $self->{realpath}  if exists $self->{realpath};
    $self->{realpath} = $self->{base} . $self->clean;
}

sub basename {
    my $self = shift;
    return $self->{basename}  if exists $self->{basename};
    $self->{basename} = File::Basename::basename($self->{orig});
}

sub extension {
    my $self = shift;
    return $self->{extension}  if exists $self->{extension};
    $self->{orig} =~ m|\.([^./]+)$|;
    $self->{extension} = $1;
}

sub cat {
    my ($self, $path) = @_;
    __PACKAGE__->new($self->{base}, $self->{orig} . '/' . $path);
}

1;
