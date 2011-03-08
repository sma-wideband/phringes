function fx=plot_delay_core_test(x0,x2,y0,y2)
x=reshape([x0,x2].',1,[]);
y=reshape([y0,y2].',1,[]);
xx=x([1:2^15]+120);
yy=y([1:2^15]+120);
xx128=reshape(xx,128,[]);
yy128=reshape(yy,128,[]);
fx=fftshift(fxcorr(xx128,yy128));
ph=angle(fx);
subplot(2,1,1);
plot(angle(fx)*180/pi,'-o');
xlim([0, 128]);
set(gca,'xtick',[0:16:128]);
ylim([-180, 180]);
set(gca,'ytick',[-180:45:180]);
grid on;
subplot(2,1,2);
plot(abs(fx),'-o');
xlim([0, 128]);
set(gca,'xtick',[0:16:128]);
k=[33:97];
pp=polyfit(k-65,ph(k)',1);
delay=-pp(1)*128/pi;
delay16=round(delay*16);
delayi=floor(delay16/16);
delayf=mod(delay16,16);
delayr=delay-delay16/16;
fprintf(1, 'Phase slope fit = %f samples (%d+%d/16, %+.2f/16)\n', delay, delayi, delayf, delayr);
fprintf(1, 'Phase at center = %f degrees\n', ph(65)*180/pi);