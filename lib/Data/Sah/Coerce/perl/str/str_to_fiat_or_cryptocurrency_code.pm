package Data::Sah::Coerce::perl::str::str_to_fiat_or_cryptocurrency_code;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

sub meta {
    +{
        v => 3,
        enable_by_default => 0,
        might_fail => 1,
        prio => 50,
    };
}

sub coerce {
    my %args = @_;

    my $dt = $args{data_term};

    my $res = {};

    $res->{expr_match} = "!ref($dt)";
    $res->{modules}{"CryptoCurrency::Catalog"} //= 0;
    $res->{modules}{"Locale::Codes::Currency_Codes"} //= 0;
    $res->{expr_coerce} = join(
        "",
        "do { my \$res; ",
        "  my \$uc = uc($dt); ",
        "  if (\$Locale::Codes::Data{currency}{code2id}{alpha}{\$uc}) { \$res = [undef, \$uc]; goto RETURN_RES } ",
        "  my \$cat = CryptoCurrency::Catalog->new; ",
        "  my \$rec; eval { \$rec = \$cat->by_code($dt) }; if (\$@) { eval { \$rec = \$cat->by_name($dt) } } if (\$@) { eval { \$rec = \$cat->by_safename($dt) } } ",
        "  if (\$@) { \$res = ['Unknown fiat/cryptocurrency code/name/safename: ' . $dt] } else { \$res = [undef, \$rec->{code}] } ",
        "  RETURN_RES: \$res; ",
        "}",
    );

    $res;
}

1;
# ABSTRACT: Coerce string containing fiat/cryptocurrency code/name/safename to uppercase code

=for Pod::Coverage ^(meta|coerce)$

=head1 DESCRIPTION

The rule is not enabled by default. You can enable it in a schema using e.g.:

 ["str", "x.perl.coerce_rules"=>["str_to_cryptocurrency_code"]]
