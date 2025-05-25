clc;clear

in_path = 'D:\NoahMp\LAI\S3_Tailor\';
known_days = 1:8:361;      % 已知影像的获取天数
total_days = 365;          % 总天数
output_dir = 'D:\NoahMp\LAI\S4_interp\'; % 设置输出目录路径

% 读取第一个文件获取地理参考信息和图像属性
first_file = 'GLASS01B01.V60.A2010001.tif';
[img, R] = readgeoraster( strcat( in_path , first_file ) ); % geotiffread
[rows, cols] = size(img);
% data_type = 'double';

% 预分配内存存储已知影像数据
num_known = length(known_days);
data_3d = zeros(rows, cols, num_known, 'double');

% 读取所有已知影像到内存
for i = 1:num_known
    current_day = known_days(i);
    tifname = sprintf('GLASS01B01.V60.A2010%03d.tif', current_day);
    filename = strcat( in_path , tifname ) ;
    [data_i,~] = readgeoraster(filename);
    data_3d(:,:,i) = double(data_i).*0.1; % FVC 0.04 
end

% 处理每一天并生成结果
for d = 1:total_days
    output_path = fullfile(output_dir, sprintf('GLASS01B01.V60.A2010%03d.tif', d));
    
    if ismember(d, known_days)         % 直接复制已知天数数据
        idx = find(known_days == d);
        geotiffwrite(output_path, data_3d(:,:,idx), R);
    elseif d>361                       % 超过361天
        geotiffwrite(output_path, data_3d(:,:,end), R);
    else
        % 查找相邻已知天数索引
        idx_prev = find(known_days < d, 1, 'last');
        idx_next = find(known_days > d, 1, 'first');
        d_prev = known_days(idx_prev);
        d_next = known_days(idx_next);
        
        % 计算插值权重
        interval = d_next - d_prev;
        weight = (d - d_prev) / interval;
        
        % 执行线性插值
        prev_data = double(data_3d(:,:,idx_prev));
        next_data = double(data_3d(:,:,idx_next));
        interpolated = (1 - weight)*prev_data + weight*next_data;
        % interpolated = cast(interpolated, data_type);
        
        % 写入结果
        geotiffwrite(output_path, interpolated, R);
    end
    fprintf('已生成第%d天影像\n', d);
end


for i= 129:145
a = strcat( 'GLASS01B01.V60.A2010', num2str(i) , '.tif' );
[data,~] = readgeoraster(a);
FVC = data(5,5)*0.1;
disp ( strcat ( num2str(i) , ':' , num2str(FVC) ))
end