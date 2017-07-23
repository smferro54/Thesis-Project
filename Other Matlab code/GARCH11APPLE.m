clc
clear
%GARCH(1,1) for APPLE
%Load series
[data]=xlsread('C:\Users\Sergio\Tesis\baseAPPLE.xlsx');
close=data(:,5);
dates=x2mdate(data(:,1));
%Compute logarithmic returns
returns=tick2ret(close,dates);
%Substract mean to get a zero centered distribution
% mu=mean(returns);
% adjreturns=zeros(length(returns),1);
% for i=1:length(returns)
% adjreturns(i,1)=returns(i,1)-mu;
% end
%Compute volatility as the absolute value of returns
vol=abs(returns);
%Volatility estimation using a GARCH(1,1)
f=@(X)GARCH11(X(1),X(2),X(3),X(4),X(5),returns);
v0=abs(returns(1));
Xo=[0.3 0.3 0.4 v0 mean(returns)];
A=[1 1 0 0 0];
options=optimset('Algorithm','interior-point');
[X]=fmincon(f,Xo,A,1,[],[],zeros(1,3),[],[],options);
% [X]=fminsearch(f,Xo);

%Model results
alpha=X(1);
beta=X(2);
omega=X(3);
v0=X(4);
mu=X(5);
varhat=zeros(length(returns),1);
er=zeros(length(returns),1);
for i=1:length(returns)
    if i==1
        varhat(i)=v0;
    else
        varhat(i)=omega+alpha*er(i-1)+beta*varhat(i-1);
        er(i)=(returns(i)-mu)^2;
    end
end
%Graphics
volhat=sqrt(varhat);
dates=dates(2:end,1);
GARCH11AAPL=figure;
plot(dates,vol,dates,volhat);
% title('GARCH(1,1) APPLE')
% print(GARCH11AAPL,'-dbmp','GARCH11AAPL.bmp')
% [coeff,~,~,~,Sigmas]=garchfit(adjreturns);
[coeff,~,~,~,Sigmas]=garchfit(returns);
% plot(dates,vol,dates,Sigmas)