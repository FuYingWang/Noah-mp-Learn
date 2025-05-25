clc;clear;

output_file_pwd = 'D:\NoahMp\LDASOUT\' ;
% output_file_pwd = 'D:\Benefit of\FVCRS_version_output_file\' ;
% output_file_pwd = 'D:\Benefit of\LDASIN\';

setup_file = 'D:\NoahMp\HRLDAS_setup_2020010100_d1' ;
ncdisp(setup_file)
%% 输入目标经纬度并寻找最近格点
lat_2d = ncread(setup_file, 'XLAT');   
lon_2d = ncread(setup_file, 'XLONG');  

target_lat = 32; 
target_lon = 91.9;  
[j_l,k_l] = find_LonLat(target_lon,target_lat,lat_2d,lon_2d);
%% 读取LDASOUT文件并提取数据
var_name = 'TG' ; %    FVEG

f = dir(output_file_pwd);  
aa=1;
for i = 1:length(f)
    if ~f(i).isdir
        data{1}{aa,1} = f(i).name;
        data_area = ncread( strcat( output_file_pwd, f(i).name ) , var_name);
        data_point = data_area(j_l,k_l);
        % if data_point>10; data_point=NaN; end
        data{2}(aa,1) = double(data_point);
        aa=aa+1;
    end
end

% save('TG_Review.mat','data')
% save('TG_Origin.mat','data')