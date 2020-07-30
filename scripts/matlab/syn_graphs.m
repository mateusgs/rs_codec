clc
clear all
close all

csv_data = readtable('C:\Users\mateu\OneDrive\Documents\GitHub\UFMG_digital_design\rs_codec\syn\rs_encoder\quartus_syn_report_final.csv',...
                     'Delimiter', ';')
%C:\Users\mateu\OneDrive\Documents\GitHub\UFMG_digital_design\rs_codec\rs_decoder\syn\quartus_syn_report_2.csv
%C:\Users\mateu\OneDrive\Documents\GitHub\UFMG_digital_design\rs_codec\rs_encoder\syn\quartus_syn_report.csv                 


GF_16_rows = ismember(csv_data{:,3}, 'RS_GF_16');
GF_16 = csv_data(GF_16_rows, :);

GF_32_rows = ismember(csv_data{:,3}, 'RS_GF_32');
GF_32 = csv_data(GF_32_rows, :);

GF_64_rows = ismember(csv_data{:,3}, 'RS_GF_64');
GF_64 = csv_data(GF_64_rows, :);

GF_128_rows = ismember(csv_data{:,3}, 'RS_GF_128');
GF_128 = csv_data(GF_128_rows, :);

GF_256_rows = ismember(csv_data{:,3}, 'RS_GF_256');
GF_256 = csv_data(GF_256_rows, :);

%%

csv_data_2 = readtable('C:\Users\mateu\OneDrive\Documents\GitHub\UFMG_digital_design\rs_codec\syn\rs_decoder\quartus_syn_report_final.csv',...
                      'Delimiter', ';')
%C:\Users\mateu\OneDrive\Documents\GitHub\UFMG_digital_design\rs_codec\rs_decoder\syn\quartus_syn_report_2.csv
%C:\Users\mateu\OneDrive\Documents\GitHub\UFMG_digital_design\rs_codec\rs_encoder\syn\quartus_syn_report.csv                 


GF_16_rows_2 = ismember(csv_data_2{:,3}, 'RS_GF_16');
GF_16_2 = csv_data_2(GF_16_rows_2, :);

GF_32_rows_2 = ismember(csv_data_2{:,3}, 'RS_GF_32');
GF_32_2 = csv_data_2(GF_32_rows_2, :);

GF_64_rows_2 = ismember(csv_data_2{:,3}, 'RS_GF_64');
GF_64_2 = csv_data_2(GF_64_rows_2, :);

GF_128_rows_2 = ismember(csv_data_2{:,3}, 'RS_GF_128');
GF_128_2 = csv_data_2(GF_128_rows_2, :);

GF_256_rows_2 = ismember(csv_data_2{:,3}, 'RS_GF_256');
GF_256_2 = csv_data_2(GF_256_rows_2, :);


%%
close all
subplot(3,1,1);
hold on;
plot((GF_16.N - GF_16.K)/2, extract_num_logic_cells(GF_16.logic_elements), '-', 'Color', 'k');
plot((GF_32.N - GF_32.K)/2, extract_num_logic_cells(GF_32.logic_elements), '--', 'Color', 'k');
plot((GF_64.N - GF_64.K)/2, extract_num_logic_cells(GF_64.logic_elements), '-.', 'Color', 'k');
plot((GF_128.N - GF_128.K)/2, extract_num_logic_cells(GF_128.logic_elements), '-*', 'Color', 'k');
plot((GF_256.N - GF_256.K)/2, extract_num_logic_cells(GF_256.logic_elements), '-s', 'Color', 'k');
title('RS Encoder: LE Utilization')
ylabel('LE')
xlabel('T')

subplot(3,1,2);
hold on;
plot((GF_16.N - GF_16.K)/2, GF_16.registers, '-', 'Color', 'k');
plot((GF_32.N - GF_32.K)/2, GF_32.registers, '--', 'Color', 'k');
plot((GF_64.N - GF_64.K)/2, GF_64.registers, '-.', 'Color', 'k');
plot((GF_128.N - GF_128.K)/2, GF_128.registers, '-*', 'Color', 'k');
plot((GF_256.N - GF_256.K)/2, GF_256.registers, '-s', 'Color', 'k');
title('RS Encoder: RE Utilization')
ylabel('RE')
xlabel('T')

subplot(3,1,3);
hold on;
plot((GF_16.N - GF_16.K)/2, GF_16.fmax, '-', 'Color', 'k');
plot((GF_32.N - GF_32.K)/2, GF_32.fmax, '--', 'Color', 'k');
plot((GF_64.N - GF_64.K)/2, GF_64.fmax, '-.', 'Color', 'k');
plot((GF_128.N - GF_128.K)/2, GF_128.fmax, '-*', 'Color', 'k');
plot((GF_256.N - GF_256.K)/2, GF_256.fmax, '-s', 'Color', 'k');
title('RS Encoder: Maximum clock frequency (F_{max})')
ylabel('F_{max} (MHz)')
xlabel('T')
legend('m = 4', 'm = 5', 'm = 6', 'm = 7', 'm = 8' )
figure(2);
subplot(3,1,1);
hold on;
plot((GF_16_2.N - GF_16_2.K)/2, extract_num_logic_cells(GF_16_2.logic_elements), '-', 'Color', 'k');
plot((GF_32_2.N - GF_32_2.K)/2, extract_num_logic_cells(GF_32_2.logic_elements), '--', 'Color', 'k');
plot((GF_64_2.N - GF_64_2.K)/2, extract_num_logic_cells(GF_64_2.logic_elements), '-.', 'Color', 'k');
plot((GF_128_2.N - GF_128_2.K)/2, extract_num_logic_cells(GF_128_2.logic_elements), '-*', 'Color', 'k');
plot((GF_256_2.N - GF_256_2.K)/2, extract_num_logic_cells(GF_256_2.logic_elements), '-s', 'Color', 'k');
title('RS Decoder: LE Utilization')
ylabel('LE')
xlabel('T')

subplot(3,1,2);
hold on;
plot((GF_16_2.N - GF_16_2.K)/2, GF_16_2.registers, '-', 'Color', 'k');
plot((GF_32_2.N - GF_32_2.K)/2, GF_32_2.registers, '--', 'Color', 'k');
plot((GF_64_2.N - GF_64_2.K)/2, GF_64_2.registers, '-.', 'Color', 'k');
plot((GF_128_2.N - GF_128_2.K)/2, GF_128_2.registers, '-*', 'Color', 'k');
plot((GF_256_2.N - GF_256_2.K)/2, GF_256_2.registers, '-s', 'Color', 'k');
title('RS Decoder: RE Utilization')
ylabel('RE')
xlabel('T')

subplot(3,1,3);
hold on;
plot((GF_16_2.N - GF_16_2.K)/2, GF_16_2.fmax, '-', 'Color', 'k');
plot((GF_32_2.N - GF_32_2.K)/2, GF_32_2.fmax, '--', 'Color', 'k');
plot((GF_64_2.N - GF_64_2.K)/2, GF_64_2.fmax, '-.', 'Color', 'k');
plot((GF_128_2.N - GF_128_2.K)/2, GF_128_2.fmax, '-*', 'Color', 'k');
plot((GF_256_2.N - GF_256_2.K)/2, GF_256_2.fmax, '-s', 'Color', 'k');
title('RS Decoder: Maximum Clock Frequency (F_{max})')
ylabel('F_{max} (MHz)')
xlabel('T')


%leg1=legend(legend);
legend('m = 4', 'm = 5', 'm = 6', 'm = 7', 'm = 8' )
 %set(leg1,'Position',[p1 p2 p3 p4]);
%b = extract_num_logic_cells(csv_data(:,4))

%a = table2cell(csv_data(:,4))
%for each
%conver
%remove blab
%a = table2cell(csv_data(:,4))
%plot(str2num(char(n)))
%add

%f=fit(GF_16.N - GF_16.K,extract_num_logic_cells(GF_16.logic_elements)','poly2')
