function R=StratEvalTES(data,extremos,lastpos,Time,xlarge,Type)

%Para los TES, las estrategias son opuestas, pues quiero que bajen las
%tasas. As'i mismo, los retornos son diferentes. 

compra=0;
x1=0;
R=[];
if Type==1 %Patr'on de cabeza y hombros 
    for i=1:Time %Examino precio por precio hasta que se acabe la ventanta de tiempo en la que se cumpli'o el patr'on
        if lastpos+i<size(data,1)
            if compra==0 %Si no ha comprado nada y ve la oportunidad, que compre. 
                if data(lastpos+i)<=extremos(1,3)*(1-xlarge) && data(lastpos+i)<data(lastpos+i-1)
                    x1=data(lastpos+i);
                    compra=1;
                    level=0;
                end
            end
            if compra==1 %Voy a especificar los niveles que ha cruzado una vez se ha hecho la compra
                if data(lastpos+i)<=extremos(1,5)
                    level=1;%quiere decir que ya baj'o el hombro
                elseif data(lastpos+i)>=extremos(1,4)
                    level=2;%quiere decir que ya es menor al cuello
                end
            end
            if compra==1
                if data(lastpos+i)>=extremos(1,5)*(1+xlarge) && level==1 ...
                    || data(lastpos+i)>=extremos(1,4)*(1+xlarge) && level==2 ...
                    || data(lastpos+i)>=extremos(1,3)*(1+xlarge) ...
                    || i==Time %Aqu'i hago stop loss o vendo cuando se toque el m'inimo reciente o despues que se acabe el tiempo
                    x2=data(lastpos+i);
                    compra=0;
                    r1=(x2-x1)*100;
                    R=[R r1];
                end
            end     
        end
    end
    if x1==0
        r1=x1;
        R=[R r1];
    end
elseif Type==2 %Patr'on de cabeza y hombros invertido
    for i=1:Time %Examino precio por precio hasta que se acabe la ventanta de tiempo en la que se cumpli'o el patr'on
        if lastpos+i<size(data,1)    
            if compra==0 && data(lastpos+i)>=extremos(1,4)*(1+xlarge) %Primero quiero saber si el patr'on se va a convertir en reversi'on o en horizontal.
                rev=1;
            else
                rev=0;
            end
            if compra==0 %Si no ha comprado nada y ve la oportunidad, que compre. 
                if data(lastpos+i)>=extremos(1,3)*(1+xlarge) && rev==1 && data(lastpos+i)>=data(lastpos+i-1) %si es mayor a la cabeza, se respet'o el cuello y va para abajo    
                    compra=1;
                    x1=data(lastpos+i);
                    level=0;
                end
            end
            if compra==1 %Voy a especificar los niveles que ha cruzado una vez se ha hecho la compra
                if data(lastpos+i)<=extremos(1,5)
                    level=1;%quiere decir que ya baj'o del hombro
                elseif data(lastpos+i)<=extremos(1,3)
                    level=2;%quiere decir que ya baj'o de la cabeza
                end
            end
            if compra==1
                if data(lastpos+i)>=extremos(1,3)*(1+xlarge) && level==2 ...
                    || data(lastpos+i)>=extremos(1,5)*(1+xlarge) && level==1 ...
                    || data(lastpos+i)>=extremos(1,4)*(1+xlarge) ...
                    || i==Time %Aqu'i hago stop loss o vendo cuando se toque el m'inimo reciente o despues que se acabe el tiempo
                    x2=data(lastpos+i);
                    compra=0;
                    r1=(x2-x1)*100;
                    R=[R r1];
                end
            end    
        end
    end
    if x1==0
        r1=x1;
        R=[R r1];
    end
elseif Type==3 %Broadening tops
    R=[R 0];
elseif Type==4 %Broadening Bottoms
    R=[R 0];
elseif Type==5 %Triangle Tops
    for i=1:Time %Examino precio por precio hasta que se acabe la ventanta de tiempo en la que se cumpli'o el patr'on
        if lastpos+i<size(data,1)
            if compra==0 %Si no ha comprado nada y ve la oportunidad, que compre. 
                if data(lastpos+i)<=extremos(1,5)*(1-xlarge) && data(lastpos+i)<data(lastpos+i-1)
                    compra=1;
                    x1=data(lastpos+i);
                end
            end
            if compra==1
                if data(lastpos+i)>=extremos(1,5)*(1+xlarge) ...
                        || i==Time %Aqu'i hago stop loss o vendo cuando se toque el m'inimo reciente o despues que se acabe el tiempo
                    x2=data(lastpos+i);
                    compra=0;
                    r1=(x2-x1)*100;
                    R=[R r1];
                end
            end
        end
    end
    if x1==0
        r1=x1;
        R=[R r1];
    end
elseif Type==6 %Triangle Bottoms
   for i=1:Time %Examino precio por precio hasta que se acabe la ventanta de tiempo en la que se cumpli'o el patr'on
       if lastpos+i<size(data,1) 
           if compra==0 %Si no ha comprado nada y ve la oportunidad, que compre. 
                if data(lastpos+i)<=extremos(1,5)*(1-xlarge) && data(lastpos+i)<data(lastpos+i-1)
                    compra=1;
                    x1=data(lastpos+i);
                end
            end
            if compra==1
                if data(lastpos+i)>=extremos(1,5)*(1+xlarge) || i==Time %Aqu'i hago stop loss o vendo cuando se toque el m'inimo reciente o despues que se acabe el tiempo
                    x2=data(lastpos+i);
                    compra=0;
                    r1=(x2-x1)*100;
                    R=[R r1];
                end
            end     
       end
    end
    if x1==0
        r1=x1;
        R=[R r1];
    end
elseif Type==7 %Rectangle Tops
    for i=1:Time %Examino precio por precio hasta que se acabe la ventanta de tiempo en la que se cumpli'o el patr'on
        if lastpos+i<size(data,1)
            if compra==0 %Si no ha comprado nada y ve la oportunidad, que compre. 
                if data(lastpos+i)<=extremos(1,5)*(1-xlarge) && data(lastpos+i)<data(lastpos+i-1) %Si es menor al tope del rect'angulo y va bajando, compro.
                    compra=1;
                    x1=data(lastpos+i);
                    level=0;
                end
            end
            if compra==1
                if data(lastpos+i)<=extremos(1,4)*(1-xlarge)
                    level=1;
                end
            end
            if compra==1
                if data(lastpos+i)>=extremos(1,4)*(1+xlarge) && level==1 ...
                        || data(lastpos+i)>=extremos(1,5)*(1+xlarge) ...
                        || i==Time %Aqu'i hago stop loss o vendo cuando se toque el m'inimo reciente o despues que se acabe el tiempo
                    x2=data(lastpos+i);
                    compra=0;
                    r1=(x2-x1)*100;
                    R=[R r1];
                end
            end
        end    
    end
    if x1==0
        r1=x1;
        R=[R r1];
    end
elseif Type==8 %Rectangle Bottoms
    for i=1:Time %Examino precio por precio hasta que se acabe la ventanta de tiempo en la que se cumpli'o el patr'on
        if lastpos+i<size(data,1)
            if compra==0 %Si no ha comprado nada y ve la oportunidad, que compre. 
                if data(lastpos+i)<=extremos(1,4)*(1-xlarge) && data(lastpos+i)<=data(lastpos+i-1) %Si es menor al tope y va bajando, compro.
                    compra=1;
                    x1=data(lastpos+i);
                    level=0;
                end
            end
            if compra==1
                if data(lastpos+i)<=extremos(1,5)*(1-xlarge)
                    level=1;
                end
            end
            if compra==1
                if data(lastpos+i)>=extremos(1,5)*(1+xlarge) && level==1 ...
                        || data(lastpos+i)>=extremos(1,4)*(1+xlarge) ...
                        || i==Time %Aqu'i hago stop loss o vendo cuando se toque el m'inimo reciente o despues que se acabe el tiempo
                    x2=data(lastpos+i);
                    compra=0;
                    r1=(x2-x1)*100;
                    R=[R r1];
                end
            end
        end     
    end
    if x1==0
        r1=x1;
        R=[R r1];
    end
elseif Type==9 %Double Tops
    for i=1:Time %Examino precio por precio hasta que se acabe la ventanta de tiempo en la que se cumpli'o el patr'on
        if lastpos+i<size(data,1)
            if compra==0 %Si no ha comprado nada y ve la oportunidad, que compre. 
                if data(lastpos+i)<=extremos(1,2)*(1-xlarge)
                    compra=1;
                    x1=data(lastpos+i);
                end
            end
            if compra==1
                if data(lastpos+i)>=extremos(1,2)*(1+xlarge) ...
                        || i==Time %Aqu'i hago stop loss o vendo cuando se toque el m'inimo reciente o despues que se acabe el tiempo
                    x2=data(lastpos+i);
                    compra=0;
                    r1=(x2-x1)*100;
                    R=[R r1];
                end
            end     
        end
    end
    if x1==0
        r1=x1;
        R=[R r1];
    end
elseif Type==10 %Double Bottoms
    for i=1:Time %Examino precio por precio hasta que se acabe la ventanta de tiempo en la que se cumpli'o el patr'on
        if lastpos+i<size(data,1)
            if compra==0 %Si no ha comprado nada y ve la oportunidad, que compre. 
                if data(lastpos+i)<=extremos(1,2)*(1-xlarge)
                    compra=1;
                    x1=data(lastpos+i);
                end
            end
            if compra==1
                if data(lastpos+i)>=extremos(1,2)*(1+xlarge)...
                        || i==Time %Aqu'i hago stop loss o vendo cuando se toque el m'inimo reciente o despues que se acabe el tiempo
                    x2=data(lastpos+i);
                    compra=0;
                    r1=(x2-x1)*100;
                    R=[R r1];
                end
            end
        end
    end
    if x1==0
        r1=x1;
        R=[R r1];
    end
end
    
end 