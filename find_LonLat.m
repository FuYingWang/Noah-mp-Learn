function [j_l,k_l] = find_LonLat(target_lon,target_lat,lat_2d,lon_2d)
[R] = 6371e3; % 地球半径
dlat = deg2rad(lat_2d - target_lat);
dlon = deg2rad(lon_2d - target_lon);
a = sin(dlat/2).^2 + cos(deg2rad(target_lat)) * cos(deg2rad(lat_2d)) .* sin(dlon/2).^2;
c = 2 * atan2(sqrt(a), sqrt(1-a));
distances = R * c; % 得到每个格点与目标的距离矩阵
% 找到最小距离的索引
[min_dist, min_index] = min(distances(:));
[j_l, k_l] = ind2sub(size(distances), min_index);
end