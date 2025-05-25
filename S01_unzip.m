clc;clear
gzFolder = 'D:\NoahMp\CMFD'; % 替换为你的实际路径
% 指定解压后的输出文件夹（可选，默认为当前文件夹）
outputFolder = 'D:\NoahMp\CMFD'; % 可选，若省略则解压到原文件夹

% 获取所有.gz文件的路径
gzFiles = fullfile(gzFolder, '*.gz');

% 解压所有.gz文件
gunzip(gzFiles, outputFolder);

disp('解压完成！');






