clc;
close all;
clear all;
I1=imread('office1.jpg');
I2=imread('office000750.jpg');
i3=rgb2gray(I1);
i4=rgb2gray(I2);
i1=i3;
i2=i4;
%i1=i3(501:700,501:700);
%i2=i4(501:700,501:700);

[m,n]=size(i1);
ds=(i1-i2);
for i=1:m
    for j=1:n
        temp=abs(log(double(i2(i,j)+1))-log(double(i1(i,j)+1)));
        dl(i,j)=(temp);
    end
end


dlm = medfilt2(dl, [3 3]);

kernel = ones(11, 11) / (11*11); 

J = conv2(ds, kernel, 'same');
J1=(J);

h = fspecial('average',[11 11]);

J2=conv2(ds,h,'same');
J3=uint8(J2);
%froundtruth
ground_trth=imread('officegt000750.png');
grnd_normalized=double(ground_trth/256);

r_max=10;
%initialization
a_true_positive=zeros(r_max,1);
a_true_negative=zeros(r_max,1);
a_false_positive=zeros(r_max,1);
a_false_negative=zeros(r_max,1);

hit_rate=zeros(r_max,1);
miss_rate_alarms=zeros(r_max,1);
false_alarms_rate=zeros(r_max,1);
overall_error=zeros(r_max,1);
k=zeros(r_max,1);

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

%figure;imshow(i1);
%figure;imshow(i2);
%cdi2=fcmkmns2;
[m,n]=size(cdi2);
%{
cdi=kmeans(D_re,2);
cdi2=reshape(cdi,m,n);
imshow(cdi2,gray(2));
figure;imshow(i1);
%}

true_positive=0;
true_negative=0;
false_positive=0;
false_negative=0;
for i=1:1:m
    for j=1:1:n
        
        t2=cdi2(i,j);
        t1=grnd_normalized(i,j);
        
        if t1==1 && t2==2
            true_positive= true_positive+1;
        elseif t1==0 && t2==1
            true_negative=true_negative+1;
        elseif t1 == 0 && t2==2
            false_positive=false_positive+1;
        elseif t1==1 && t2==1
            false_negative=false_negative+1;
        else
           disp('!!!error!!');
        end
    
    end
end

a_true_positive(index)=true_positive;
a_true_negative(index)=true_negative;
a_false_positive(index)=false_positive;
a_false_negative(index)=false_negative;
hit_rate(index)=true_positive*100/(true_positive+false_negative);
miss_rate_alarms(index)=false_negative*100/(false_negative+true_positive);
false_alarms_rate(index)=false_positive*100/(false_positive+true_positive);
overall_error(index)=false_negative+false_positive;

%cohen calculation
Po=(true_positive+true_negative)/(true_positive+true_negative+false_positive+false_negative);
Aa=(true_positive+false_positive)*(true_positive+false_negative)/(true_positive+true_negative+false_positive+false_negative);
Bb=(true_negative+false_positive)*(true_negative+false_negative)/(true_positive+true_negative+false_positive+false_negative);
Pe=(Aa+Bb)/(true_positive+true_negative+false_positive+false_negative);

k(index)=(Po-Pe)/(1-Pe);

end

%plot(alpha3(1:11),a_false_positive(1:11));
figure();plot(alpha3(1:11),a_false_positive(1:11),alpha3(1:11),a_false_negative(1:11),alpha3(1:11),overall_error(1:11));
ylabel('performance evaluation');xlabel('alpha');
legend('false alarm','missed alarm','overall error');

figure();plot(alpha3(1:11),k(1:11));
ylabel('kappa index');xlabel('alpha');
