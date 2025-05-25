function [sn,we,center_lon,center_lat] = LonLat_correspond_piexl(sample_nc, target_lat, target_lon)

lon = ncread(sample_nc, 'lon'); % 经度数组
lat = ncread(sample_nc, 'lat'); % 纬度数组

% 确定纬度索引（处理降序情况）
if issorted(lat, 'descend')
    lat = flip(lat); % 反转纬度数组为升序
    [~, lat_start] = min(abs(lat - target_lat(1)));
    [~, lat_end] = min(abs(lat - target_lat(2)));
    lat_indices = lat_start:lat_end;
    lat_indices = sort(length(lat) - lat_indices + 1); % 调整原索引
else
    lat_indices = find(lat >= target_lat(1) & lat <= target_lat(2));
end

% 确定经度索引
lon_indices = find(lon >= target_lon(1) & lon <= target_lon(2));

% 确认维度顺序（假设CMFD变量维度为lat × lon × time）
% 检查变量维度顺序
nc_info = ncinfo(sample_nc);
var_name = 'lrad'; % 以lrad变量为例
var_dims = {nc_info.Variables(strcmp({nc_info.Variables.Name}, var_name)).Dimensions.Name};

% if strcmp(var_dims{1}, 'lon') % 维度顺序为lon × lat × time
    % sn = lon_indices; % west_east对应经度
    % we = lat_indices; % south_north对应纬度
% else % 默认lat × lon × time
    sn = lat_indices; % south_north纬度索引
    we = lon_indices; % west_east经度索引
% end

% 验证裁剪后的经纬度范围
A_lon = lon(we);
A_lat = lat(sn);
center_lat = (min(A_lat(:))+max(A_lat(:)))/2 ;
center_lon = (min(A_lon(:))+max(A_lon(:)))/2 ;
% disp(['裁剪后的经度范围：', num2str(min(A_lon)), '至', num2str(max(A_lon))]);
% disp(['裁剪后的纬度范围：', num2str(min(A_lat)), '至', num2str(max(A_lat))]);