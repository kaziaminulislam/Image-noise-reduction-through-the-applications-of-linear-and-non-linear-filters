clear all;
close all;
I=imread('SKY.PGM');

%I=im2double(I);
figure();imshow(I);
[M, N]=size(I);
F=fft2(double(I));

T=1;
a=0.1;
b=0.1;

[p,q]=size(I);
x=1:(p);
y=1:(q);
xin=find(x>p/2);
x(xin)=x(xin)-p;
yin=find(y>q/2);
y(yin)=y(yin)-q;
[v,u]=meshgrid(y,x);



for n = 1: p
   for m = 1:q
       H(n,m)=(T/(pi*(u(n,m)*a+v(n,m)*b))).*(sin(pi*(u(n,m)*a+v(n,m)*b)))...
           *exp(-(1j*pi*(u(n,m)*a+v(n,m)*b)));
       


    end
end

F=fft2(I);
H(isnan(H)) =0;
G=F.*(H);
g=real(ifft2(double(G)));
figure();imshow(uint8(g));

%gaussian noise

mean1=0;   % value ofmean


gstd=abs(g*0.05); % standard deviation 5%
nse= mean1 + gstd.*randn(size(g));
out_noise=g+nse;
figure();imshow(uint8(out_noise));
G2=fft2(out_noise);



I_nfil=(H).*G2;

%figure();imshow(log(1+abs(fftshift(I_nfil))),[]);

n_xy=real(ifft2(double(I_nfil))); 
mean_n_xy=mean(reshape(n_xy,p*q,1));
std_n=std2(n_xy);
n2=M*N*((mean_n_xy^2)+(std_n^2));

H2=abs(H).^2; 



[m,n]=size(I); % image sizes
mn=m*n; 
tmp=[1:m]'*ones(1,n)+ones(m,1)*[1:n];
H2=H.^2;
k1=.1;
%k1=n2;
Hhs=((conj(H)).*G2)./(H2+k1);
hhs2=abs(ifft2(Hhs));

%figure();imshow(uint8(hhs2));

gn2=uint8(hhs2);
gn3=zeros(174,182);
gn3(1:174,1:14)=gn2(1:174,169:182);
gn3(1:174,15:182)=gn2(1:174,1:168);

figure();imshow(uint8(gn3));title('Weiner filtered image')

%imshow(im2double(gn3),[])

Gn=fft2(gn3);
R=G2-(H.*Gn);
r=abs(ifft2(R));

r2=std2(r.^2);

[peaksnr, snr] = psnr(I, uint8(gn3))

Idiff1=I-uint8(out_noise);
idiff2=I-uint8(gn3);
mean1=mean2(Idiff1.*Idiff1);
mean2=mean2(idiff2.*idiff2);
isnr=10*log(mean1/mean2)/log(10)


