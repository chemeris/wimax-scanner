Copyright (c) 2011, Alexander Chemeris <Alexander.Chemeris@gmail.com>

This code was written for self-education purposes and is just a proof of
concept. It doesn't even do full decoding - just detect preamble and decode
FCH for a hardcoded example values.

Main files:
1) do_2647.m - main decoding file which calls all other files/functions
in appropriate order.

2) WiMAX_tests.m - a set of tests, using test vectors from the standard.

Note: Sample capture data is not included, because it may contain sensitive
      data and legality of this is not clear.
