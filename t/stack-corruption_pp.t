$ENV{PERL_LIST_UTIL_MAYBEXS_NO_XS} = 1;
do './t/stack-corruption.t' or die $@;