% TODO:: Replace hardcoded values with run-time calculation
% Rows enumerate physical carrier indexes (starting with 0)
% of sub-channels 0-3
% FCH_carriers_sym0 is for symbol 0, FCH_carriers_sym1 is for symbol 1
FCH_carriers_sym0 = [ 920 926 770 775 838 848 612 618 896 901 684 694 93 99 461 466 754 764 738 744 293 298 530 540 ;
                      104 458 467 757 760 737 749 290 299 533 536 919 931 767 776 841 844 611 623 893 902 687 690 92 ;
                      768 778 836 842 616 621 894 904 682 688 97 102 459 469 752 758 742 747 291 301 528 534 924 929 ;
                      465 751 763 739 748 294 297 527 539 921 930 771 774 835 847 613 622 897 900 681 693 94 103 462 ];
FCH_carriers_sym1 = [ 921 926 770 774 839 848 613 618 896 900 685 694 94 99 461 465 755 764 739 744 293 297 531 540 ;
                      103 459 466 757 759 738 748 291 298 533 535 920 930 768 775 841 843 612 622 894 901 687 689 93 ;
                      769 778 837 842 616 620 895 904 683 688 97 101 460 469 753 758 742 746 292 301 529 534 924 928 ;
                      464 752 762 740 747 294 296 528 538 922 929 771 773 836 846 614 621 897 899 682 692 95 102 462 ];

% FCH is repeated 4 times -> we save it to 4 arrays
% PS we add 1 to convert to Matlab indexing (starting from 1)
% TODO:: This damn standard doesn't tell us how subcarriers are numbered
% across symbols. So just do what seems more logical.
if 1
FCH_bits_interleaved_0 = [ sym_derand(1,FCH_carriers_sym0(1,:)+1) sym_derand(2,FCH_carriers_sym1(1,:)+1) ];
FCH_bits_interleaved_1 = [ sym_derand(1,FCH_carriers_sym0(2,:)+1) sym_derand(2,FCH_carriers_sym1(2,:)+1) ];
FCH_bits_interleaved_2 = [ sym_derand(1,FCH_carriers_sym0(3,:)+1) sym_derand(2,FCH_carriers_sym1(3,:)+1) ];
FCH_bits_interleaved_3 = [ sym_derand(1,FCH_carriers_sym0(4,:)+1) sym_derand(2,FCH_carriers_sym1(4,:)+1) ];
else
FCH_bits_interleaved_0(1:2:48) = sym_derand(1,FCH_carriers_sym0(1,:)+1);
FCH_bits_interleaved_0(2:2:48) = sym_derand(2,FCH_carriers_sym1(1,:)+1);
FCH_bits_interleaved_1(1:2:48) = sym_derand(1,FCH_carriers_sym0(2,:)+1);
FCH_bits_interleaved_1(2:2:48) = sym_derand(2,FCH_carriers_sym1(2,:)+1);
FCH_bits_interleaved_2(1:2:48) = sym_derand(1,FCH_carriers_sym0(3,:)+1);
FCH_bits_interleaved_2(2:2:48) = sym_derand(2,FCH_carriers_sym1(3,:)+1);
FCH_bits_interleaved_3(1:2:48) = sym_derand(1,FCH_carriers_sym0(4,:)+1);
FCH_bits_interleaved_3(2:2:48) = sym_derand(2,FCH_carriers_sym1(4,:)+1);
end

% Plot FCH I/Q data - all 4 repetitions
figure ; subplot(2,1,1) ; hold on
plot( real(FCH_bits_interleaved_0) ,'r.-')
plot( real(FCH_bits_interleaved_1) ,'g.-')
plot( real(FCH_bits_interleaved_2) ,'b.-')
plot( real(FCH_bits_interleaved_3) ,'k.-')
hold off
title('FCH I values (4 repetitions)');
subplot(2,1,2) ; hold on
plot( imag(FCH_bits_interleaved_0) ,'r.-')
plot( imag(FCH_bits_interleaved_1) ,'g.-')
plot( imag(FCH_bits_interleaved_2) ,'b.-')
plot( imag(FCH_bits_interleaved_3) ,'k.-')
hold off
title('FCH Q values (4 repetitions)');

%scatterplot(FCH_bits_interleaved_0) ; xlim([-1 1]); ylim([-1 1])
%scatterplot(FCH_bits_interleaved_1) ; xlim([-1 1]); ylim([-1 1])
%scatterplot(FCH_bits_interleaved_2) ; xlim([-1 1]); ylim([-1 1])
%scatterplot(FCH_bits_interleaved_3) ; xlim([-1 1]); ylim([-1 1])
