% Test preamble_idx detection for different CFO

set_params; 
preambles; 
NUMBER_ITER  =114

if 0
    CFO = 2*pi/1024 * (rand(1, NUMBER_ITER)-0.5); 
else    
    CFO =  -pi/1024*ones(1,NUMBER_ITER); % 2*pi/1024 * (rand(1, NUMBER_ITER)-0.5); 
end

est_CFO = zeros(1, NUMBER_ITER); 
seg = zeros(1, 114); 
%h = [0.5, 0, 0.5*1j]; 

for k=1:114
    preamble_idx = k-1; 
   if k < 96
        seg(k) = floor(preamble_idx/32);
    else
        seg(k) = mod(preamble_idx-96, 3);
   end
end

s0 = find(seg == 0); 
s1 = find(seg == 1); 
s2 = find(seg == 2); 

% Make CIR
if 1
 h = firpm(20, [0, 0.5 0.8, 1], [1,1,0,0])
 h = h.*exp(-1j*2*pi*0.15*(1:length(h))); 
else
 h = firpm(20, [0, 0.5 0.8, 1], [1,1,0,0])
 h = h.*exp(+1j*2*pi*0.15*(1:length(h)));     
end
 freqz(h,1, 512, 'whole'); 
 
 % Flat channel
 h=1;
 
 for CFo = -pi/1024: pi/1024/2: pi/1024+1E-10
    total_cnt = 0; 
    lost_cnt  = 0; 
    err_cnt   = 0; 
    CFO =  CFo * ones(1,NUMBER_ITER);  
    for n = 1:100
        for k=1: NUMBER_ITER
           preamble_idx = k-1; 
           if preamble_idx < 96
                s = floor(preamble_idx/32);
           else
                s = mod(preamble_idx-96, 3);
           end



            x = 5*(randn(20000, 1)+1j*randn(20000, 1)); 
            pos = 1000; 
            tmp = 1024*ifft(preamble_freq(preamble_idx+1,:).'); 
            frame = [tmp(1024-params.Tg_samples+1 :1024); tmp  ]; 

            eframe = var(frame); 
            enoise = var(x(pos : pos + params.Tb_samples + params.Tg_samples -1)); 

            %SNR  = 10*log10(eframe/enoise)
            frame = frame.*exp(1j*((1:length(frame))*CFO(k)+2*pi*rand(1,1))).';    
            x(pos : pos + params.Tb_samples + params.Tg_samples -1) = x(pos : pos + params.Tb_samples + params.Tg_samples -1)+frame; 

            x = filter(h, 1, x); 
            [frame_start_pos, frame_carrier_offset] = find_preamble(params, x) ;
            total_cnt = total_cnt+1; 
            if(~isempty(frame_start_pos) )
                if s==0
                    est_CFO(k) = frame_carrier_offset(1); 
                elseif s==1
                    est_CFO(k) = frame_carrier_offset(1)-2*pi/1024; 
                else
                    est_CFO(k) = frame_carrier_offset(1)+2*pi/1024; 
                end

                frame_td =  x(frame_start_pos(1): frame_start_pos(1) + params.Tb_samples-1);

       
        % Compensate CFO
               if 0
                 frame_fd = fft(frame_td.*exp(1j*((1:length(frame_td))*(-est_CFO(k)))).'); 
               else
                 frame_fd = fft(frame_td); 
               end
                 frame_fd = fftshift(frame_fd); 
                 frame_fd = frame_fd.*exp(1j*2*pi/1024*(params.Tg_samples)/2*(1:1024)).'; 


                [preamble_idx, id_cell, segment] = detect_preamble_fd(frame_fd, preamble_freq); 
                if ((k-1) ~= preamble_idx)
                   % fprintf('\rtotal=%d error detected = %d, actually = %d ',total_cnt, preamble_idx ,k-1); 
                    err_cnt = err_cnt+1;             
                end
            else
                lost_cnt= lost_cnt+1; 
                %fprintf('\r %d lost !!!', total_cnt);
            end

        end
    end %for n = 1:10
    fprintf('\n\nCFO = %f ntotal  = %d lost = %d err=%d', CFO(1), total_cnt, lost_cnt, err_cnt);
end
 
figure(7), plot(1: NUMBER_ITER, CFO, 1: NUMBER_ITER, est_CFO); 
title('estimated CFO vs actually CFO'); 

% est_CFO(s1)=est_CFO(s1)-2*pi/1024;
% est_CFO(s2)=est_CFO(s2)+2*pi/1024;

e = est_CFO - CFO; 
mean_e = mean(e) ; 
std_e  = std(e);  


mean_e_div_df = mean_e/(2*pi/1024)
std_div_df = std_e/(2*pi/1024)



% for k=1: NUMBER_ITER
%     t = abs(fftshift(preamble_freq(k,:))); 
%     m(k) = sum(t.*(-511:512)); 
% end        
% figure(8),  plot(m);

%figure(8), plot([e(s0), e(s1), e(s2) ])
%figure(8), plot(e(s0))
%mean_e0 = mean(e(s0))
%d_e0 = std(e(s0))
