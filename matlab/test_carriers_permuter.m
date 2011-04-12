% Another way to generate carriers indexes
% then get_DL_PUSC_subcarriers_PN

% FFT size 1024
DC_index = 512;
used_carriers = 92: 92+841-1 ;
tmp_ind = find(used_carriers==512); 
used_carriers(tmp_ind) = [];  %remove DC carrier
renumering_seq = [6; 48; 37; 21; 31; 40; 42; 56; 32; 47; 30; 33; 54; 18;
                    10; 15; 50; 51; 58; 46; 23; 45; 16; 57; 39; 35; 7; 55;
                    25; 59; 53; 11; 22; 38; 28; 19; 17; 3; 27; 12; 29; 26;
                    5; 41; 49; 44; 9; 8; 1; 13; 36; 14; 43; 2; 20; 24; 52;
                    4; 34; 0]; 

NumCarriersPerCluster = 14; 
NumClusters = 60;
NumSubcarrPerSubchannel = 24; 
PermBase6 = [3,2,0,4,5,1]; 
PermBase4 = [3,0,2,1]; 

clusters = zeros(NumClusters, NumCarriersPerCluster); 

for i = 1: NumClusters
    clusters(i, :) = used_carriers(1+(i-1)*NumCarriersPerCluster: i*NumCarriersPerCluster); 
end 

logical_clusters = clusters; 
test = zeros(1, NumClusters); 
for i = 1:  NumClusters
    logical_clusters(1+renumering_seq(i), :) = clusters(i, :); 
    test(1+renumering_seq(i)) = i-1; 
end

major_group0 = logical_clusters(1+(0 :11), :); 
major_group1 = logical_clusters(1+(12:19), :); 
major_group2 = logical_clusters(1+(20:31), :);  
major_group3 = logical_clusters(1+(32:39), :);  
major_group4 = logical_clusters(1+(40:51), :);  
major_group5 = logical_clusters(1+(52:59), :);  



Nsubcarriers = NumSubcarrPerSubchannel; 
DL_PermBase = 2; 
k = (0:Nsubcarriers-1); %number subcarrier in the subchannel
dl0_carriers = zeros(2*30, 24); 

for ofdm_symbol = 0:1
    s = 0;  % current subchannel 
    fprintf('\n================== ofdm_symbol = %d =============',ofdm_symbol); 
    for mg = 0:5
        if(mod(mg,2)==0) 
            Nsubchannels = 6;         
            ps = PermBase6; 
        else
            Nsubchannels = 4; 
            ps = PermBase4; 
        end

        switch mg
            case 0,   tmp_grp = major_group0 ; 
            case 1,   tmp_grp = major_group1 ;     
            case 2,   tmp_grp = major_group2 ;  
            case 3,   tmp_grp = major_group3 ;   
            case 4,   tmp_grp = major_group4 ;  
            case 5,   tmp_grp = major_group5 ;               
        end


        %remove pilots
        if(ofdm_symbol==0)
            tmp_grp = [tmp_grp(:,1:4), tmp_grp(:,6:8), tmp_grp(:, 10:end) ] ;
        else
            tmp_grp = [tmp_grp(:,2:12), tmp_grp(:,14)] ;
        end
        
        tmp = reshape(tmp_grp.',  Nsubchannels*Nsubcarriers, 1).'; 

        for n=1:Nsubchannels
            s2 = n-1; %!!!!!!!!!!!!!!
            nk = mod( (k + 13 * s2),  Nsubcarriers)  ;    
            ref =params.N_left_guard_sc + get_DL_PUSC_subcarriers_PN(s, DL_PermBase, true, ofdm_symbol,  params); 
            subcarrier = Nsubchannels * nk + mod( ps( 1+ mod(  s2 + mod(nk , Nsubchannels), Nsubchannels) ) + DL_PermBase,  Nsubchannels);      
            ref = ref + (ref>511);  
            result = tmp(1+subcarrier);   
            dl0_carriers(ofdm_symbol*30 + s+1, :) = result; 
            fprintf('\n mg=%d, subchannel=%d', mg, s2); 
            if max(abs(ref-result))==0 
                fprintf(' Œ  ');  
                
            else
                fprintf(' ERROR ');  
    %             ref
    %             result
            end 
            s = s+1; 
        end
    end
end




