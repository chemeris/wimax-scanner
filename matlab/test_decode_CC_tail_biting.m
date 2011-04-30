%  This is test performance of two possible realizations 
%  decode_CC_tail_biting().
clear all;
N =  10000; 
err_count = 0; 

G1 = 171;       % 1+D+D^2+D^3+D^6
G2 = 133;       % 1+D^2+D^3+D^5+D^6
constLen = 7;   % Constraint length
rateInv = 2;    % Inverse of code rate

% Create the trellis that represents the convolutional code
convCode = poly2trellis(constLen, [G1 G2]);


data = randint(24,1); 
enc_data = encode_CC_tail_biting(data); 

llr =  0.5 - enc_data.'; 
std_noise_0dB = 1*std(llr); % Noise reference level 0 dB SNR

all_snr = []; 
v1 = []; 
v2 = []; 

for SNR = 2:0.5:5
    std_noise = std_noise_0dB*power(10, -SNR/20); 
    
    for variant=1:2
        err_count = 0; 
        for i=1:N
            data = randint(24,1); 
            enc_data = encode_CC_tail_biting(data); 

            llr =  0.5 - enc_data.'; 
            noise = std_noise*randn(1, length(llr)); 
            llr = llr + noise; 

        %   dec_data = decode_CC_tail_biting(llr, 'unquant');  

            tbLen = length(llr)/rateInv;
            if variant==1
          % The encoded data is repeat twice, we use second part 
          % of decoded data.   
                dec_data= vitdec([llr' ; llr'], convCode, tbLen, 'trunc', 'unquant');
                dec_data = dec_data(tbLen+1: end, 1);
            else
          % This has improve performance of decoder,  at least 1 dB.       
          % The encoded data is repeated three times, 
          % the middle part decoded data is used.  
       
                dec_data = vitdec([llr' ; llr'; llr'], convCode, tbLen, 'trunc', 'unquant');
                dec_data = dec_data(tbLen+1: tbLen*2, 1);
            end

            if(sum(abs(data-dec_data))~=0)
                err_count = err_count + 1; 
            end
        end
        if variant==1
            v1(end+1) = err_count; 
            all_snr(end+1) = SNR; 
        else
             v2(end+1) = err_count; 
        end
     
        fprintf('\nSNR=%d: variant No %d: count of damaged packets = %d', SNR, variant,  err_count); 
    end %    for variant=1:2
    
end %for SNR = 
fprintf( '\n' ); 

figure(1), plot(all_snr, log10(v1/N), 'b-', all_snr, log10(v2/N), 'r-') ; 
legend('variant 1', 'variant 2'); 
title('log10(packet error rate)'); 


