clear all

sizem=10; 
numnet=5; 

load('r4iresultstog2l.mat')
load('r4iresultsmse2l.mat')
load('r4iresultsdel2l.mat')
load('r4iresultstog2l.mat')
load('r4iresultsdiff2l.mat')
load('r4iresultsr2l.mat')

numcell=5; 

%initializing  cells
%column 1 is for average, 2 for std, 3 for max, 4 for min
c=cell(numcell,4); 
r4avresultsr2l=c;
r4avresultsmse2l=c;
r4avresultstog2l=c ;
r4avresultsdel2l=c;
r4avresultsdiff2l=c; 

clear c

for n=1:numcell; 
    for m=1:4; 
    initial=zeros(3,3,6); 
   r4avresultsr2l{n,m}=initial;
    r4avresultsmse2l{n,m}=initial;
    r4avresultstog2l{n,m}=initial ;
    r4avresultsdel2l{n,m}=initial;
    r4avresultsdiff2l{n,m}=initial; 
   
    end
end

%obtaining averaged results for each type of output
sinitial=size(initial);
indx=sinitial(1)*sinitial(2)*sinitial(3); 
v=zeros(sizem,indx); 
for j=1:numnet; 
    for i=1:sizem;
      for k=1:indx; 
          v(i,k)=iresultsr{i}{j}(k); %linearize matrix
      end
    end
    mx=max(v); 
    mn=min(v); 
    v=std(v);
    
      for k=1:indx;
        [x,y,z]=ind2sub([sinitial(1),sinitial(2),sinitial(3)],k); 
        r4avresultsr2l{j,2}(x,y,z)=v(k); 
        r4avresultsr2l{j,3}(x,y,z)=mx(k);
        r4avresultsr2l{j,4}(x,y,z)=mn(k);
      end
end

for j=1:numnet; 
    for i=1:sizem;
      for k=1:indx; 
          v(i,k)=iresultsmse{i}{j}(k); %linearize matrix
      end
    end
    mx=max(v); 
    mn=min(v); 
    v=std(v); 
      for k=1:indx;
        [x,y,z]=ind2sub([sinitial(1),sinitial(2),sinitial(3)],k); 
        r4avresultsmse2l{j,2}(x,y,z)=v(k); 
        r4avresultsmse2l{j,3}(x,y,z)=mx(k);
        r4avresultsmse2l{j,4}(x,y,z)=mn(k);
      end
end

for j=1:numnet; 
    for i=1:sizem;
      for k=1:indx; 
          v(i,k)=iresultstog{i}{j}(k); %linearize matrix
      end
    end
     mx=max(v); 
    mn=min(v); 
    v=std(v);
      for k=1:indx;
        [x,y,z]=ind2sub([sinitial(1),sinitial(2),sinitial(3)],k); 
        r4avresultstog2l{j,2}(x,y,z)=v(k); 
        r4avresultstog2l{j,3}(x,y,z)=mx(k);
        r4avresultstog2l{j,4}(x,y,z)=mn(k);
      end
end

for j=1:numnet; 
    for i=1:sizem;
      for k=1:indx; 
          v(i,k)=iresultsdel{i}{j}(k); %linearize matrix
      end
    end
     mx=max(v); 
    mn=min(v); 
    v=std(v);
      for k=1:indx;
        [x,y,z]=ind2sub([sinitial(1),sinitial(2),sinitial(3)],k); 
        r4avresultsdel2l{j,2}(x,y,z)=v(k); 
        r4avresultsdel2l{j,3}(x,y,z)=mx(k);
        r4avresultsdel2l{j,4}(x,y,z)=mn(k);
      end
end

for j=1:numnet; 
    for i=1:sizem;
      for k=1:indx; 
          v(i,k)=iresultsdiff{i}{j}(k); %linearize matrix
      end
    end
     mx=max(v); 
    mn=min(v); 
    v=std(v); 
      for k=1:indx;
        [x,y,z]=ind2sub([sinitial(1),sinitial(2),sinitial(3)],k); 
        r4avresultsdiff2l{j,2}(x,y,z)=v(k); 
        r4avresultsdiff2l{j,3}(x,y,z)=mx(k);
        r4avresultsdiff2l{j,4}(x,y,z)=mn(k);
      end
end

for j=1:numnet; 
    for i=1:sizem; 
        r4avresultsr2l{j,1}=r4avresultsr2l{j,1}+iresultsr{i}{j,1}; 
    end
    r4avresultsr2l{j,1}= r4avresultsr2l{j,1}/sizem; 
end

for j=1:numnet; 
    for i=1:sizem; 
        r4avresultsmse2l{j,1}=r4avresultsmse2l{j,1}+iresultsmse{i}{j,1}; 
    end
    r4avresultsmse2l{j,1}= r4avresultsmse2l{j,1}/sizem; 
end

for j=1:numnet; 
    for i=1:sizem; 
        r4avresultstog2l{j,1}=r4avresultstog2l{j,1}+iresultstog{i}{j,1}; 
    end
    r4avresultstog2l{j,1}= r4avresultstog2l{j,1}/sizem; 
end

for j=1:numnet; 
    for i=1:sizem; 
        r4avresultsdel2l{j,1}=r4avresultsdel2l{j,1}+iresultsdel{i}{j,1}; 
    end
    r4avresultsdel2l{j,1}= r4avresultsdel2l{j,1}/sizem; 
end

for j=1:numnet; 
    for i=1:sizem; 
        r4avresultsdiff2l{j,1}=r4avresultsdiff2l{j,1}+iresultsdel{i}{j,1}; 
    end
    r4avresultsdiff2l{j,1}= r4avresultsdiff2l{j,1}/sizem; 
end
save('r4avresultsr2l','r4avresultsr2l')
save('r4avresultsmse2l','r4avresultsmse2l')
save('r4avresultstog2l','r4avresultstog2l')
save('r4avresultsdel2l','r4avresultsdel2l')
save('r4avresultsdiff2l','r4avresultsdiff2l')