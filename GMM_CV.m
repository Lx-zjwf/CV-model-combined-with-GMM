function LSF_GMM=GMM_CV(LSF,Img,mu,nu,epsilon,step)
%计算曲率
[XDiff,YDiff]=gradient(LSF);  %求行列方向上地梯度
magnitude=sqrt(XDiff.^2+YDiff.^2);
[diffRow,diffCol]=size(magnitude);
NXDiff=zeros(diffRow,diffCol);
NYDiff=zeros(diffRow,diffCol);
for i=1:diffRow
    for j=1:diffCol
        if(magnitude(i,j)==0)
            NXDiff(i,j)=0;
            NYDiff(i,j)=0;
        else
            NXDiff(i,j)=XDiff(i,j)./magnitude(i,j);
            NYDiff(i,j)=YDiff(i,j)./magnitude(i,j);
        end
    end
end

cur=NXDiff+NYDiff;

%长度项
Length=nu*Delta(LSF,epsilon).*cur;

%规则项
elem=fspecial('laplacian',0);
Lap=imfilter(LSF,elem,'replicate');
Penalty=mu*(Lap-cur);

%CV项（图像像素）
fgdSum=sum(sum(Heaviside(LSF,epsilon).*Img));
fgdWeightSum=sum(sum(Heaviside(LSF,epsilon)));
fgdMean=fgdSum/fgdWeightSum;
bgdSum=sum(sum((1-Heaviside(LSF,epsilon)).*Img));
bgdWeightSum=sum(sum(1-Heaviside(LSF,epsilon)));
bgdMean=bgdSum/bgdWeightSum;
CVterm=Delta(LSF,epsilon).*((-1*(Img-fgdMean).*(Img-fgdMean)...
    +1*(Img-bgdMean).*(Img-bgdMean)));

%根据高斯混合模型求得CV项
[fgdGMMMean,bgdGMMMean]=pixelMeanCalc(Img);
GMMterm=Delta(LSF,epsilon).*((-1*(Img-fgdGMMMean).*(Img-fgdGMMMean)...
    +1*(Img-bgdGMMMean).*(Img-bgdGMMMean)));

%三项相加
LSF_CV=LSF+step*(Length+CVterm+Penalty);
LSF_GMM=LSF+step*(Length+GMMterm+Penalty);
end

%找出每个像素属于第ci个模型的概率
function prob=modelProb(ci,model,pixel,inverseCovs)
diff=pixel-model(ci,2);
mult=diff*diff*inverseCovs(ci);
prob=1.0/sqrt(model(ci,3))*exp(-0.5*mult);
end

%计算像素点属于（前/背景）高斯混合模型的概率
function probSum=mixModelProb(model,pixel,inverseCovs, compCount)
probSum=0;
for ci=1:compCount
    if(model(ci,3)==0)
        model(ci,3)=1e-10;
    end
    probSum=probSum+model(ci,1)*modelProb(ci,model,pixel,inverseCovs);
end
end


%计算前景和背景的像素均值
function [fgdPixelMean,bgdPixelMean]=pixelMeanCalc(img)
global bgdGMM bgdInvCovs fgdGMM; %fgdInvCovs
global fgdCompCount bgdCompCount;
%fgdPixelSum=0;
%fgdCoefSum=0;
bgdPixelSum=0;
bgdCoefSum=0;
[rows,cols]=size(img);
for i=1:rows
    for j=1:cols
        pixel=img(i,j);
        %根据高斯混合模型加权算出前景均值
        %fgdModelProb=mixModelProb(fgdGMM,pixel,fgdInvCovs, fgdCompCount);
        %fgdCoefSum=fgdCoefSum+fgdModelProb;
        %fgdPixelSum=fgdPixelSum+fgdModelProb*pixel;
        
        bgdModelProb=mixModelProb(bgdGMM,pixel,bgdInvCovs, bgdCompCount);
        bgdCoefSum=bgdCoefSum+bgdModelProb;
		bgdPixelSum=bgdPixelSum+bgdModelProb*pixel;
    end
end
%fgdPixelMean=fgdPixelSum/fgdCoefSum;
bgdPixelMean=bgdPixelSum/bgdCoefSum;
%前景均值选择数量充足且像素与背景像素差异明显的子模型的均值
maxDiff=0;
for n=1:fgdCompCount
    if(fgdGMM(n,1)>=0.05)
        modelPixel=fgdGMM(n,2);
        pixelDiff=abs(modelPixel-bgdPixelMean);
        if(pixelDiff>maxDiff)
            maxDiff=pixelDiff;
            fgdPixelMean=modelPixel;
        end
    end
end
end