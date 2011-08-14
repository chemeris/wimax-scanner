Copyright (c) 2011, Alexander Chemeris <Alexander.Chemeris@gmail.com>

This code was written for self-education purposes and is just a proof of
concept. It doesn't even do full decoding - just detect preamble and decode
FCH for a hardcoded example values. E.g. we assume 10MHz and 1024 FFT.

Main files:
1) do_preamble_finder.m - main decoding file which calls all other
files/functions in appropriate order.

2) do_PDU_extract.m - extract data bursts after we discover where they are.

3) WiMAX_tests.m - a set of tests, using test vectors from 802.16-2009.

4) test_wimax_prbs.m - test for sub-carrier randomization PRBS, using
test vector from 802.16-2009.

5) test_*.m - other tests you can play with.

Note: Sample capture data is not included, because it may contain sensitive
      data and legality of this is not clear.
