a=345;
n=[0.5,0.75,1];
d=0.106;%进出口管径
dc=n.*d;
Ac=pi.*dc.^2./4;
Lc=0.4;
D=0.372;
L=1.1;
L1=L./2;
L2=L-L1;
V1=pi.*D^2./4.*L1;
V2=pi.*D^2./4.*L2;
Lc1=Lc+0.6.*dc;
fh=(a./(2.*pi)).*sqrt((Ac./Lc1).*(1./V1+1./V2));%内插滤波管截止频率
