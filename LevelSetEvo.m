function LevelSetEvo(Img,LSF)
global fgdInvCovs bgdInvCovs fgdGMM bgdGMM mask compIdxs;
global fgdCompCount bgdCompCount
fgdCompCount=3;
bgdCompCount=1;
[fgdGMM,fgdInvCovs]=defGMMVal(fgdCompCount);
[bgdGMM,bgdInvCovs]=defGMMVal(bgdCompCount);
[rows,cols]=size(Img);
mask=zeros(rows,cols);
compIdxs=zeros(rows,cols);
BGD=-1;
FGD=1;
%划分前景和背景区域
mask=mask+BGD;
mask(rows/3:rows*2/3,cols/3:cols*2/3)=FGD;
initGMMs(Img);

numIter=1e4;
timestep=0.1;
lambda_1=1;
lambda_2=1;
epsilon=1;
nu=0.001*255*255;  % tune this parameter for different images
mu=1;
t1=clock;
for k=1:numIter
    assignGMMsComponents(Img);
    learnGMMs(Img);
    %不含高斯的水平集演化过程
    %LSF=EVOL_CV(Img, LSF, nu, lambda_1, lambda_2, timestep, epsilon);
    LSF=GMM_CV(LSF,Img,mu,nu,epsilon,timestep);
    
    pause(.1);
    imagesc(Img,[0 255]);
    colormap(gray);
    axis off;
    hold on;
    contour(LSF,[0 0],'r');
    hold off;
        
    for m=1:rows
        for n=1:cols
            if(LSF(m,n)<0)
                mask(m, n)=BGD;
            elseif(LSF(m,n)>=0)
                mask(m, n)=FGD;
            end
        end
    end
    t2=clock;
    cost_time=etime(t2,t1);
    disp(strcat('iter num:',num2str(k)));
    disp(strcat('cost time:',num2str(cost_time)));
end
end


%初始化高斯混合模型
function [model,inverseCovs]=defGMMVal(compCount)
model=zeros(compCount,3);
inverseCovs=zeros(1,compCount);
for i=1:1:compCount
    if(model(i,1)>0)
        inverseCovs(1,i)=1.0/(model(i,3)+1e-5);  %协方差的逆
    end
end
end


%通过mask来判断该像素属于背景像素还是前景像素，再判断它属于前景或者背景GMM中的哪个高斯分量
function assignGMMsComponents(img)
global mask bgdGMM fgdGMM bgdInvCovs fgdInvCovs compIdxs;
global fgdCompCount bgdCompCount;
BGD=-1;
FGD=1;
[rows,cols]=size(img);
for i=1:rows
    for j=1:cols
        pixel=img(i,j);
        if(mask(i,j)==BGD)
            %标记对应的子模型序号
            compIdxs(i,j)=whichComponent(pixel,bgdGMM,bgdInvCovs,bgdCompCount);
        elseif(mask(i,j)==FGD)
            compIdxs(i,j)=whichComponent(pixel,fgdGMM,fgdInvCovs,fgdCompCount);
        end
    end
end
end


%找出每个像素点对应的概率最大的子模型
function comp=whichComponent(pixel,model,inverseCovs,compCount)
max=-1;
for ci=1:compCount
    prob=modelProb(ci,model,pixel,inverseCovs);
    %找出概率最大的子模型
    if(prob>max)
        comp=ci;
        max=prob;
    end
end
end


%找出每个像素属于第ci个模型的概率
function prob=modelProb(ci,model,pixel,inverseCovs)
diff=pixel-model(ci,2);
mult=diff*diff*inverseCovs(ci);
prob=1.0/sqrt(model(ci,3))*exp(-0.5*mult); 
end


%学习GMM模型
function learnGMMs(img)
global fgdCompCount bgdCompCount;
global mask compIdxs bgdGMM fgdGMM bgdInvCovs fgdInvCovs;
[fgdSums,fgdProds,fgdSmpCounts,fgdTotalSmp]=initLearn(fgdCompCount);
[bgdSums,bgdProds,bgdSmpCounts,bgdTotalSmp]=initLearn(bgdCompCount);
[rows,cols]=size(img);
BGD=-1;
FGD=1;
for ci=1:fgdCompCount
    for i=1:rows
        for j=1:cols
            pixel=img(i,j);
            if(compIdxs(i,j)==ci && mask(i,j)==FGD)
                [fgdSums,fgdProds,fgdSmpCounts,fgdTotalSmp]=...
                    addSample(ci,pixel,fgdSums,fgdProds,fgdSmpCounts,fgdTotalSmp);
            end
        end
    end
end
for ci=1:bgdCompCount
    for i=1:rows
        for j=1:cols
            pixel=img(i,j);
            if(compIdxs(i,j)==ci && mask(i,j)==BGD)
                [bgdSums,bgdProds,bgdSmpCounts,bgdTotalSmp]=...
                    addSample(ci,pixel,bgdSums,bgdProds,bgdSmpCounts,bgdTotalSmp);
            end
        end
    end
end
[fgdGMM,fgdInvCovs]=endLearn(fgdSmpCounts,fgdTotalSmp,fgdSums,fgdProds,fgdInvCovs,fgdCompCount);
[bgdGMM,bgdInvCovs]=endLearn(bgdSmpCounts,bgdTotalSmp,bgdSums,bgdProds,bgdInvCovs,bgdCompCount);
end

% K均值法初步计算高斯混合模型
function initGMMs(img)
global fgdCompCount bgdCompCount;
global bgdGMM fgdGMM mask bgdInvCovs fgdInvCovs;
BGD=-1;
FGD=1;
bgdSamples=[];
fgdSamples=[];
[rows,cols]=size(img);
for i=1:rows
    for j=1:cols
        pixel=img(i,j);
        if(mask(i,j)==BGD)
            bgdSamples=[bgdSamples pixel];
        elseif(mask(i,j)==FGD)
            fgdSamples=[fgdSamples pixel];
        end
    end
end
bgdSmpLen=length(bgdSamples);
fgdSmpLen=length(fgdSamples);
bgdSamples=reshape(bgdSamples,bgdSmpLen,1);
fgdSamples=reshape(fgdSamples,fgdSmpLen,1);
fgdLabels=kmeans(fgdSamples,fgdCompCount);
bgdLabels=kmeans(bgdSamples,bgdCompCount);
%因为没有类的区分，所以为前景和背景各设置对应的参数
[fgdSums,fgdProds,fgdSmpCounts,fgdTotalSmp]=initLearn(fgdCompCount);
[bgdSums,bgdProds,bgdSmpCounts,bgdTotalSmp]=initLearn(bgdCompCount);
%为前景和背景模型增加元素
for i=1:bgdSmpLen
    label=bgdLabels(i);
    pixel=bgdSamples(i);
    [bgdSums,bgdProds,bgdSmpCounts,bgdTotalSmp]=...
        addSample(label,pixel,bgdSums,bgdProds,bgdSmpCounts,bgdTotalSmp);
end
for i=1:fgdSmpLen
    label=fgdLabels(i);
    pixel=fgdSamples(i);
    [fgdSums,fgdProds,fgdSmpCounts,fgdTotalSmp]=...
        addSample(label,pixel,fgdSums,fgdProds,fgdSmpCounts,fgdTotalSmp);
end

[fgdGMM,fgdInvCovs]=endLearn(fgdSmpCounts,fgdTotalSmp,fgdSums,fgdProds,fgdInvCovs,fgdCompCount);
[bgdGMM,bgdInvCovs]=endLearn(bgdSmpCounts,bgdTotalSmp,bgdSums,bgdProds,bgdInvCovs,bgdCompCount);
end


% GMM模型参数最终计算
function [model,inverseCovs]=endLearn(smpCounts,totalSmpCounts,sum,prods,inverseCovs,compCount)
variance=1e-3;
for ci=1:compCount
    n=smpCounts(ci);
    if(n==0)
        model(ci,1)=0;
    else
        model(ci,1)=n/totalSmpCounts;  % 计算第ci个高斯模型的权值系数
        model(ci,2)=sum(ci)/n;  % 子模型的均值
        model(ci,3)=prods(ci)/n-model(ci,2)*model(ci,2);  % 子模型的方差
        if(model(ci,3)<1e-7)
            model(ci,3)=model(ci,3)+variance;
        end
        inverseCovs(ci)=1.0/model(ci,3);
    end
end
end

%为每个高斯混合模型增添实力并修改参数值
function [sum,prods,smpCounts,totalSmpCount]=...
    addSample(ci,pixel,sum,prods,smpCounts,totalSmpCount)
sum(ci)=sum(ci)+pixel;
prods(ci)=prods(ci)+pixel*pixel;
smpCounts(ci)=smpCounts(ci)+1;
totalSmpCount=totalSmpCount+1;
end


%初步定义子模型的计算量
function [sums,prods,smpCounts,totalSmpCount]=initLearn(compCount)
sums=zeros(1,compCount);
prods=zeros(1,compCount);
smpCounts=zeros(1,compCount);
totalSmpCount=0;
end
