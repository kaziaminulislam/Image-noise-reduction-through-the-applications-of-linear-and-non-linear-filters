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

mean1=0;   
g=blur_img;

gstd=abs(g*0.005); 
nse= mean1 + gstd.*randn(size(g));
out_noise=g+nse;
figure();imshow(out_noise,[]);

G2=fft2(out_noise);

%weiner filtering
H=F_krnl;
G=F_blur;


H2=H.^2;
k1=.1;

Hhcls=((conj(H)).*G2)./(H2+k1);
hcls2=abs(ifft2(Hhcls));

%figure();imshow(hcls2,[]);


gn2=(hcls2);
gn3=zeros(174,182);
gn3(1:174,1:14)=gn2(1:174,169:182);
gn3(1:174,15:182)=gn2(1:174,1:168);

figure();imshow(gn3,[]);title('Weiner filtered image')


[peaksnr, snr] = psnr(I,gn3)

Idiff1=double(I)-double(out_noise);
idiff2=double(I)-double(gn3);
mean1=mean2(Idiff1.*Idiff1);
mean2=mean2(idiff2.*idiff2);
isnr=10*log(mean1/mean2)/log(10)

