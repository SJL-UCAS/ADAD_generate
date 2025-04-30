
city={"hunan"};
rastersize=0.025;
base=7;

z=1;
disp(city{z})

filename1='F:\01PHD_DATA\DATA\hunan.xlsx';
ref = xlsread(filename1,a,'B2:D16'); 
num=15;

sizedata=imread(fullfile('F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_2006001.tif'));
[m,n]=size(sizedata);

mask_intensity=zeros(m,n,num);
for c=1:num
    mask_intensity(:,:,c)=imread(['F:\01PHD_DATA\DATA\intensity\intensity2-zhang\utm50\',num2str(city{z}),'\','cropIntensity',num2str(c+2005),'.tif']);
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
for c=1:num
    mask_rice(:,:,c)=imread(['F:\01PHD_DATA\DATA\crop\LR&ER\utm50\',num2str(city{z}),'\','CHN_Rice(LR)_HE_',num2str(c+2005),'.tif']);
    %g=mask_rice(:,:,c);
    %disp(1);
end

mask_rice(mask_rice>500)=nan;
mask_rice(mask_rice>0)=1;
mask_ERLR=reshape(mask_rice, [m*n, num]);


%Summer harvest
index = (mask_double == 0) & (mask_ERLR == 0);
mask_summer=mask_double;
mask_summer(index) = NaN;

%Autumn harvest
mask_autumn=(mask_single==0)|(mask_ERLR==0);
mask_autumn2=double(mask_autumn);
mask_autumn2(mask_autumn2==0)=nan;
mask_autumn2(mask_autumn2==1)=0;

s=1;
%all phenological periods of Autumn-harvest crops for DC/DD/CF (the number  of 8 days in a year)
for startdate2=18:29
    for enddate2=startdate2:29
        data2_a=zeros(m,n,num);
        for l=2006:2006+num-1
            data_a=zeros(m,n,enddate2-startdate2+1);
            for b=startdate2:enddate2
                filePath2=fullfile(['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%02d'),'.tif']);
                data_a(:,:,b-startdate2+1)=importdata(filePath2);
                %disp(filePath)
            end
            data1_a=mean(data_a,3);
            data1_a(data1_a<=0)=nan;
            %data1_a(data1_a>10)=nan;
            data2_a(:,:,l-2005)=data1_a;
        end

        data3_a=data2_a./data2_a(:,:,base);
        A_a = reshape(data3_a, [m*n, num]);
        B_a=A_a+mask_autumn2;
        B_a=B_a(any(~isnan(B_a),2),:);

        export=zeros(2200000,15);

        %all phenological periods of Summer-harvest crops for DC/DD/CF (the number  of 8 days in a year)（1：9，33-124）
        for startdate1=1:9
            for enddate1=startdate1:9
                data2_s=zeros(m,n,num);
                for l=2006:2006+num-1
                    data_s=zeros(m,n,enddate1-startdate1+1);
                    for b=startdate1:enddate1                    
                        filePath1=fullfile(['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%02d'),'.tif']);
                        data_s(:,:,b-startdate1+1)=importdata(filePath1);
                    end
                    data1_s=mean(data_s,3);
                    data1_s(data1_s<=0)=nan;
                    %data1_s(data1_s>10)=nan;
                    data2_s(:,:,l-2005)=data1_s;
                end
                data3_s=data2_s./data2_s(:,:,base);
                A_s = reshape(data3_s, [m*n, num]);
                B_s=A_s+mask_summer;
                B_s=B_s(any(~isnan(B_s),2),:);                


                %%all phenological periods of ER for DC/DD/CF (the number  of 8 days in a year)
                for startdate3=12:18
                    for enddate3=startdate3:18
                        data2_e=zeros(m,n,num);
                        for l=2006:2006+num-1
                            data_e=zeros(m,n,enddate3-startdate1+3);
                            for b=startdate3:enddate3                            
                                filePath3=fullfile(['F:\01PHD_DATA\DATA\LAI\zhang\LAI_8d\LAI_DOY_UTM\',num2str(city{z}),'\LAI_',num2str(l),num2str(8*(b-1)+1,'%02d'),'.tif']);
                                data_e(:,:,b-startdate1+1)=importdata(filePath3);
                            end
                            data1_e=mean(data_e,3);
                            data1_e(data1_e<=0)=nan;
                            %data1_e(data1_e>10)=nan;
                            data2_e(:,:,l-2005)=data1_e;
                        end    
                        data3_e=data2_e./data2_e(:,:,base);
                        A_e = reshape(data3_e, [m*n, num]);
                        B_e=A_e+mask_ERLR;
                        B_e=B_e(any(~isnan(B_e),2),:);%
                        
                        for t1=0.9:0.1:0.9
                            num1=sum(B_s<=t1);                            
                            for t2=0.75:0.1:0.75
                                num2=sum(B_a<=t2);                               
                                for t3=0.5:0.1:0.5
                                    num3=sum(B_e<=t3);
                                    sumnum=rastersize*(num1+num2+num3);
                                    dc=sumnum+ref(base,1);
                                    dd=sumnum+ref(base,2);
                                    cf=sumnum+ref(base,3);                               
                                    rmse1=round(sqrt(mean((dc'-ref(:,1)).^2)),0);
                                    r1=corrcoef(ref(:,1),dc');
                                    %rmse2 = rmse(sumnum',ref(:,2));
                                    rmse2=round(sqrt(mean((dd'-ref(:,2)).^2)),0);
                                    r2=corrcoef(ref(:,2),dd');
                                    %rmse3 = rmse(sumnum',ref(:,1));
                                    rmse3=round(sqrt(mean((cf'-ref(:,3)).^2)),0);
                                    r3=corrcoef(ref(:,3),cf');

                                    %export(s,:)= [startdate1,enddate1,startdate2,enddate2,t1,t2,r1(1,2),rmse1,r2(1,2),rmse2,r3(1,2),rmse3];
                                    export(s,:)=[startdate1,enddate1,startdate2,enddate2,startdate3,enddate3,t1,t2,t3,r1(1,2),rmse1,r2(1,2),rmse2,r3(1,2),rmse3];
                                    %disp([startdate2,enddate2,startdate,enddate,startdate3,enddate3,t2,t1,t3,r1(1,2),rmse1,r2(1,2),rmse2,r3(1,2),rmse3])
                                    s=s+1;
                                end

                            end

                        end
                         disp([startdate1,enddate1,startdate2,enddate2,startdate3,enddate3,t1,t2,t3]);
                    end
                end

            end
        end
        xlswrite(['/home/Yangtze/hunan/output2/HN7',num2str(startdate2),'_',num2str(enddate2),'_1.xlsx'],export(1:1000000,:));
        xlswrite(['/home/Yangtze/hunan/output2/HN7',num2str(startdate2),'_',num2str(enddate2),'_2.xlsx'],export(1000001:2000000,:));
        xlswrite(['/home/Yangtze/hunan/output2/HN7',num2str(startdate2),'_',num2str(enddate2),'_3.xlsx'],export(2000001:2181200,:));
    end
end

