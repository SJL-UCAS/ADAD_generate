city={"hunan"}
%key phenological periods of Summer-harvest crops for DC/DD/CF (the number  of 8 days in a year)
startdate_s1=11;
enddate_s1=11;

%key phenological periods of Autumn-harvest crops for DC/DD/CF (the number  of 8 days in a year)
startdate_a=31;
enddate_a  =31;

%key phenological periods of Early rice for DC/DD/CF (the number  of 8 days in a year)
startdate_e1=25;
enddate_e1=25;


%DC
t1=0.83;%Summer-harvest crops
t4=0.36;%Autumn-harvest crops
t7=0.81;%ER
%DD
t2=0.81;
t5=0.25;
t8=0.69;
%CF
t3=0.73;
t6=0.18;
t9=0.16;

base=7;
length=15;
result2=zeros(length,length);
rastersize=0.025;


filename1='F:\01PHD_DATA\DATA\hunan.xlsx';
ref = xlsread(filename1,z,'B2:D16'); 
num=15;
sizedata=imread(fullfile('F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_2006001.tif'));
[m,n]=size(sizedata);
[a,R3]=geotiffread(fullfile('F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_2006001.tif'));
info=geotiffinfo(fullfile('F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_2006001.tif'));



mask1=zeros(m,n,num);
for c=1:17
    mask1(:,:,c)=imread(['F:\01PHD_DATA\DATA\intensity\intensity2-zhang\utm50\',num2str(city{z}),'\','cropIntensity',num2str(c+2005),'.tif']);
end
mask2=mask1;
mask1(~(mask1 == 1 | mask1 == 2)) = NaN;
mask1(mask1 == 1 | mask1 == 2) = 0;
mask_single=mask1;



mask2(mask2 ~= 2) = NaN;
mask2(mask2 == 2) = 0;
mask_double=mask2;



%ER coverage
mask_rice=zeros(m,n,num);
for c=1:15
    mask_rice(:,:,c)=imread(['F:\01PHD_DATA\DATA\crop\三大作物物候数据集\LR&ER\utm50\',num2str(city{z}),'\','CHN_Rice(LR)_HE_',num2str(c+2005),'.tif']);
end
mask_rice(:,:,16)=mask_rice(:,:,15);
mask_rice(:,:,17)=mask_rice(:,:,15);

mask_rice(mask_rice>500)=nan;
mask_rice(mask_rice>0)=0;
mask_ERLR=mask_rice;


%Summer harvest
index = (mask_double == 0) & (mask_ERLR == 0);
mask_summer=mask_double;
mask_summer(index) = NaN;

%Autumn harvest
mask_autumn2=(mask_single==0)|(mask_ERLR==0);
mask_autumn=double(mask_autumn2);
mask_autumn(mask_autumn==0)=nan;
mask_autumn(mask_autumn==1)=0;



startdate1=startdate_s1;
enddate1=enddate_s1;
data2_s=zeros(m,n,num);
for l=2006:2022
    data_s=zeros(m,n,enddate1-startdate1+1);
    for b=startdate1:enddate1
        %path=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%02d'),'.tif'];
        filePath1=fullfile(['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%03d'),'.tif']);
        data_s(:,:,b-startdate1+1)=importdata(filePath1);
        %disp(filePath)
    end
    data1_s=mean(data_s,3);
    data1_s(data1_s<0)=nan;
    data1_s(data1_s>10)=nan;
    data2_s(:,:,l-2005)=data1_s;
end

data2_s=data2_s+mask_summer;
data3_s=data2_s./data2_s(:,:,base(z));%除以基准年
B_s = data3_s;
B_s(B_s>t1(z))=99;
%B_s(B_s<=t2(z))=nan;
B_s(B_s<=t1(z))=1;
for length=1:17
    outname1=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\01_drought_area\droughtArea\Summer_dc_',num2str(city{z}),'_',num2str(length+2005),'.tif'];
    geotiffwrite(outname1,int8(B_s(:,:,length)),R3,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
    %disp(1);
end

startdate2=startdate_s1;
enddate2=enddate_s1;
data2_s2=zeros(m,n,num);
for l=2006:2022
    data_s2=zeros(m,n,enddate2-startdate2+1);
    for b=startdate2:enddate2
        %path=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%02d'),'.tif'];
        filePath1=fullfile(['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%03d'),'.tif']);
        data_s2(:,:,b-startdate2+1)=importdata(filePath1);
        %disp(filePath)
    end
    data1_s2=mean(data_s2,3);
    data1_s2(data1_s2<0)=nan;
    data1_s2(data1_s2>10)=nan;
    data2_s2(:,:,l-2005)=data1_s2;
end
%受灾面积输出
data2_s2=data2_s2+mask_summer;
data3_s2=data2_s2./data2_s2(:,:,base(z));%除以基准年
B_s2 = data3_s2;
B_s2(B_s2>t2(z))=99;
%B_s(B_s<=t2(z))=nan;
B_s2(B_s2<=t2(z))=2;
for length=1:17
    outname1=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\01_drought_area\droughtArea\Summer_dd_',num2str(city{z}),'_',num2str(length+2005),'.tif'];
    geotiffwrite(outname1,int8(B_s2(:,:,length)),R3,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
    %disp(1);
end


startdate3=startdate_s1;
enddate3=enddate_s1;
data2_s3=zeros(m,n,num);
for l=2006:2022
    data_s3=zeros(m,n,enddate3-startdate3+1);
    for b=startdate3:enddate3
        %path=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%02d'),'.tif'];
        filePath1=fullfile(['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%03d'),'.tif']);
        data_s3(:,:,b-startdate3+1)=importdata(filePath1);
        %disp(filePath)
    end
    data1_s3=mean(data_s3,3);
    data1_s3(data1_s3<0)=nan;
    data1_s3(data1_s3>10)=nan;
    data2_s3(:,:,l-2005)=data1_s3;
end

%受灾面积输出
data2_s3=data2_s3+mask_summer;
data3_s3=data2_s3./data2_s3(:,:,base(z));%除以基准年
B_s3 = data3_s3;
B_s3(B_s3>t3(z))=99;
%B_s(B_s<=t2(z))=nan;
B_s3(B_s3<=t3(z))=3;
for length=1:17
    outname1=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\01_drought_area\droughtArea\Summer_cf_',num2str(city{z}),'_',num2str(length+2005),'.tif'];
    geotiffwrite(outname1,int8(B_s3(:,:,length)),R3,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
    %disp(1);
end




%遍历秋收作物生育期（24.33,六月下到九月初）
startdate6=startdate_a;
enddate6=enddate_a;
data2_a=zeros(m,n,num);
for l=2006:2022
    data_a=zeros(m,n,enddate6-startdate6+1);
    for b=startdate6:enddate6
        %path=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%02d'),'.tif'];
        filePath2=fullfile(['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%03d'),'.tif']);
        data_a(:,:,b-startdate6+1)=importdata(filePath2);
        %disp(filePath)
    end
    data1_a=mean(data_a,3);
    data1_a(data1_a<0)=nan;
    data1_a(data1_a>10)=nan;
    data2_a(:,:,l-2005)=data1_a;
end
%受灾面积输出
data2_a=data2_a+mask_autumn;
data3_a=data2_a./data2_a(:,:,base(z));%除以基准年
B_a = data3_a;
B_a(B_a>t4(z))=99;
%B_s(B_s<=t2(z))=nan;
B_a(B_a<=t4(z))=1;
for length=1:17
    outname1=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\01_drought_area\droughtArea\Autumn_dc_',num2str(city{z}),'_',num2str(length+2005),'.tif'];
    geotiffwrite(outname1,int8(B_a(:,:,length)),R3,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
    %disp(1);
end


startdate4=startdate_a;
enddate4=enddate_a;
data2_a2=zeros(m,n,num);
for l=2006:2022
    data_a2=zeros(m,n,enddate4-startdate4+1);
    for b=startdate4:enddate4
        %path=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%02d'),'.tif'];
        filePath2=fullfile(['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%03d'),'.tif']);
        data_a2(:,:,b-startdate4+1)=importdata(filePath2);
        %disp(filePath)
    end
    data1_a2=mean(data_a2,3);
    data1_a2(data1_a2<0)=nan;
    data1_a2(data1_a2>10)=nan;
    data2_a2(:,:,l-2005)=data1_a2;
end

%受灾面积输出
data2_a2=data2_a2+mask_autumn;
data3_a2=data2_a2./data2_a2(:,:,base(z));%除以基准年
B_a2 = data3_a2;
B_a2(B_a2>t5(z))=99;
%B_s(B_s<=t2(z))=nan;
B_a2(B_a2<=t5(z))=2;
for length=1:17
    outname1=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\01_drought_area\droughtArea\Autumn_dd_',num2str(city{z}),'_',num2str(length+2005),'.tif'];
    geotiffwrite(outname1,int8(B_a2(:,:,length)),R3,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
    %disp(1);2
end




startdate5=startdate_a;
enddate5=enddate_a;
data2_a3=zeros(m,n,num);
for l=2006:2022
    data_a3=zeros(m,n,enddate5-startdate5+1);
    for b=startdate5:enddate5
        %path=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%02d'),'.tif'];
        filePath2=fullfile(['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%03d'),'.tif']);
        data_a3(:,:,b-startdate5+1)=importdata(filePath2);
        %disp(filePath)
    end
    data1_a3=mean(data_a3,3);
    data1_a3(data1_a3<0)=nan;
    data1_a3(data1_a3>10)=nan;
    data2_a3(:,:,l-2005)=data1_a3;
end

%受灾面积输出
data2_a3=data2_a3+mask_autumn;
data3_a3=data2_a3./data2_a3(:,:,base(z));%除以基准年
B_a3 = data3_a3;
B_a3(B_a3>t6(z))=99;
%B_s(B_s<=t2(z))=nan;
B_a3(B_a3<=t6(z))=3;
for length=1:17
    outname1=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\01_drought_area\droughtArea\Autumn_cf_',num2str(city{z}),'_',num2str(length+2005),'.tif'];
    geotiffwrite(outname1,int8(B_a3(:,:,length)),R3,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
    %disp(1);2
end




%遍历早稻作物生育期（24.33,六月下到九月初）
startdate7=startdate_e1;
enddate7=enddate_e1;
data2_e=zeros(m,n,num);
for l=2006:2022
    data_e=zeros(m,n,enddate7-startdate7+1);
    for b=startdate7:enddate7
        %path=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%02d'),'.tif'];
        filePath2=fullfile(['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%03d'),'.tif']);
        data_e(:,:,b-startdate7+1)=importdata(filePath2);
        %disp(filePath)
    end
    data1_e=mean(data_e,3);
    data1_e(data1_e<0)=nan;
    data1_e(data1_e>10)=nan;
    data2_e(:,:,l-2005)=data1_e;
end
%受灾面积输出
data2_e=data2_e+mask_ERLR;
data3_e=data2_e./data2_e(:,:,base(z));%除以基准年
B_e = data3_e;
B_e(B_e>t7(z-3))=99;
%B_s(B_s<=t2(z))=nan;
B_e(B_e<=t7(z-3))=1;
for length=1:17
    outname1=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\01_drought_area\droughtArea\ER_dc_',num2str(city{z}),'_',num2str(length+2005),'.tif'];
    geotiffwrite(outname1,int8(B_e(:,:,length)),R3,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
    %disp(1);2
end


startdate8=startdate_e1;
enddate8=enddate_e1;
data2_e2=zeros(m,n,num);
for l=2006:2022
    data_e2=zeros(m,n,enddate8-startdate8+1);
    for b=startdate8:enddate8
        %path=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%02d'),'.tif'];
        filePath2=fullfile(['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%03d'),'.tif']);
        data_e2(:,:,b-startdate8+1)=importdata(filePath2);
        %disp(filePath)
    end
    data1_e2=mean(data_e2,3);
    data1_e2(data1_e2<0)=nan;
    data1_e2(data1_e2>10)=nan;
    data2_e2(:,:,l-2005)=data1_e2;
end
%受灾面积输出
data2_e2=data2_e2+mask_ERLR;
data3_e2=data2_e2./data2_e2(:,:,base(z));%除以基准年
B_e2 = data3_e2;
B_e2(B_e2>t8(z-3))=99;
%B_s(B_s<=t2(z))=nan;
B_e2(B_e2<=t8(z-3))=2;
for length=1:17
    outname1=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\01_drought_area\droughtArea\ER_dd_',num2str(city{z}),'_',num2str(length+2005),'.tif'];
    geotiffwrite(outname1,int8(B_e2(:,:,length)),R3,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
    %disp(1);2
end


startdate9=startdate_e1;
enddate9=enddate_e1;
data2_e3=zeros(m,n,num);
for l=2006:2022
    data_e3=zeros(m,n,enddate9-startdate9+1);
    for b=startdate9:enddate9
        %path=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%02d'),'.tif'];
        filePath2=fullfile(['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%03d'),'.tif']);
        data_e3(:,:,b-startdate9+1)=importdata(filePath2);
        %disp(filePath)
    end
    data1_e3=mean(data_e3,3);
    data1_e3(data1_e3<0)=nan;
    data1_e3(data1_e3>10)=nan;
    data2_e3(:,:,l-2005)=data1_e3;
end
%受灾面积输出
data2_e3=data2_e3+mask_ERLR;
data3_e3=data2_e3./data2_e3(:,:,base(z));%除以基准年
B_e3 = data3_e3;
B_e3(B_e3>t9(z-3))=99;
%B_s(B_s<=t2(z))=nan;
B_e3(B_e3<=t9(z-3))=3;
for length=1:17
    outname1=['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\01_drought_area\droughtArea\ER_cf_',num2str(city{z}),'_',num2str(length+2005),'.tif'];
    geotiffwrite(outname1,int8(B_e3(:,:,length)),R3,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
    %disp(1);2
end


