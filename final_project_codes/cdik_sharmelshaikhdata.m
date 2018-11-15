clc;
close all;
clear all;
I1=imread('SharmElSheik_1998.jpg');
I2=imread('SharmElSheik_2004.jpg');
i3=rgb2gray(I1);
i4=rgb2gray(I2);
B = imhistmatch(i3,i4);
i1=B;
i2=i4;
%i1=i3(1:800,1:800);
%i2=i4(1:800,1:800);

[m,n]=size(i1);
ds=abs(i1-i2);
for i=1:m
    for j=1:n
        temp=abs(log(double(i2(i,j)+1))-log(double(i1(i,j)+1)));
        dl(i,j)=uint8(temp);
    end
end

dlm = medfilt2(dl, [3 3]);

kernel = ones(11, 11) / (11*11); 

J = conv2(ds, kernel, 'same');
J1=uint8(J);

h = fspecial('average',[11 11]);

J2=conv2(ds,h,'same');
J3=uint8(J2);

r_max=10;
%initialization
%{
a_true_positive=zeros(r_max,1);
a_true_negative=zeros(r_max,1);
a_false_positive=zeros(r_max,1);
a_false_negative=zeros(r_max,1);

hit_rate=zeros(r_max,1);
miss_rate_alarms=zeros(r_max,1);
false_alarms_rate=zeros(r_max,1);
overall_error=zeros(r_max,1);
k=zeros(r_max,1);
%}
alpha3=zeros(11,1);
alpha3(1,1)=0;
for i=1:1:10
alpha2=0.1*i;
alpha3(i+1,1)=alpha2;
end

for index=1:1:11
alpha=alpha3(index,1);
D=(alpha*J1)+((1-alpha)*dlm);
D_re=reshape(D,m*n,1);
cdi=kmeans(D_re,2);
cdi2=reshape(cdi,m,n);
figure();imshow(cdi2,gray(2));
%floc = 'H:\final project2\output_pictures';
%saveas(gcf, fullfile(floc, num2str(alpha*10)), 'jpeg');
end