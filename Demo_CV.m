clc;
clear;
close all;
srcImg=imread('image_for_paper/wrench.jpg');
[row,col,channels]=size(srcImg);
if(channels==3)
    grayImg=rgb2gray(srcImg);
else
    grayImg=srcImg;
end
Img=double(grayImg);

% get the size
[nrow,ncol] =size(Img);
LSF=zeros(nrow,ncol)+0.1;   %水平集演化图像
LSF(nrow*1/3:nrow*2/3,ncol*1/3:ncol*2/3)=-0.1;

figure;
imagesc(Img,[0 255]);colormap(gray)
hold on;
contour(LSF,[0 0],'r');

%水平集演化过程
LevelSetEvo(Img,LSF);
