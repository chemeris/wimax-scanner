% WiMAX decoding/encoding functions testbench
% Copyright (C) 2011  Alexander Chemeris
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301
% USA

%% Test vectors
if 0
% 8.3.3.5.1 Full bandwidth (16 subchannels)
input_data = sscanf(['45 29 C4 79 AD 0F 55 28 AD 87 B5 76 1A 9C 80 50 45 1B 9F D9 2A '...
                     '88 95 EB AE B5 2E 03 4F 09 14 69 58 0A 5D'], '%x');
randomized_data = sscanf(['D4 BA A1 12 F2 74 96 30 27 D4 88 9C 96 E3 A9 52 B3 15 AB FD 92 '...
                          '53 07 32 C0 62 48 F0 19 22 E0 91 62 1A C1'],'%x');
rs_encoded_data = sscanf(['49 31 40 BF D4 BA A1 12 F2 74 96 30 27 D4 88 9C 96 E3 A9 52 B3 '...
                          '15 AB FD 92 53 07 32 C0 62 48 F0 19 22 E0 91 62 1A C1 00'],'%x');
conv_encoded_data = sscanf(['3A 5E E7 AE 49 9E 6F 1C 6F C1 28 BC BD AB 57 CD BC CD E3 A7 92 '...
                            'CA 92 C2 4D BC 8D 78 32 FB BF DF 23 ED 8A 94 16 27 A5 65 CF 7D '...
                            '16 7A 45 B8 09 CC'],'%x');
interleaved_data = sscanf(['77 FA 4F 17 4E 3E E6 70 E8 CD 3F 76 90 C4 2C DB F9 B7 FB 43 6C '...
                           'F1 9A BD ED 0A 1C D8 1B EC 9B 30 15 BA DA 31 F5 50 49 7D 56 ED '...
                           'B4 88 CC 72 FC 5C'],'%x');
interleave_base=12;
else
% 8.4.9.4.4 Example of OFDMA UL CC encoding
input_data = sscanf('AC BC D2 11 4D AE 15 77 C6 DB F4 C9', '%x');
randomized_data = sscanf('55 8A C4 A5 3A 17 24 E1 63 AC 2B F9','%x');
conv_encoded_data = sscanf('28 33 E4 8D 39 20 26 D5 B6 DC 5E 4A F4 7A DD 29 49 4B 6C 89 15 13 48 CA','%x');
interleaved_data = sscanf('4B 04 7D FA 42 F2 A5 D5 F6 1C 02 1A 58 51 E9 A3 09 A2 4F D5 80 86 BD 1E','%x');
interleave_base=16;
constellation_mapping = [ +0.707-0.707*1i +0.707+0.707*1i -0.707+0.707*1i -0.707-0.707*1i +0.707+0.707*1i +0.707+0.707*1i +0.707-0.707*1i +0.707+0.707*1i +0.707-0.707*1i -0.707-0.707*1i -0.707-0.707*1i +0.707-0.707*1i -0.707-0.707*1i -0.707-0.707*1i -0.707+0.707*1i -0.707+0.707*1i +0.707-0.707*1i +0.707+0.707*1i +0.707+0.707*1i -0.707+0.707*1i -0.707-0.707*1i -0.707-0.707*1i +0.707+0.707*1i -0.707+0.707*1i -0.707+0.707*1i -0.707+0.707*1i +0.707-0.707*1i +0.707-0.707*1i -0.707-0.707*1i +0.707-0.707*1i +0.707-0.707*1i +0.707-0.707*1i -0.707-0.707*1i -0.707-0.707*1i +0.707-0.707*1i -0.707+0.707*1i +0.707+0.707*1i +0.707-0.707*1i -0.707-0.707*1i +0.707+0.707*1i +0.707+0.707*1i +0.707+0.707*1i +0.707+0.707*1i -0.707+0.707*1i +0.707+0.707*1i +0.707-0.707*1i -0.707+0.707*1i -0.707+0.707*1i +0.707-0.707*1i +0.707-0.707*1i -0.707+0.707*1i +0.707+0.707*1i +0.707-0.707*1i +0.707-0.707*1i +0.707+0.707*1i +0.707-0.707*1i -0.707-0.707*1i -0.707+0.707*1i -0.707+0.707*1i +0.707-0.707*1i -0.707+0.707*1i -0.707+0.707*1i +0.707+0.707*1i -0.707-0.707*1i +0.707+0.707*1i +0.707+0.707*1i -0.707+0.707*1i +0.707-0.707*1i -0.707+0.707*1i -0.707+0.707*1i +0.707+0.707*1i -0.707+0.707*1i +0.707-0.707*1i +0.707+0.707*1i -0.707-0.707*1i -0.707-0.707*1i -0.707-0.707*1i +0.707-0.707*1i +0.707-0.707*1i +0.707-0.707*1i -0.707+0.707*1i +0.707+0.707*1i +0.707+0.707*1i +0.707+0.707*1i -0.707+0.707*1i +0.707+0.707*1i +0.707-0.707*1i -0.707+0.707*1i -0.707+0.707*1i -0.707-0.707*1i -0.707-0.707*1i +0.707-0.707*1i +0.707+0.707*1i +0.707-0.707*1i -0.707-0.707*1i -0.707+0.707*1i ];
modulated_data = [ 0 448 +1 ; 0 449 +0.707+0.707*1i ; 0 450 -0.707-0.707*1i ; 0 451 -1 ; 0 512 -1 ; 0 513 -0.707+0.707*1i ; 0 514 +0.707-0.707*1i ; 0 515 -1 ; 0 984 -1 ; 0 985 +0.707+0.707*1i ; 0 986 +0.707-0.707*1i ; 0 987 -1 ; 0 1189 +1 ; 0 1190 -0.707-0.707*1i ; 0 1191 +0.707+0.707*1i ; 0 1192 -1 ; 0 1505 -1 ; 0 1506 -0.707-0.707*1i ; 0 1507 -0.707-0.707*1i ; 0 1508 +1 ; 0 1753 -1 ; 0 1754 -0.707-0.707*1i ; 0 1755 +0.707-0.707*1i ; 0 1756 +1 ; 1 448 -0.707-0.707*1i ; 1 449 +0.707-0.707*1i ; 1 450 +0.707-0.707*1i ; 1 451 -0.707+0.707*1i ; 1 512 -0.707+0.707*1i ; 1 513 -0.707-0.707*1i ; 1 514 +0.707-0.707*1i ; 1 515 -0.707-0.707*1i ; 1 984 +0.707+0.707*1i ; 1 985 +0.707+0.707*1i ; 1 986 -0.707+0.707*1i ; 1 987 +0.707+0.707*1i ; 1 1189 +0.707-0.707*1i ; 1 1190 -0.707-0.707*1i ; 1 1191 +0.707+0.707*1i ; 1 1192 -0.707+0.707*1i ; 1 1505 +0.707+0.707*1i ; 1 1506 +0.707+0.707*1i ; 1 1507 -0.707+0.707*1i ; 1 1508 -0.707+0.707*1i ; 1 1753 -0.707+0.707*1i ; 1 1754 -0.707-0.707*1i ; 1 1755 +0.707+0.707*1i ; 1 1756 +0.707-0.707*1i ; 2 448 +1 ; 2 449 +0.707+0.707*1i ; 2 450 -0.707-0.707*1i ; 2 451 +1 ; 2 512 -1 ; 2 513 -0.707-0.707*1i ; 2 514 -0.707+0.707*1i ; 2 515 -1 ; 2 984 +1 ; 2 985 +0.707-0.707*1i ; 2 986 -0.707+0.707*1i ; 2 987 -1 ; 2 1189 +1 ; 2 1190 -0.707+0.707*1i ; 2 1191 -0.707+0.707*1i ; 2 1192 -1 ; 2 1505 -1 ; 2 1506 -0.707-0.707*1i ; 2 1507 +0.707-0.707*1i ; 2 1508 +1 ; 2 1753 -1 ; 2 1754 +0.707-0.707*1i ; 2 1755 -0.707+0.707*1i ; 2 1756 +1 ; 3 328 -1 ; 3 329 +0.707-0.707*1i ; 3 330 -0.707-0.707*1i ; 3 331 -1 ; 3 524 -1 ; 3 525 -0.707+0.707*1i ; 3 526 +0.707-0.707*1i ; 3 527 -1 ; 3 784 -1 ; 3 785 -0.707+0.707*1i ; 3 786 -0.707+0.707*1i ; 3 787 -1 ; 3 1209 -1 ; 3 1210 +0.707-0.707*1i ; 3 1211 -0.707-0.707*1i ; 3 1212 -1 ; 3 1361 +1 ; 3 1362 +0.707+0.707*1i ; 3 1363 +0.707+0.707*1i ; 3 1364 +1 ; 3 1601 +1 ; 3 1602 +0.707+0.707*1i ; 3 1603 +0.707-0.707*1i ; 3 1604 +1 ; 4 328 +0.707-0.707*1i ; 4 329 -0.707+0.707*1i ; 4 330 +0.707-0.707*1i ; 4 331 +0.707+0.707*1i ; 4 524 -0.707+0.707*1i ; 4 525 -0.707+0.707*1i ; 4 526 -0.707-0.707*1i ; 4 527 +0.707+0.707*1i ; 4 784 +0.707+0.707*1i ; 4 785 -0.707-0.707*1i ; 4 786 -0.707+0.707*1i ; 4 787 -0.707+0.707*1i ; 4 1209 -0.707+0.707*1i ; 4 1210 +0.707-0.707*1i ; 4 1211 -0.707-0.707*1i ; 4 1212 -0.707-0.707*1i ; 4 1361 -0.707-0.707*1i ; 4 1362 -0.707+0.707*1i ; 4 1363 +0.707+0.707*1i ; 4 1364 -0.707+0.707*1i ; 4 1601 -0.707+0.707*1i ; 4 1602 +0.707-0.707*1i ; 4 1603 -0.707-0.707*1i ; 4 1604 -0.707-0.707*1i ; 5 328 +1 ; 5 329 -0.707+0.707*1i ; 5 330 +0.707+0.707*1i ; 5 331 +1 ; 5 524 -1 ; 5 525 -0.707+0.707*1i ; 5 526 +0.707+0.707*1i ; 5 527 +1 ; 5 784 +1 ; 5 785 +0.707-0.707*1i ; 5 786 -0.707+0.707*1i ; 5 787 -1 ; 5 1209 -1 ; 5 1210 -0.707+0.707*1i ; 5 1211 +0.707-0.707*1i ; 5 1212 +1 ; 5 1361 +1 ; 5 1362 +0.707+0.707*1i ; 5 1363 -0.707+0.707*1i ; 5 1364 -1 ; 5 1601 -1 ; 5 1602 +0.707-0.707*1i ; 5 1603 +0.707+0.707*1i ; 5 1604 +1 ];
end

% Convert to Matlab-readable form
randomized_bits = double(dec2bin(randomized_data))'-48;
randomized_bits = randomized_bits(:);
conv_encoded_bits = double(dec2bin(conv_encoded_data))'-48;
conv_encoded_bits = conv_encoded_bits(:);
interleaved_bits = double(dec2bin(interleaved_data))'-48;
interleaved_bits = interleaved_bits(:);

%% De-interleave (for QPSK modulation)
t = deinterleave_QPSK(interleaved_bits, interleave_base);
all(t==conv_encoded_bits)
clear t ;

%% Interleave (for QPSK modulation)
t = interleave_QPSK(conv_encoded_bits, interleave_base);
all(t==interleaved_bits)
clear t ;

%% Decode (CC 1/2 with tail-biting)
% Using hard bits
t = decode_CC_tail_biting(conv_encoded_bits', 'hard');
all(t==randomized_bits)
clear t ;

% Using unquiantized soft bits
conv_encoded_bits_soft = double(1 - 2*conv_encoded_bits)*0.7;
t = decode_CC_tail_biting(conv_encoded_bits_soft', 'unquant');
all(t==randomized_bits)
clear t ;

%% Encode (CC 1/2 with tail-biting)
t = encode_CC_tail_biting(randomized_bits);
all(t==conv_encoded_bits)
clear t ;

%% QPSK demodulation
t = demodulate_QPSK(constellation_mapping)<0;
all(t'==interleaved_bits)
clear t ;
