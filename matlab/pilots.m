% Pre-calculate pilots for 802.16e PUSC.
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

% Refer to "8.4.6.1.2.1 Symbol structure for PUSC" and "8.4.9.4.3 Pilot
% modulation" of IEEE 802.16-2009 for details.

pilot_shifted = zeros(2, params.N_pilot_sc);
pilot = zeros(2, params.N_pilot_sc);

% Odd
t = [93:14:512 514:14:933 ; 105:14:512 526:14:933 ];
pilot_shifted(1,:) = reshape(t,params.N_pilot_sc,1);
t = [2:14:421 605:14:1023 ; 14:14:421 617:14:1023 ];
pilot(1,:) = reshape(t,params.N_pilot_sc,1);

% Even
t = [97:14:512 518:14:933 ; 101:14:512 522:14:933 ];
pilot_shifted(2,:) = reshape(t,params.N_pilot_sc,1);
t = [6:14:421 609:14:1023 ; 10:14:421 613:14:1023 ];
pilot(2,:) = reshape(t,params.N_pilot_sc,1);

clear t;
