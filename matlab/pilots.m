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
