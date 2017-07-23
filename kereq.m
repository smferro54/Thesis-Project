function CV = kereq(y,h)

n=length(y);
t=(1:n)';
%función de kernel gaussiano                                          
kerg=@(z)exp(-0.5*(z^2))/sqrt(2*pi);
z=zeros(n,1);w=zeros(n,1);yhat=zeros(n,1);
for i=1:n
    for j=1:n
        if j==i 
            z(j)=0;
        else
            z(j)=kerg((t(j)-t(i))/h);
        end
    end
    for k=1:n
        w(k)=z(k)/sum(z);
    end
    yhat(i)=sum(w.*y);
end
CV=(1/n)*sum((y-yhat).^2);
end
