%Simulated paths - GARCH models, Francq and Zakoian, p. 21.

%Simulation of size 500 of the ARCH(1) process with omega=1, alpha=0.5 and
%eta~N(0,1)
omega=1;
alpha=0.5;
n=500;
e=zeros(n,1);
var=zeros(n,1);
for i=1:n
    if i==1
        var(i)=1;
    else
        var(i)=omega+alpha*(e(i-1)^2);
    end
    eta=random('Normal',0,1);
    e(i)=sqrt(var(i))*eta;
end
ARCH1=figure;
plot(e)
title('ARCH(1)')
print(ARCH1,'-dbmp','ARCH1_alpha0_5.bmp')

%Simulation of size 500 of the ARCH(1) process with omega=1, alpha=0.95 and
%eta~N(0,1)
omega=1;
alpha=0.95;
n=500;
e=zeros(n,1);
var=zeros(n,1);
for i=1:n
    if i==1
        var(i)=1;
    else
        var(i)=omega+alpha*(e(i-1)^2);
    end
    eta=random('Normal',0,1);
    e(i)=sqrt(var(i))*eta;
end
ARCH1=figure;
plot(e)
title('ARCH(1)')
print(ARCH1,'-dbmp','ARCH1_alpha0_95.bmp')

%Simulation of size 500 of the ARCH(1) process with omega=1, alpha=1.1 and
%eta~N(0,1)
omega=1;
alpha=1.1;
n=500;
e=zeros(n,1);
var=zeros(n,1);
for i=1:n
    if i==1
        var(i)=1;
    else
        var(i)=omega+alpha*(e(i-1)^2);
    end
    eta=random('Normal',0,1);
    e(i)=sqrt(var(i))*eta;
end
ARCH1=figure;
plot(e)
title('ARCH(1)')
print(ARCH1,'-dbmp','ARCH1_alpha1_1.bmp')

%Simulation of size 200 of the ARCH(1) process with omega=1, alpha=3 and
%eta~N(0,1)
omega=1;
alpha=3;
n=200;
e=zeros(n,1);
var=zeros(n,1);
for i=1:n
    if i==1
        var(i)=1;
    else
        var(i)=omega+alpha*(e(i-1)^2);
    end
    eta=random('Normal',0,1);
    e(i)=sqrt(var(i))*eta;
end
ARCH1=figure;
plot(e)
title('ARCH(1)')
print(ARCH1,'-dbmp','ARCH1_alpha3.bmp')

%Simulation of size 500 of the GARCH(1,1) process with omega=1, alpha=0.2 
%beta=0.7 and eta~N(0,1). In order to see how different values affect
%persistence and schock responde, two processes are generated from the same
%random data from e.
omega=1;
alpha=[0.2 0.7];
beta=[0.7 0.2];
n=500;
e=zeros(n,1);
e1=zeros(n,1);
var=zeros(n,1);
var1=zeros(n,1);
for i=1:n
    if i==1
        var(i)=1;
        var1(i)=1;
    else
        var(i)=omega+alpha(1)*(e(i-1)^2)+beta(1)*var(i-1);
        var1(i)=omega+alpha(2)*(e(i-1)^2)+beta(2)*var1(i-1);
    end
    eta=random('Normal',0,1);
    e(i)=sqrt(var(i))*eta;
    e1(i)=sqrt(var1(i))*eta;
end
GARCH1_1=figure;
plot(e)
title('GARCH(1,1)')
print(GARCH1_1,'-dbmp','GARCH1_1_a0_2_b0_7.bmp')
plot(e1)
title('GARCH(1,1)')
print(GARCH1_1,'-dbmp','GARCH1_1_a0_7_b0_2.bmp')
