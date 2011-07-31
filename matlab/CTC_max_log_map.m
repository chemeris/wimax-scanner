function  ab_out_llrs = CTC_max_log_map( branches )
% Max Log MAP decoder. This is a part turbo decoder of the CTC. 
% Copyright (C) 2011  Alexey Ostapenko.
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
%
% ab_out_llrs = CTC_max_log_map( branches )
% Function input:
%   branches - table of the metrics, size 4xN, 
%       first row of the table is metrics of the systematic bits 'A',  
%       second row of the table is metrics of the systematic bits 'B',  
%       third   row of the table is metrics of the parity bits 'Y',  
%       4th  row of the table is metrics of the parity bits 'W',  
% Function output: 
%       ab_out_llrs - interleaved LLRs of the systematic bits  'A' 'B'
N = length(branches); 
% All possible branches from one state
AB = [0, 0
      0, 1
      1, 0,
      1, 1]; 

 FwdStatesTab = struct('s_prev', zeros(32,1), 's', zeros(32,1), 'branch', zeros(32, 4));   
 BwdStatesTab = FwdStatesTab; 
 
 c = 1; 
 for s = 0:7
     for b = 1:4
        [y, w, s_next] = CTC_ConstituentEncoder(AB(b,:), s);
        % Ñurrent state (backward direction)
        BwdStatesTab.s(c) = s; 
        % State from which we came (backward direction)
        BwdStatesTab.s_prev(c) = s_next;         
        BwdStatesTab.branch(c,:) = 2*[AB(b,:), y, w]-1; 
        c= c+1;
     end
 end 
 
for s = 0:7
    Ind = find(BwdStatesTab.s_prev==s); 
    FwdStatesTab.s(1+s*4: (s+1)*4) = s; 
    FwdStatesTab.s_prev(1+s*4: (s+1)*4) = BwdStatesTab.s(Ind); 
    FwdStatesTab.branch(1+s*4: (s+1)*4, :) = BwdStatesTab.branch(Ind,:); 
end


W = zeros(8, N+1); 

%    (  S0 initional encoder state ) ---branch1---> (S1) ...
%    ---branchN-->(SN+1)


% Backward trace, calculate beta
 for i=N:-1:1
     
	% Take i-th branch
    b = branches(i, :); 
    % Cycle through all possible states    
    newW = zeros(8,1); 
    for s=0:7     
        prev_states = BwdStatesTab.s_prev(s*4+1:(s+1)*4); 
        tmp = W(prev_states+1, i+1) + BwdStatesTab.branch(s*4+1:(s+1)*4, :) * b'; 
        newW(s+1) = max(tmp);         
    end
    W(:, i) =   newW;           
 end
 
 positive_a_ind =  BwdStatesTab.branch(:,1) > 0; 
 negative_a_ind =  BwdStatesTab.branch(:,1) < 0; 
 positive_b_ind =  BwdStatesTab.branch(:,2) > 0; 
 negative_b_ind =  BwdStatesTab.branch(:,2) < 0; 
 
 Walpha = zeros(8,1); 
 ab_out_llrs = zeros(2*N,1); 
 % Forward trace, calculate alpha
 for i=1:1:N
  % Take i-th branch
    b = branches(i, :);     
    newW = zeros(8,1); 
  % merge forward & backward traces
    all_branches_metrics = BwdStatesTab.branch * b' + Walpha(1+BwdStatesTab.s) + W(1+BwdStatesTab.s_prev, i+1); 
  % calculate the output llrs  for two bits
    ab_out_llrs( (i-1)*2+1) = max(all_branches_metrics(positive_a_ind)) - max(all_branches_metrics(negative_a_ind)); 
    ab_out_llrs( (i-1)*2+2) = max(all_branches_metrics(positive_b_ind)) - max(all_branches_metrics(negative_b_ind)); 
    
    %max(all_branches_metrics)
   % Cycle through all possible states    
    for s=0:7     
        prev_states = FwdStatesTab.s_prev(s*4+1:(s+1)*4); 
        tmp = Walpha(prev_states+1) + FwdStatesTab.branch(s*4+1:(s+1)*4, :) * b'; 
        newW(s+1) = max(tmp);         
    end
    Walpha = newW;               
 end 