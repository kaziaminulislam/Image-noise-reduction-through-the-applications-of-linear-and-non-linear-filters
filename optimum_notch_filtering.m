clear all;
close all;
I=imread('SKY.PGM');

I=im2double(I);
figure();imshow(I);
[M, N]=size(I);
F=fft2(double(I));
figure;imshow(log(1+abs(fftshift(F))),[]); title('Frequency Domain Amplitude Spectrum');
figure();imshow(angle(fftshift(F)),[]); title('Frequency Domain Phase Spectrum ');

B2=double(I);

A=1;
u=25;
v=35;
bx=29;
by=37;

for i=1:M,
  for j=1:N,
      
 
      p2(i,j)=(A*sin((2*pi*(u./M)*(i+bx))+(2*pi*(v/N)*(j+by))));
      
  end
end
g=p2+double(I);
G=fft2(g);

figure();imshow((g));
figure;imshow(log(1+abs(fftshift(G))),[]);


%notch
[p,q]=size(I);
M=p;
N=q;

x=0:(p-1);
y=0:(q-1);
xin=find(x>p/2);
x(xin)=x(xin)-p;
yin=find(y>q/2);
y(yin)=y(yin)-q;
[v,u]=meshgrid(y,x);

%notch filtering
order = 2;
centers = [62 58];
centers2 = [121 117];%centers of the highpass filters.

for i = 1: p
   for j = 1:q
        D0(i,j)=sqrt(((u(i,j)-M/2).^2)+(((v(i,j)-N/2).^2)));
        Dk(i,j)=sqrt(((u(i,j)-M/2-centers(1)).^2)+(((v(i,j)-N/2-centers(1)).^2)));
        Dkm(i,j)=sqrt(((u(i,j)-M/2+centers2(1)).^2)+(((v(i,j)-M/2+centers2(1)).^2)));


    end
end

Hnr=1./((1+((D0./Dk).^(2*order))).*(1+((D0./Dkm).^(2*order))));
Hnp=Hnr;
%figure();imshow(log(1+abs(fftshift(Hnr))),[]);

I_noise_FT=fft2(g);
I_nfil=(Hnp).*I_noise_FT;
n_xy=real(ifft2(double(I_nfil))); 

figure();imshow(n_xy,[]);
figure();figure;imshow(log(1+abs(fftshift(fft2(n_xy)))),[])

%weights

%{
I=input image
B=noiseyimage
np=filter for corresponding image
%}

I=I;
B=g;
np=n_xy;
blockSize=2;
[numRow, numCol] = size(I);


numRow_flr1=floor(numRow/(blockSize*blockSize));
numCol_flr1=floor(numCol/(blockSize*blockSize));
numRow_flr=numRow_flr1*blockSize;
numCol_flr=numCol_flr1*blockSize;

I_resize=I(1:(numRow_flr*blockSize),1:(numCol_flr*blockSize));
B_resize=B(1:(numRow_flr*blockSize),1:(numCol_flr*blockSize));
np_resize=np(1:(numRow_flr*blockSize),1:(numCol_flr*blockSize));

a=blockSize*ones(1,numRow_flr);
b=blockSize*ones(1,numCol_flr);


B_blckImgsize=mat2cell(B_resize,a,b);
np_blckImgsize=mat2cell(np_resize,a,b);
clear w_b;
for i=1:1:numRow_flr
    for j=1:1:numCol_flr
        s_g=0;
        s_n=0;
        gn=0;
        sum2=0;
      
       
        s_g=double(reshape(cell2mat(B_blckImgsize(i,j)),blockSize*blockSize,1));
        s_n=double(reshape(cell2mat(np_blckImgsize(i,j)),blockSize*blockSize,1));
        gn=double(double(s_g).*s_n);
        np2=double(s_n.*s_n);
        
        g1=double(mean(s_g));
        ns=double(mean(s_n));
        ns2=double(mean(np2));
        gns=double(mean(gn));
        w=double(gns-(g1*ns))/(ns2-(ns^2));
     
        sum2(1:blockSize,1:blockSize)=w;	
        w_b(i,j)=mat2cell(sum2,blockSize,blockSize);
    end
end

w2=cell2mat(w_b);

I2=double((B_resize)-(w2.*np_resize));
I2=I2;
figure();imshow(I2,[]);title('optium notch filtered image')
[m,n]=size(I2);
I3=I(1:m,1:n);
g=g(1:m,1:n);
[peaksnr, snr] = psnr(I3, I2)

Idiff1=I3-g;
idiff2=I3-I2;
mean1=mean2(Idiff1.*Idiff1);
mean2=mean2(idiff2.*idiff2);
isnr=10*log(mean1/mean2)/log(10)