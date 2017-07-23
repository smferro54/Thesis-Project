function [L]=GARCH11(alpha,beta,omega,v0,mu,R)
varhat=zeros(length(R),1);
er=zeros(length(R),1);
for i=1:length(R)
    if i==1
        varhat(i)=v0;
    else
        varhat(i)=omega+alpha*er(i-1)+beta*varhat(i-1);
    end
    er(i)=((R(i)-mu)^2);
end
L=sum(log(sqrt(varhat)))+0.5*sum(er./varhat);
