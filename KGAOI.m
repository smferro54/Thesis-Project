% KERNEL GAUSSIANO CON AJUSTE DE VOLUMEN
%
% Función: Adicional al sistema de pesos según la distancia, se realiza una
% ponderación según el volumen negociado durante la jornada. Para este fin,
% se crea una distribución de los pesos, se suman los puntajes a los de
% distancia y se renormalizan los pesos. 

function [mker]= KGAOI(data,volexc)
%% Primero se define el h óptimo para el kernel
%para hacer pruebas
x=(-2*pi:0.1:2*pi)';
n=length(x);
y=zeros(n,1);
y1=zeros(n,1);
for i=1:n
    y(i)=sin(x(i))+0.5*random('Normal',0,1);
    y1(i)=sin(x(i));
end

t=(1:n)';
h0=median(abs(t-median(t)))/0.6745*(4/3/n)^0.2; %Banda óptima sugerida por 
                                            %Bowman y Azzalini (1997) p.31
f=@(h)kereq(y,h);
[h]=fminsearch(f,h0);
%h=2.5*h;
%con el h óptimo calculamos el nuevo filtro

%función de kernel gaussiano
kerg=@(z)exp(-0.5*(z^2))/sqrt(2*pi);

%Regresión lineal local
z=zeros(n,1);yhat=zeros(n,1);w=zeros(n,1);
for i=1:n
    t1=zeros(n,1);
    for j=1:n
        t1(j)=t(j)-t(i);
        z(j,1)=kerg(t1(j,1)/h);
    end
    %función a minimizar
    for k=1:n
        w(k)=z(k)/sum(z);
    end
    t1=[ones(n,1) t];%agrego un vector con unos para la regresión con intercepto
    g=@(beta) sum(((y-t1*beta).^2).*w);
    beta0=(t1'*t1)\t1'*y;%vector inicial es el estimador matricial
    options=optimset('MaxFunEvals',10000,'MaxIter',10000);
    [beta]= fminsearch(g,beta0,options);
    yhat(i)=beta'*[1; t(i)];
    clear t1
end

%Estimación de kernel para comparación con regresión lineal local

z=zeros(n,1);w=zeros(n,1);yker=zeros(n,1);
for i=1:n
    for j=1:n
        z(j)=kerg((t(j)-t(i))/h);
    end
    for k=1:n
        w(k)=z(k)/(sum(z));
    end
    yker(i)=sum(w.*y);
end

plot(t,yker,'-',t,yhat,'-.',t,y1,'.',t,y)
legend('R. Kernel','RLL','Sin(x)','Sin(x)_e')
%plot(t,yker,t,yhat,t,y)
%legend('yker','yhat','y')

%% Cargue de datos

%Leer desde matlab porque la ventana de comandos no deja hacer nada
%data=xlsread('K:\600_Vice_Financiera\Gerencia_Inversiones\zona_comun\Estudios_Economicos\asanabria\tecdolar.xlsm');
DollarNoVol=xlsread('C:\Users\Sergio\Documents\MATLAB\BaseTesis.xlsx',1);
DollarVol=xlsread('C:\Users\Sergio\Documents\MATLAB\BaseTesis.xlsx',2);
Ecopetrol=xlsread('C:\Users\Sergio\Documents\MATLAB\BaseTesis.xlsx',3);
Tes20=xlsread('C:\Users\Sergio\Documents\MATLAB\BaseTesis.xlsx',4);
Tes24=xlsread('C:\Users\Sergio\Documents\MATLAB\BaseTesis.xlsx',5);

%% Elección de la serie

ParSuav=0.2; %Par'ametro que suaviza la banda de bowman y azzalini

y=DollarNoVol(:,1);
%y=DollarVol(:,1);
%y=Ecopetrol(:,1);
%y=Tes20(:,1);
%y=Tes24(:,1);

%vol=DollarVol(:,2);%Base de datos de volumen
%vol=Ecopetrol(:,2);
%vol=Tes20(:,2);
%vol=Tes24(:,2);
n=length(y);
t=(1:n)';

%% Regresión lineal local para ventanas de x datos

%función de kernel gaussiano
kerg=@(z)exp(-0.5*(z^2))/sqrt(2*pi);

x=38;
z=zeros(x,1);yhats=zeros(x,1);w=zeros(x,1);betas=zeros(1,x);
num=0;
for i=1:n-x-1
    num=i+1; %se cuenta el numero de datos que quedan para que las ventanas queden completas
end
Matriz=zeros(num-1,x);
Matrizbetas=zeros(num-1,x);
for i=1:n-x-1
    %Para cada ventana tengo una submuestra de Y y una de T para la que
    %calculo un h óptimo
    Y=y(i:i+x-1,1);
    T=t(i:i+x-1,1);
    m=length(Y);
    h0=(median(abs(T-median(T)))/0.6745)*((4/(3*m))^0.2); %Banda óptima sugerida por 
                                            %Bowman y Azzalini (1997) p.31
    %f=@(h)kereq(Y,h);
    %[h]=fminsearch(f,h0);
    h=ParSuav*h0;
    for l=i:i+x-1;
        t1=zeros(x,1);
        for j=1:x
            t1(j)=t(j+i-1)-t(l);
            z(j)=kerg(t1(j)/h);
        end
        %Cálculo de pesos
        for k=1:x
            w(k)=z(k)/sum(z);
        end
        %función a minimizar
        %if yhats~=y(l);
            t1=[ones(x,1) T];%agrego un vector con unos para la regresión con intercepto
            g=@(beta) (1/m)*sum(((Y-t1*beta).^2).*w);
            beta0=(t1'*t1)\t1'*Y;%vector inicial es el estimador matricial
            %beta=(t1'*t1)\t1'*Y;
            options=optimset('MaxFunEvals',3000,'MaxIter',3000);
            [beta]= fminsearch(g,beta0,options);
            yhats(l-i+1)=beta'*[1; t(l)];
            betas(l-i+1)=beta(2);
        %end
        clear t1
    end
    Matriz(i,:)=yhats';
    Matrizbetas(i,:)=betas;
end

plot(Matriz(201,:))
plot(t(201:238),Matriz(201,:),t(201:238),y(201:238))

%% Regresión lineal local introduciendo información de volumen para ventanas de x datos

%función de kernel gaussiano
kerg=@(z)exp(-0.5*(z^2))/sqrt(2*pi);

x=38;

z=zeros(x,1);yhats=zeros(x,1);w1=zeros(x,1);betas=zeros(1,x);w=zeros(x,1);

num=0;

for i=1:n-x-1
    num=i+1;
end

Matriz=zeros(num-1,x);
Matrizbetas=zeros(num-1,x);
ParSuav=0.2; %Este es el parametro que multiplica a h0 (Banda Bowman y Azzalini)

for i=1:n-x-1
    %Para cada ventana tengo una submuestra de Y y una de T para la que
    %calculo un h óptimo
    Y=y(i:i+x-1,1);
    T=t(i:i+x-1,1);
    V=vol(i:i+x-1,1);
    m=length(Y);
    h0=(median(abs(T-median(T)))/0.6745)*((4/(3*m))^0.2); %Banda óptima sugerida por 
                                            %Bowman y Azzalini (1997) p.31
    %f=@(h)kereq(Y,h);
    %[h]=fminsearch(f,h0);
    h=ParSuav*h0;
    for l=i:i+x-1;
        t1=zeros(x,1);
        for j=1:x
            t1(j)=t(j+i-1)-t(l);
            z(j)=kerg(t1(j)/h);
        end
        %Cálculo de pesos
        for k=1:x
            w1(k)=z(k)/sum(z); %Pesos según distancia, suman 1.
        end
        for k=1:x
            w(k)=(w1(k)*V(k))/(w1'*V); %Normalizo el vector
        end
        %función a minimizar
        %if yhats~=y(l);
            t1=[ones(x,1) T];%agrego un vector con unos para la regresión con intercepto
            g=@(beta) (1/m)*sum(((Y-t1*beta).^2).*w);
            beta0=(t1'*t1)\t1'*Y;%vector inicial es el estimador matricial
            %beta=(t1'*t1)\t1'*Y;
            options=optimset('MaxFunEvals',3000,'MaxIter',3000);
            [beta]= fminsearch(g,beta0,options);
            yhats(l-i+1)=beta'*[1; t(l)];
            betas(l-i+1)=beta(2);
        %end
        clear t1
    end
    Matriz(i,:)=yhats';
    Matrizbetas(i,:)=betas;
end

plot(Matriz(201,:))
plot(t(201:238),Matriz(201,:),t(201:238),y(201:238))

%% Conteo de extremos e identificaci'on de ventanas con patrones

extrema=zeros(num-1,38);
numextrema=zeros(num-1,38);
for i=1:num-1
    for j=1:37
        if sign(Matrizbetas(i,j))==-sign(Matrizbetas(i,j+1));
            numextrema(i,j+1)=1;
            if sign(Matrizbetas(i,j))>0 %si el primero es positivo y el segundo negativo es un m'aximo
                extrema(i,j+1)=1;
            else %de lo contrario es un m'inimo
                extrema(i,j+1)=2;
            end
        end
    end
end

%Con el identificador de extremos locales se identifican patrones como una
%sucesi'on de m'aximos y m'inimos

%%% Los primeros 8 patrones requieren al menos 5 extremos consecutivos, por
%%% lo que se van haciendo candidatas las ventanas que tengan al menos 5
%%% extremos, y ah'i se eval'ua el tipo de patr'on.

NumVentana=[]; %Aqu'i voy a guardar el n'umero de la ventana en la que estoy. Esto es, la i.
patr=[];
maxi=[];
for i=1:num-1
    if sum(numextrema(i,1:35))>4 %Busco entre las filas las mayores a 4
        k=1;
        for j=1:35
            if sum(numextrema(i,k:j))==1
                if numextrema(i,j)==1    
                    pos1=i+j-1;
                    if extrema(i,j)==1 %S'olo necesito saber como empieza, son m'aximos y m'inimos consecutivos
                        max1=1;
                    else
                        max1=0;
                    end
                    maxi=[maxi max1]; %Guardo esto en mi vector de inicios
                end
            elseif sum(numextrema(i,k:j))==2
                if numextrema(i,j)==1    
                    pos2=i+j-1;
                end
            elseif sum(numextrema(i,k:j))==3
                if numextrema(i,j)==1    
                    pos3=i+j-1;
                end
            elseif sum(numextrema(i,k:j))==4
                if numextrema(i,j)==1    
                    pos4=i+j-1;
                end
            elseif sum(numextrema(i,k:j))==5 %Cuando completo los 5 guardo mis posiciones en una fila de la matriz patr
                if numextrema(i,j)==1    
                    pos5=i+j-1;
                    CompletePositions = [pos1 pos2 pos3 pos4 pos5]; %Aqu'i queda guardado mi patron
                    if isempty(patr)
                        patr=[patr;CompletePositions];
                        NumVentana=[NumVentana;i];
                    elseif isequal(CompletePositions,patr(end,:))==0
                        patr=[patr;CompletePositions];
                        NumVentana=[NumVentana;i];
                    end
                end
            elseif sum(numextrema(i,k:j))>5 %si en la fila hay mas de 5 extremos corro el k hasta despu'es del primer extremo encontrado
                k=pos2-i+1; %Esto es el segundo extremo en la serie, que va a ser el primer extremo del nuevo patron.
            end
        end
    end
end

%% Condicionales para identificar cada uno de los 8 patrones que comprenden 5 extremos consecutivos

%%% Tengo que establecer los parámetros primero para facilitar la
%%% calibración

banda=0.005; %Los autores usan una banda de 1.5%.
xlarge=banda/2; %La mitad de la banda es hacia arriba, la otra mitad es del putno para abajo.
xsmall=xlarge/2; %Esta es la mitad, por lo que se usa para los patrones m'as estrictos.

Tes=0;

if isequal(y,DollarNoVol)
    cd 'C:\Users\Sergio\Tesis\ResultadosDolarNoVol';
elseif isequal(y,DollarVol(:,1))
    cd 'C:\Users\Sergio\Tesis\ResultadosDolarVol';
elseif isequal(y,Ecopetrol(:,1))
    cd 'C:\Users\Sergio\Tesis\ResultadosEcopetrol';
elseif isequal(y,Tes20(:,1))
    cd 'C:\Users\Sergio\Tesis\ResultadosTES20';
    Tes=1;
elseif isequal(y,Tes24(:,1))
    cd 'C:\Users\Sergio\Tesis\ResultadosTES24';
    Tes=1;
end

type={};
rcon=[];
Time=[];
fecDTF=[];
for k=1:size(patr,1)
    y1=y(patr(k,1));
    y2=y(patr(k,2));
    y3=y(patr(k,3));
    y4=y(patr(k,4));
    y5=y(patr(k,5));
    ys=[y1 y2 y3 y4 y5];
    m1=mean([y1 y5]);
    m2=mean([y2 y4]);
    i=NumVentana(k);
    if maxi(k)==1 && y3>y1 && y3>y5 && (1-xlarge)*m1<y1 && y1<(1+xlarge)*m1 && ...
            (1-xlarge)*m1<y5 && y5<(1+xlarge)*m1 && (1-xlarge)*m2<y2 && y2<(1+xlarge)*m2 && (1-xlarge)*m2<y4 && y4<(1+xlarge)*m2
        Time=patr(k,5)-patr(k,1);
        if Tes==1
            [f,r]=StratEvalTES(y,ys,patr(k,5),Time,xlarge,1);
        else
            [f,r]=StratEval(y,ys,patr(k,5),Time,xlarge,1);
        end
        if length(f)~=length(r)
            disp('error en cabeza y hombros')
        end
        fecDTF=[fecDTF; f];
        rcon=[rcon; r'];
        type=[type; ['Cabeza y hombros en la posicion ' num2str(patr(k,1))]];
        plot(t(i:i+37),y(i:i+37),'',t(i:i+37),Matriz(i,:));
        for m=1:5
            hold on              
            plot(t(patr(k,m)),y(patr(k,m)),'bo');
        end
        filename=type(end);
        title(filename)
        eval(['print -dbmp H&S_' num2str(patr(k,1)) num2str(patr(k,5)) '.bmp']);
        close
    end
    if maxi(k)==0 && y3<y1 && y3<y5 && (1-xlarge)*m1<y1 && y1<(1+xlarge)*m1 && ...
            (1-xlarge)*m1<y5 && y5<(1+xlarge)*m1 && (1-xlarge)*m2<y2 && y2<(1+xlarge)*m2 && (1-xlarge)*m2<y4 && y4<(1+xlarge)*m2
        if Tes==1
            [f,r]=StratEvalTES(y,ys,patr(k,5),Time,xlarge,2);
        else
            [f,r]=StratEval(y,ys,patr(k,5),Time,xlarge,2);
        end
        if length(f)~=length(r)
            dbstop
        end
        fecDTF=[fecDTF; f];
        rcon=[rcon; r'];
        type=[type; ['Cabeza y hombros invertido en la posicion ' num2str(patr(k,1))]];
        plot(t(i:i+37),y(i:i+37),'',t(i:i+37),Matriz(i,:));
        for m=1:5
            hold on              
            plot(t(patr(k,m)),y(patr(k,m)),'bo');
        end
        filename=type(end);
        title(filename)
        eval(['print -dbmp IH&S_' num2str(patr(k,1)) num2str(patr(k,5)) '.bmp']);
        close
    end
    if maxi(k)==1 && y1<y3 && y3<y5 && y2>y4;
        if Tes==1
            [f,r]=StratEvalTES(y,ys,patr(k,5),Time,xlarge,3);
        else
            [f,r]=StratEval(y,ys,patr(k,5),Time,xlarge,3);
        end
        if length(f)~=length(r)
            dbstop
        end
        fecDTF=[fecDTF; f];
        rcon=[rcon; r'];
        type=[type; ['Broadening tops en la posicion ' num2str(patr(k,1))]];
        plot(t(i:i+37),y(i:i+37),'',t(i:i+37),Matriz(i,:));
        for m=1:5
            hold on              
            plot(t(patr(k,m)),y(patr(k,m)),'bo');
        end
        filename=type(end);
        title(filename)
        eval(['print -dbmp BTOPS_' num2str(patr(k,1)) num2str(patr(k,5)) '.bmp']);
        close
    end
    if maxi(k)==0 && y1>y3 && y3>y5 && y2<y4;
        if Tes==1
            [f,r]=StratEvalTES(y,ys,patr(k,5),Time,xlarge,4);
        else
            [f,r]=StratEval(y,ys,patr(k,5),Time,xlarge,4);
        end
        if length(f)~=length(r)
            dbstop
        end
        fecDTF=[fecDTF; f];
        rcon=[rcon; r'];
        type=[type; ['Broadening bottoms en la posicion ' num2str(patr(k,1))]];
        plot(t(i:i+37),y(i:i+37),'',t(i:i+37),Matriz(i,:));
        for m=1:5
            hold on              
            plot(t(patr(k,m)),y(patr(k,m)),'bo');
        end
        if length(f)~=length(r)
            dbstop
        end
        filename=type(end);
        title(filename)
        eval(['print -dbmp BBOTTOMS_' num2str(patr(k,1)) num2str(patr(k,5)) '.bmp']);
        close
    end
    if maxi(k)==1 && y1>y3 && y3>y5 && y2<y4;
        if Tes==1
            [f,r]=StratEvalTES(y,ys,patr(k,5),Time,xlarge,5);
        else
            [f,r]=StratEval(y,ys,patr(k,5),Time,xlarge,5);
        end
        if length(f)~=length(r)
            dbstop
        end
        fecDTF=[fecDTF; f];
        rcon=[rcon; r'];
        type=[type; ['Triangle tops en la posicion ' num2str(patr(k,1))]];
        plot(t(i:i+37),y(i:i+37),'',t(i:i+37),Matriz(i,:));
        for m=1:5
            hold on              
            plot(t(patr(k,m)),y(patr(k,m)),'bo');
        end
        filename=type(end);
        title(filename)
        eval(['print -dbmp TTOPS_' num2str(patr(k,1)) num2str(patr(k,5)) '.bmp']);
        close
    end
    if maxi(k)==0 && y1<y3 && y3<y5 && y2>y4;
        if Tes==1
            [f,r]=StratEvalTES(y,ys,patr(k,5),Time,xlarge,6);
        else
            [f,r]=StratEval(y,ys,patr(k,5),Time,xlarge,6);
        end
        if length(f)~=length(r)
            dbstop
        end
        fecDTF=[fecDTF; f];
        rcon=[rcon; r'];
        type=[type; ['Triangle bottoms en la posicion ' num2str(patr(k,1))]];
        plot(t(i:i+37),y(i:i+37),'',t(i:i+37),Matriz(i,:));
        for m=1:5
            hold on              
            plot(t(patr(k,m)),y(patr(k,m)),'bo');
        end
        filename=type(end);
        title(filename)
        eval(['print -dbmp TBOTTOMS_' num2str(patr(k,1)) num2str(patr(k,5)) '.bmp']);
        close
    end
    m3=mean([y1 y3 y5]);
    m4=mean([y2 y4]);
    min1=min([y1 y3 y5]);
    max1=max([y1 y3 y5]);
    min2=min([y2 y4]);
    max2=max([y2 y4]);
    if maxi(k)==1 && (1-xsmall)*m3<y1 && y1<(1+xsmall)*m3 && (1-xsmall)*m3<y3 && ...
            y3<(1+xsmall)*m3 && (1-xsmall)*m3<y5 && y5<(1+xsmall)*m3 && (1-xsmall)*m4<y2 && ...
            y2<(1+xsmall)*m4 && (1-xsmall)*m4<y4 && y4<(1+xsmall)*m4 && min1>max2; 
        if Tes==1
            [f,r]=StratEvalTES(y,ys,patr(k,5),Time,xlarge,7);
        else
            [f,r]=StratEval(y,ys,patr(k,5),Time,xlarge,7);
        end
        if length(f)~=length(r)
            dbstop
        end
        fecDTF=[fecDTF; f];
        rcon=[rcon; r'];
        type=[type; ['Rectangle tops en la posicion ' num2str(patr(k,1))]];
        plot(t(i:i+37),y(i:i+37),'',t(i:i+37),Matriz(i,:));
        for m=1:5
            hold on              
            plot(t(patr(k,m)),y(patr(k,m)),'bo');
        end
        filename=type(end);
        title(filename)
        eval(['print -dbmp RTOPS_' num2str(patr(k,1)) num2str(patr(k,5)) '.bmp']);
        close
    end
    if maxi(k)==0 && (1-xsmall)*m3<y1 && y1<(1+xsmall)*m3 && (1-xsmall)*m3<y3 && y3<(1+xsmall)*m3 && ...
            (1-xsmall)*m3<y5 && y5<(1+xsmall)*m3 && (1-xsmall)*m4<y2 && y2<(1+xsmall)*m4 && ...
            (1-xsmall)*m4<y4 && y4<(1+xsmall)*m4 && min2>max1; 
        if Tes==1
            [f,r]=StratEvalTES(y,ys,patr(k,5),Time,xlarge,8);
        else
            [f,r]=StratEval(y,ys,patr(k,5),Time,xlarge,8);
        end
        if length(f)~=length(r)
            dbstop
        end
        fecDTF=[fecDTF; f];
        rcon=[rcon; r'];
        type=[type; ['Rectangle bottoms en la posicion ' num2str(patr(k,1))]];
        plot(t(i:i+37),y(i:i+37),'',t(i:i+37),Matriz(i,:));
        for m=1:5
            hold on              
            plot(t(patr(k,m)),y(patr(k,m)),'bo');
        end
        filename=type(end);
        title(filename)
        eval(['print -dbmp RBOTTOMS_' num2str(patr(k,1)) num2str(patr(k,5)) '.bmp']);
        close
    end
end

%% Double Bottoms y Double Tops

%Para doble soporte o doble resistencia debo comparar todas las
%parejas posibles de puntos.

cand=[];
vent=[];
maxi=[];
pos=[];
for i=1:num-1
    if sum(numextrema(i,1:35))>1 %Busco entre las filas que tengan por lo menos dos extremos
        for j=1:35
            if numextrema(i,j)==1
                pos=i+j-1;
                if isempty(cand)
                    cand=[cand;pos];
                    if extrema(i,j)==1 %S'olo necesito saber como empieza, son m'aximos y m'inimos consecutivos
                        max1=1;
                    else
                        max1=0;
                    end
                    vent=[vent;i];
                    maxi=[maxi;max1];
                elseif sum(any(pos==cand))==0
                    cand=[cand;pos];
                    if extrema(i,j)==1 %S'olo necesito saber como empieza, son m'aximos y m'inimos consecutivos
                        max1=1;
                    else
                        max1=0;
                    end
                    vent=[vent;i];
                    maxi=[maxi;max1];
                end
            end
        end
    end
end

for k=1:length(cand)
    y6=y(cand(k)); %este es el punto base
    for j=k:length(cand)
        y7=y(cand(j)); %Este es el punto de comparaci'on
        ys=[y6 y7];
        m5=mean([y6 y7]);
        minimum=min([y6 y7]);
        maximum=max([y6 y7]);
        if maxi(k)==1 && maxi(j)==1 && (1-xsmall)*m5<y6 && y6<(1+xsmall)*m5 && ...
                (1-xsmall)*m5<y7 && y7<(1+xsmall)*m5 && cand(j)-cand(k)>21 && cand(j)-cand(k)<37 ...
                && sum(y(cand(k):cand(k)+37)>minimum)<2
            if Tes==1
                [f,r]=StratEvalTES(y,ys,cand(j),Time,xlarge,9);
            else
                [f,r]=StratEval(y,ys,cand(j),Time,xlarge,9);
            end
            fecDTF=[fecDTF; f];
            rcon=[rcon; r'];
            type=[type; ['Double tops en la posicion ' num2str(cand(k))]];
            plot(t(cand(k):cand(k)+37),y(cand(k):cand(k)+37),'',t(cand(k):cand(k)+37),Matriz(cand(k),:));
            hold on              
            plot(t(cand(k)),y(cand(k)),'bo');
            hold on
            plot(t(cand(j)),y(cand(j)),'bo');
            filename=type(end);
            title(filename)
            eval(['print -dbmp DTOPS_' num2str(cand(k)) num2str(cand(j)) '.bmp']);
            close
        end
        if maxi(k)==0 && maxi(j)==0 && (1-xsmall)*m5<y6 && y6<(1+xsmall)*m5 && ...
                (1-xsmall)*m5<y7 && y7<(1+xsmall)*m5 && cand(j)-cand(k)>21 && cand(j)-cand(k)<37 ...
                && sum(y(cand(k):cand(k)+37)<maximum)<2
            if Tes==1
                [f,r]=StratEvalTES(y,ys,cand(j),Time,xlarge,10);
            else
                [f,r]=StratEval(y,ys,cand(j),Time,xlarge,10);
            end
            fecDTF=[fecDTF; f];
            rcon=[rcon; r'];
            type=[type; ['Double bottoms en la posicion ' num2str(cand(k))]];
            plot(t(cand(k):cand(k)+37),y(cand(k):cand(k)+37),'',t(cand(k):cand(k)+37),Matriz(cand(k),:));
            hold on              
            plot(t(cand(k)),y(cand(k)),'bo');
            hold on
            plot(t(cand(j)),y(cand(j)),'bo');
            filename=type(end);
            title(filename)
            eval(['print -dbmp DBOTTOMS_' num2str(cand(k)) num2str(cand(j)) '.bmp']);
            close
        end
    end
end

%% Is technical analisys informative?

rle=length(rcon)*10;
rnocon=zeros(rle,1);
for i=1:rle
   posi=randi(length(y)-1,1,1);
   if Tes==1 
        r=y(posi+1)-y(posi);
   else
        r=y(posi+1)/y(posi)-1;
   end
   rnocon(i)=r;
end
% Defino los deciles
dist=sort(rnocon);
% Clasifico los retornos condicionales en los deciles
d=zeros(10,1);
meh=ones(11,1);
meh1=length(rcon);
for i=1:11
    meh(i)=meh1*(i-1);
end
meh(1)=1;
for i=1:length(rcon)
    for j=1:10
        if rcon(i)>dist(meh(j))&& rcon(i)<dist(meh(j+1))
            d(j)=d(j)+1;
        end
    end
end
q=zeros(10,1);
for i=1:10
   q(i)=((d(i)-0.1*length(rcon))^2)/(0.1*length(rcon));
end
Q=sum(q);

rcon=[rcon;Q];
fecDTF=[fecDTF;0 0];

%% Test de Kolmogorov-Smirnov para dos muestras

%Calculo el test y lo pego en mis resultados

[~,Rho]=kstest2(rcon,rnocon);

rcon=[rcon;Rho];
fecDTF=[fecDTF;0 0];

TotalResults=[rcon fecDTF];

xlswrite('RconKS.xlsx',TotalResults);

%Primero estandarizo los vectores de rcon y rnocon

%Zrcon=zscore(rcon);
%Zrnocon=zscore(rnocon);

%Luego se ordena un vector conjunto para poder calcular las distribuciones
%amuculadas Frcon y Frnocon

%Ztotal=[Zrcon;Zrnocon];
%Ztotal=sort(Ztotal);

%Para cada punto de este vector calculo la distribución empírica acumulada

%[Frcon,~]=ecdf(Ztotal,Zrcon);
%[Frnocon,Ztotal]=ecdf(Zrnocon);

%Luego calculo la m'axima diferencia entre las dos distribuciones
%maxi=max(Frcon-Frnocon);

%Con esto calculo el estad'istico de Kolmogorov-Smirnov
%KSstat=((length(rcon)*length(rnocon)/(length(rcon)+length(rnocon)))^0.5)*maxi;

%Lo pego en mis resultados

%rcon=[rcon;KSstat];

%xlswrite('RconKS.xlsx',rcon);
end

