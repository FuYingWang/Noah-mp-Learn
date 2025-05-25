clc;clear;

CMFD_name    = {  'lrad',   'prec',  'pres','shum','srad', 'temp','wind'}; % CMFD的变量名
scale_factor  = [  1 ,   1/3600,  1,    1,  1,  1,   1 ]; % 单位比例
LDASIN_varable = {'LWDOWN','RAINRATE','PSFC','Q2D','SWDOWN','T2D','U2D','V2D','LAI','SHDFAC'}; % GLDAS变量名+ LAI+SHDFAC
out_pwd = 'D:\NoahMp\test\';
in_dir='D:\NoahMp\CMFD\';


A_lon = ncread('D:\NoahMp\CMFD\temp_CMFD_V0106_B-01_03hr_010deg_201010.nc', 'lon');  % 假设经度变量名为'lon'，尺寸700x1
A_lat = ncread('D:\NoahMp\CMFD\temp_CMFD_V0106_B-01_03hr_010deg_201010.nc', 'lat');  % 假设纬度变量名为'lat'，尺寸400x1

% Step0: 获得LAI/FVC
LAI_dir = 'D:\NoahMp\LAI\S4_interp\' ;
LAI_file = dir(fullfile(LAI_dir, '*.tif'));
for i=1:length(LAI_file)
    GLASS_Date{i,1} = LAI_file(i).name(17:23);
end  

FVC_dir = 'D:\NoahMp\FVC\S4_interp\' ;
FVC_file = dir(fullfile(FVC_dir, '*.tif'));
% Step1: 获得CMFD文件月份时间
D1 =  dir(fullfile(in_dir, '*lrad*'));  % 记载单变量nc名字
for i=1:length(D1)
    Month_str{i,1} = D1(i).name(34:39);
end

% Step2: 提取出每个月具体时间(年月日小时)
for mm = 3%1:length(Month_str)  % 第i个月
    var_month =   dir(fullfile(in_dir, strcat('*',Month_str{mm},'*')));  % 记载单变量nc名字
    nc_name = strcat( in_dir , var_month(1).name ) ;  % 单个nc文件
    ncdisp(nc_name);  % 查看nc文件属性
    includ_time = datestr(  datetime(1900, 1, 1, 0, 0, 0) + hours(double(ncread(nc_name,'time'))) , 'yyyymmddHH');  % 单个月包含的时间

% Step3: 提取(年月日小时)CMFD数据
    for var_idx = 1:7
        Data_source = strcat ( in_dir , '\' , var_month(var_idx).name ) ; % 要读取的nc名字
        Data = ncread( Data_source , CMFD_name{var_idx} );  % 读取nc的具体值
        Data_conv =  Data*scale_factor(var_idx);    % 单位转换
        Data_CMFD_Single_Month{var_idx} = Data_conv;
    end

% Step3: 创建年月日小时.LDASIN_  nc文件    
    for i_hour = 4%:length(includ_time) % 第i个小时
        YYMMDDHH = includ_time(i_hour,:);
        LDASIN_name=strcat( out_pwd, '\' , YYMMDDHH, '.LDASIN_DOMAIN1' );
        cncid=netcdf.create(LDASIN_name,'CLOBBER');  % 创建nc .LDASIN_DOMAIN1文件
% Step4: 创建变量
        lon_dim = netcdf.defDim(cncid, 'lon', 700);    % 原700列 -> lon维度
        lat_dim = netcdf.defDim(cncid, 'lat', 400);    % 原400行 -> lat维度
        time_dim = netcdf.defDim(cncid, 'time', 1);
        lon_id = netcdf.defVar(cncid, 'lon', 'double', lon_dim);
        netcdf.putAtt(cncid, lon_id, 'units', 'degrees_east');
        lat_id = netcdf.defVar(cncid, 'lat', 'double', lat_dim);
        netcdf.putAtt(cncid, lat_id, 'units', 'degrees_north');
        for LDASIN_var_idx = 1:10
            varID(LDASIN_var_idx) = netcdf.defVar(cncid, LDASIN_varable{LDASIN_var_idx}, 'float', [lon_dim, lat_dim, time_dim]);
        end
        netcdf.endDef(cncid);
        netcdf.putVar(cncid, lon_id, A_lon);
        netcdf.putVar(cncid, lat_id, A_lat);
% Step5: 写入CMFD变量值
        for var_idx = 1:7
            netcdf.putVar(cncid, varID(var_idx), Data_CMFD_Single_Month{var_idx}(:,:,i_hour));  % 写入
            netcdf.putVar(cncid, varID(8),       Data_CMFD_Single_Month{var_idx}(:,:,i_hour).*0);       % V2D设为0
        end

% Step6: 写入LAI/FAC变量值 
        dt = datetime(YYMMDDHH, 'InputFormat', 'yyyyMMddHH'); 
        YYDD = sprintf('%d%03d', year(dt), day(dt, 'dayofyear') );  % 转为年自然日
        if ~isempty ( find(ismember(GLASS_Date,YYDD), 1) )  
            % LAI
            LAI_name = strcat(  LAI_dir , '\' , LAI_file( find(ismember(GLASS_Date,YYDD), 1)  ).name);
            [LAI_Data,~]  = readgeoraster( LAI_name );  % 读取LAI值
            LAI_Data=rot90(LAI_Data, -1);    LAI_Data(LAI_Data<0|LAI_Data>7)=NaN;            % 调整LAI
            netcdf.putVar(cncid,varID(9),LAI_Data);  % 写入
            % FVC
            FVC_name = strcat(  FVC_dir , '\' , FVC_file( find(ismember(GLASS_Date,YYDD), 1)  ).name);
            [FVC_Data,~]  = readgeoraster( FVC_name );  % 读取FVC值
            FVC_Data=rot90(double(FVC_Data), -1);   FVC_Data(FVC_Data>1)=NaN;  % 调整fvc
            netcdf.putVar(cncid,varID(10),FVC_Data);  % 写入
        end

% Step7: 结束       
        netcdf.close(cncid);
    end
end

% Step8: 经纬度信息
mean_lat = (min(A_lat(:))+max(A_lat(:)))/2 ;
mean_lon = (min(A_lon(:))+max(A_lon(:)))/2 ;






%   lrad : Surface downward longwave radiation (W m-2)
%   prec : Precipitation rate (mm hr-1)
%   pres : Near surface air pressure (Pa)
%   shum : 'Near surface air specific humidity' (kg/kg)
%   srad : Surface downward shortwave radiation (W m-2)
%   temp : Near surface air temperature (K)
%   wind : 'Near surface wind speed' (m/s)