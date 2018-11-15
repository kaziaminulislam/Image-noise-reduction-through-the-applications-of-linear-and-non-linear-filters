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

[p_cons,q]=size(I);
x=1:(p_cons);
y=1:(q);
xn1=find(x>p_cons/2);
x(xn1)=x(xn1)-p_cons;
yn1=find(y>q/2);
y(yn1)=y(yn1)-q;
[v,u]=meshgrid(y,x);


for N = 1: p_cons
   for M = 1:q
       H(N,M)=(T/(pi*(u(N,M)*a+v(N,M)*b))).*(sin(pi*(u(N,M)*a+v(N,M)*b)))...
           *exp(-(1j*pi*(u(N,M)*a+v(N,M)*b)));
       


    end
end

%F=fft2(I);
H(isnan(H)) =0;
G=F.*(H);
g=real(ifft2(double(G)));
figure();imshow(uint8(g));

%gaussian noise

mean1=0;   % value ofmean


gd=abs(g*0.0005); %
nse= mean1 + gd.*randn(size(g));
out_noise=g+nse;
figure();imshow(uint8(out_noise));
G2=fft2(out_noise);

I_nfil=(H).*G2;

%figure();imshow(log(1+abs(fftshift(I_nfil))),[]);
n_xy=real(ifft2(double(I_nfil))); 


H2=abs(H).^2; 


%constrained linear filtering

[M,N]=size(I); 
MN=M*N; 
tamp_data=[1:M]'*ones(1,N)+ones(M,1)*[1:N];
H2=H.^2;
%gamma=.000009;
gmm=.000000009;

p_cons=[0 -1 0; -1 4 -1; 0 -1 0];
f_cons=fft2(p_cons.*tamp_data(1:size(p_cons,1),1:size(p_cons,2)),174,182);
Hcons=conj(H).*G./(H2+gmm*abs(f_cons).^2);
hcons=abs(ifft2(Hcons));

%figure();imshow(uint8(hcons));

gn2=uint8(hcons);
gn3=zeros(174,182);
gn3(1:174,1:14)=gn2(1:174,169:182);
gn3(1:174,15:182)=gn2(1:174,1:168);

figure();imshow(uint8(gn3));title('CLSF filtered image')


%figure();imshow(gn3,[]);
%iteraion
Rr=abs(G-H.*Hcons);
r=real(ifft2(Rr));
r2=(sum(sum(abs(r).^2))-r(1,1)^2)/MN;


%iteration2

mean_n_xy=mean2(n_xy);
std_n=std2(n_xy);
n2=M*N*((mean_n_xy.^2)+(std_n.^2))


Gn=fft2(gn3);
R=G2-(H.*Gn);
r=abs(ifft2(R));

r2=std2(r.^2)

[peaksnr, snr] = psnr(I,uint8(gn3))

Idiff1=double(I)-double(out_noise);
idiff2=double(I)-double(uint8(gn3));
mean1=mean2(Idiff1.*Idiff1);
mean2=mean2(idiff2.*idiff2);
isnr=10*log(mean1/mean2)/log(10)

