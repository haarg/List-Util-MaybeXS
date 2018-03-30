$ENV{PERL_LIST_UTIL_MAYBEXS_NO_XS} = 1;
do './t/rt-96343.t' or die $@;
