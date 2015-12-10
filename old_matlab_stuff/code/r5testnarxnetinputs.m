% The purpose of this test is to assess the improvement in performance that
% comes of varying inputs to the network to predict output of EUR/USD. The inputs being assessed are: 
% 1-close
% 2-high
% 3-low
% 4-volume
% 5-RSI
% 6-arithmetic momentum
% 7-geometric momentum
% 8-GBP/USD
% 
% The next iteration will test other currency values as well. Generaliztion
% is not tested here, as it doesn't seem to work well. 

clear all
clc
%define period delay for momentum and RSI
period=14; 
numdsets=5; 

%initializing input matrices
a=cell(numdsets,1); 
close=cell(numdsets,1); 
vol=cell(numdsets,1); 
maxi=cell(numdsets,1); 
mini=cell(numdsets,1); 
rsi=cell(numdsets,1); 
targets=cell(numdsets,1); 
curr=cell(numdsets,1); 


%reading in data for training
%targets will  be placed in cells
[a{1},~,~]=xlsread('eurusdn1.xlsx');
[a{2},~,~]=xlsread('eurusdn2.xlsx'); 
[a{3},~,~]=xlsread('eurusdn3.xlsx'); 
[a{4},~,~]=xlsread('eurusdn3.xlsx'); 
[a{5},~,~]=xlsread('gbpusdn1.xlsx'); 

%read in currencies for comparison
[a{6},~,~]=xlsread('gbpusdn2.xlsx');
[a{7},~,~]=xlsread('gbpusdn3.xlsx');

%a{3} is to be used for generalization
for i=1:numdsets; %the currency comps must be customized 
%RSI of closing prices
rsi{i}=calc_RSI(a{i}(:,4),14)'; 
close=a{i}(period+1:end,4); 
targets{i}=con2seq(close'); 
vol{i}=a{i}(period+1:end,2); 
maxi{i}=a{i}(period+1:end,6); 
mini{i}=a{i}(period+1:end,5); 

end
curr{1}=a{5}(period+1:end,4); 
curr{2}=a{6}(period+1:end,4);
curr{3}=a{7}(period+1:end,4); 
curr{4}=a{7}(period+1:end,4); 
curr{5}=a{1}(period+1:end,4); 

%putting inputs into a struct
inputs=struct('vol',{vol},'max',{maxi},'min',{mini},'rsi',{rsi},'curr',{curr}); 
inputnames=fieldnames(inputs); 

%trial iterations----------------------------------------------------
iter=20; 

d=cell(iter,1); 
iresults=struct('r',{d},'mse',{d},'tog',{d},'del',{d},'diff',{d},'net',{d},'netw',{d},'inw',{d}); 

clear d

%defining constants
numnet=5; 
numdat=4; 

maxn=30; 
stepsizen=10; 
minn=30; 

maxd=30; 
stepsized=10; 
mind=30; 

%vector for self-testing nets
vec=[1 2 5]; 

for numiter=1:iter
numiter
%initializing results matrices
% two rows of cells resultsr and resultsmse will remain emtpy because
%generalization data is not being collected for them



c=cell(numnet,1); 
resultsr=c;
resultsmse=c;
resultstog=c ;
resultsdel=c;
resultsdiff=c;
coninput=c; 
net=c;
netw=c;
inw=c; %for net weights
clear c
for n=1:numnet; 
    initial=zeros((maxn-minn)/stepsizen+1,length(inputnames),(maxd-mind)/stepsized+1); 
    initialc=cell((maxn-minn)/stepsizen+1,length(inputnames),(maxd-mind)/stepsized+1); 
    resultsr{n}=initial; 
    resultsmse{n}=initial;
    resultstog{n}=initial;
    resultsdel{n}=initial;
    resultsdiff{n}=initial; 
    net{n}=initialc; 
    netw{n}=initialc; 
    inw{n}=initialc; %the strength of input weights, for comparison
end



% testing loop definition
%this is specific to two hidden-layer nets

 
for i=minn:stepsizen:maxn; 
    size1=i
    for j=mind:stepsized:maxd; 
    delay=j
        for k=1:length(inputnames); 
            k
             %define coninput
             
             for c=1:numnet; 
                 temp=[]; 
             for n=1:k
                 temp=[temp; inputs.(inputnames{k}){c}']; 
             end
             temp=con2seq(temp);
             coninput{c}=temp; 
             end
           
                

%define cells
%row 1, 2, and 5 are self-tests on data sets 1, 2, and 5; 3 is 13 and 4 is 23
output=cell(numnet,1); 
targetsdiff=cell(numnet,1);
outputdiff=cell(numnet,1); 



%defining indices
numhid=(i-minn)/stepsizen+1; 
numdelay=(j-mind)/stepsized+1;

%define nets

tr=cell(numnet); 
for n=vec; 
net{n}{numhid,k,numdelay}=narxnet([1:delay],[1:delay],[size1]); 
end



%train for all self-testing nets
for n=vec; 
[p,pi,~,t]=preparets(net{n}{numhid,k,numdelay},coninput{n},{},targets{n}); 
[net{n}{numhid,k,numdelay},tr{n}]=train(net{n}{numhid,k,numdelay},p,t,pi); 
% net.trainParam.showWindow=0; 
nntraintool('close')
output{n}=net{n}{numhid,k,numdelay}(p,pi); 

%storing weight strengths
netw{n}{numhid,k,numdelay}=zeros(k,1); 
for c=1:k;  
netw{n}{numhid,k,numdelay}(c)=sum(abs(mean(net{n}{numhid,k,numdelay}.IW{1,1}(:,c:k:(end-(k-c))),2).*net{n}{numhid,k,numdelay}.LW{2,1}')); 
end
%for feedback input only
inw{n}{numhid,k,numdelay}=sum(abs(mean(net{n}{numhid,k,numdelay}.IW{1,2},2).*net{n}{numhid,k,numdelay}.LW{2,1}'));
end

netw{3}{numhid,k,numdelay}=0; 
netw{4}{numhid,k,numdelay}=0; 
inw{3}{numhid,k,numdelay}=0; 
inw{4}{numhid,k,numdelay}=0; 

%output for different data
[p,pi,~,~]=preparets(net{1}{numhid,k,numdelay},coninput{3},{},targets{3}); 
output{3}=net{1}{numhid,k,numdelay}(p,pi); 

[p,pi,~,~]=preparets(net{2}{numhid,k,numdelay},coninput{3},{},targets{3}); 
output{4}=net{2}{numhid,k,numdelay}(p,pi); 


%diagnostics for self-testing data sets
for n=vec; 
tsOut = output{n}(tr{n}.testInd);
tsTarg = targets{n}(tr{n}.testInd);
whichstats={'rsquare','mse'}; 
stats=regstats(cell2mat(tsOut),cell2mat(tsTarg),'linear',whichstats); 
resultsr{n}(numhid,k,numdelay)=stats.rsquare; 
resultsmse{n}(numhid,k,numdelay)=stats.mse; 
end

%convert targets to right size
targetmat=cell(numnet,1); 
for n=1:numnet; 
targetmat{n}=cell2mat(targets{n}); 
targetmat{n}=targetmat{n}(1+delay:end); 
end


%test ups and downs
for n=1:numnet; 
    
targetsdiff{n}=diff(targetmat{n}); 
outputdiff{n}=diff(cell2mat(output{n})); 
numuptog=sum((targetsdiff{n}>0).*(outputdiff{n}>0)); 
numdowntog=sum((targetsdiff{n}<0).*(outputdiff{n}<0));
numtog=numuptog+numdowntog; 
resultstog{n}(numhid,k,numdelay)=numtog; 

end


%regression on deltas
for n=1:numnet; 
whichstats={'rsquare'}; 
stats=regstats(targetsdiff{n},outputdiff{n},'linear',whichstats); 
resultsdel{n}(numhid,k,numdelay)=stats.rsquare;
end

for n=1:numnet; 
    %ups only
    differ=(targetmat{n}(2:end)-cell2mat(output{n}(2:end))) ; 
differ=differ(logical((targetsdiff{n}>0).*(outputdiff{n}>0)));
differ=differ<.001; 
resultsdiff{n}(numhid,k,numdelay)=sum(differ); 

%downs only
differ=(targetmat{n}(2:end)-cell2mat(output{n}(2:end))) ; 
differ=differ(logical((targetsdiff{n}<0).*(outputdiff{n}<0)));
differ=differ<.001; 
resultsdiff{n}(numhid,k,numdelay)=resultsdiff{n}(numhid,k,numdelay)+sum(differ); 
end

    end
end
end

%computing how good this thing is
for n=1:numnet; 
    for k=1:numdelay; 
     resultstog{n}(:,:,k)=resultstog{n}(:,:,k)/(500-period-(k*stepsized+mind-stepsized)-1); 
     resultsdiff{n}(:,:,k)=resultsdiff{n}(:,:,k)/(500-period-(k*stepsized+mind-stepsized)-1); 
    end
end

iresults.r{numiter}=resultsr;
iresults.mse{numiter}=resultsmse;
iresults.tog{numiter}=resultstog ;
iresults.del{numiter}=resultsdel;
iresults.diff{numiter}=resultsdiff; 
iresults.net{numiter}=net; 

iresults.netw{numiter}=netw; 
iresults.inw{numiter}=inw; 
end

r9iresults=iresults; 


save('r9iresults','r9iresults')


%analysing data

%single layer network-------------------------------------------------


%initializing  cells
%column 1 is for average, 2 for std, 3 for max, 4 for min
c=cell(numnet,4); 
avresults=struct('r',{c},'mse',{c},'tog',{c},'del',{c},'diff',{c},'netw',{c},'inw',{c}); 
clear c

for n=1:numnet; 
    for m=1:4; 
   
   avresults.r{n,m}=initial;
    avresults.mse{n,m}=initial;
    avresults.tog{n,m}=initial ;
    avresults.del{n,m}=initial;
    avresults.diff{n,m}=initial; 
   avresults.netw{n,m}=initialc; 
   avresults.inw{n,m}=initialc; 
    end
end



%obtaining averaged results for each type of output

%all except average
sinitial=size(initial);
sinitial(3)=1; 
indx=sinitial(1)*sinitial(2)*sinitial(3); 
v=zeros(iter,indx); 
namesf=fieldnames(avresults); 
names=namesf(1:end-2); 


%initializing avresults for netw and inw
for a=[namesf{7} namesf{6}]; 
    for j=1:numnet; 
        for i=1:iter; 
             for x=1:sinitial(1); 
                for y=1:sinitial(2); 
                    for z=1:sinitial(3); 
                 avresults.(namesf{a}){j,1}{x,y,z}=iresults.(namesf{a}){i}{j,1}{x,y,z}*0; 
                    end
                end
             end
        end
    end
end


for a=1:numel(names); 
for j=1:numnet; 
    for i=1:iter;
      for k=1:indx; 
          v(i,k)=iresults.(names{a}){i}{j}(k); %linearize matrix
      end
    end
    mx=max(v); 
    mn=min(v); 
    v=std(v);
    
      for k=1:indx;
        [x,y,z]=ind2sub([sinitial(1),sinitial(2),sinitial(3)],k); 
        avresults.(names{a}){j,2}(x,y,z)=v(k); 
        avresults.(names{a}){j,3}(x,y,z)=mx(k);
        avresults.(names{a}){j,4}(x,y,z)=mn(k);
      end
end
end

%averaging

for a=1:numel(namesf); 
for j=1:numnet; 
    for i=1:iter; 
        if a==length(namesf)||a==length(namesf)-1; 
        %in case of netw or inw
        for x=1:sinitial(1); 
            for y=1:sinitial(2); 
                for z=1:sinitial(3); 
                 avresults.(namesf{a}){j,1}{x,y,z}=avresults.(namesf{a}){j,1}{x,y,z}+iresults.(namesf{a}){i}{j,1}{x,y,z}; 
                end
            end
        end
        end
        avresults.(namesf{a}){j,1}=avresults.(namesf{a}){j,1}+iresults.(namesf{a}){i}{j,1}; 
    end
        if a==length(namesf)||a==length(namesf)-1; 
        %in case of netw or inw
        for x=1:sinitial(1); 
            for y=1:sinitial(2); 
                for z=1:sinitial(3); 
                 avresults.(namesf{a}){j,1}{x,y,z}=avresults.(namesf{a}){j,1}{x,y,z}/iter; 
                end
            end
        end
        end
    avresults.(namesf{a}){j,1}= avresults.(namesf{a}){j,1}/iter; 
end
end

r9avresults=avresults; 
save('r9avresults','r9avresults')

