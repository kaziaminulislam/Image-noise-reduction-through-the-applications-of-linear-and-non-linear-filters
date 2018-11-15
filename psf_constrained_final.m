close all
clear all
I=im2double(imread('SKY.PGM'));

[M,N]=size(I);
figure();imshow(I,[]);title('Original Image');

%Kernel

pdfsize = 16;
pkrnl = zeros(pdfsize);

mid = pdfsize/2;
[U, V] = meshgrid(1:pdfsize);
pr=sqrt((U-mid).^2 + (V-mid).^2);
pkrnl = (1./(pi.*pr.^2));
pkrnl(find(pkrnl == inf)) = 1;

figure, imagesc(pkrnl);colormap('gray');


krnl_img = zeros(M,N);
krnl_img(1:pdfsize, 1:pdfsize) = pkrnl;
F=fft2(double(I));
F_krnl = fft2(krnl_img);


F_krnl(find(F_krnl == 0)) = 1e-6;

F_blur = F.*F_krnl;

blur_img = double(ifft2(F_blur));

figure, imshow(blur_img,[]);title('PSF blurred')



%gaussian noise

mean1=0;   % value ofmean
g=blur_img;

gstd=abs(g*0.02); % standard deviation 5%
nse= mean1 + gstd.*randn(size(g));
out_noise=g+nse;
figure();imshow(out_noise,[]);

G2=fft2(out_noise);

%constrained linear filtering

H=F_krnl;
G=F_blur;
[M,N]=size(I); 
MN=M*N; 
tmp=[1:M]'*ones(1,N)+ones(M,1)*[1:N];
H2=H.^2;
gamma=.000000009;
p_cons=[0 -1 0; -1 4 -1; 0 -1 0];
consP=fft2(p_cons.*tmp(1:size(p_cons,1),1:size(p_cons,2)),174,182);
Hcons=(H).*G2./(H2+gamma*abs(consP).^2);
hcons=abs(ifft2(Hcons));

figure();imshow(hcons,[]);title('CLSF filtered image')



gn3=hcons;
Rr=abs(G-H.*Hcons);
r=real(ifft2(Rr));
r2=(sum(sum(abs(r).^2))-r(1,1)^2)/MN;


%iteration2
n_xy=out_noise;

mean_n_xy=mean2(n_xy);
std_n=std2(n_xy);
n2=M*N*((mean_n_xy.^2)+(std_n.^2))


Gn=fft2(gn3);
R=G2-(H.*Gn);
r=abs(ifft2(R));

r2=std2(r.^2)

[peaksnr, snr] = psnr(I,gn3)

Idiff1=double(I)-double(out_noise);
idiff2=double(I)-double(gn3);
mean1=mean2(Idiff1.*Idiff1);
mean2=mean2(idiff2.*idiff2);
isnr=10*log(mean1/mean2)/log(10)
