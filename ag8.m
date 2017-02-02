% Cortador de ca�os mediante Algoritmos Gen�ticos: (rev. 20-04-08)
% ================================================

% Importaremos un archivo de texto con los datos separados por " ; " que en
% su primer fila contiene la longitud de los listones comprados, en nuestro
% caso Lmax.
% Las resultantes filas (no se sabe cuantas pueden ser) tienen dos numeros 
% enteros, el primero es la cantidad de ca�os cortados necesarios de la 
% longitud es especificada por el segundo numero.
% El nombre del archivo de entrada siempre sera: agXX.txt  (donde XX es un 
% numero, por ej. ag01.txt)
% El archivo de salida a generar debera ser: agXXgdg.txt  (siendo GDG las 
% iniciales del alumno).
% Este archivo de salida informara la Cantidad de tiras utilizadas y la 
% suma total de los desperdicios.
%--------------------------------------------------------------------------
clear;
clc;
disp('Este es un programa para optimizar la compra de ca�os.')
disp('Por favor, verifique que el archivo con los datos se encuentre en el directorio de trabajo.')
disp(' ')
String=char(input ('Ingrese el nombre del archivo con datos entre apostrofes (comillas simples) = '));
disp(' ')
if (size(String)~=[1 8])
    disp('El nombre del archivo no es correcto.')
    beep;                                   %sonido de llamado de atencion
end
Archivo=dlmread(String,';');

%Comenzamos a acomodar los parametros como nos resulta util
Lmax=Archivo(1,1);
Longitudes=Archivo(2:end,2);
Cantidades=Archivo(2:end,1);

CantDeTirasTotales=sum(Cantidades);     %suma los elementos del vector

% Que hicimos hasta ahora? 
% Importamos los datos del archivo y nos quedamos con:
%       Lmax:longitud estandar de las tiras de ca�os comprados
%       Longitudes:vector con las longitudes de los cortes solicitados
%       Cantidades:vector con las cantidades de los listones pedidos
%       CantDeTirasTotales:sumatoria de Cantidades

% Una vez hecho esto podemos liberar de la memoria los datos que no 
% utilizaremos mas como ser la matriz archivo, esto se deberia hacer 
% siempre que sea posible con todas las variables pero lo omitire para no 
% dificultar la comprension del programa.  :-)

clear Archivo;


% Constantes Importantes:
% ======================
disp(' ')
disp(' ')
disp('Ahora podremos experimentar modificando la estructura ')
disp('de funcionamiento de nuestro algoritmo:')
disp(' ')
P=input ('Ingrese la cantidad de Individuos de la Poblacion de posibles soluciones (minimo 50)=')
disp(' ')
CantItera=input ('Ingrese la cantidad de Iteraciones o Repeticiones del algoritmo (minimo 30)=')
Iteracion=[1:CantItera];

m=0;                %mutaciones iniciales realizadas por iteracion


% Generamos el vector "Largos" de [CantDeTirasTotales x 1]

Largos=zeros([CantDeTirasTotales 1]);      %inicializo un vector con cero

j=1;
for i=1:CantDeTirasTotales
	contador=1;
    %carga del vector "Largos"
    while ((j<=CantDeTirasTotales)&(contador<=Cantidades(i)))    
		Largos(j,1)=Longitudes(i);
		j=j+1;
		contador=contador+1;
	end
end
% Largos:longitudes de tiras cortadas de cada codificacion binaria de tira

LargosTot=sum(Largos);

% Generamos la matriz "Datos" de [CantDeTirasTotales x P]
% INICIO DEL PRE PROSESAMIENTO IMPONIENDO LA PEOR CONDICION PARA LA
% CANTIDAD DE TIRAS A EMPLEAR (CantDeTirasTotales)

Datos=randint(CantDeTirasTotales,P,[1,CantDeTirasTotales]);     
%generamos la poblacion inicial de soluciones, de manera RANDOM (Aleatoria)


% ANALIZANDO EL PROGRAMA:
% Por el momento veremos que en la matriz "Datos" nos quedaron varios 
% elementos sin usar (por ej. que el numero 13 de codificaci�n binaria 
% nunca apareci�, mientas que otras codificaciones aparecieron repetidas 
% veces), esto significa que esa codificacion binaria de tira no se empleo 
% en la solucion. Las que si aparecen, es lo que se aprovecho del liston 
% n�mero tal (contenido de Datos[i][n]), de long Largos[i].
% 
% Para buscar una solucion aceptable para nuestro problema, debemos evaluar
% la aptitud de cada individuo (solucion) de la poblacion. Para cuantificar
% la aptitud (fitness), emplearemos la siguiente funcion de evaluacion:
% 
%    Aptitud = Cantidad de tiras empleadas + Sumatoria de desperdicios
%                       
%   
% Nota: casualmente tenemos una variable TirasNoEmpleadas, ohhh!
% Otra mas... hablar de desperdicios es = que MaterialRestantePorTira

% Siempre procuraremos minimizar la funcion de evaluacion, ya cuanto mas 
% bajo sea el valor num�rico de nuestra funci�n, menos cantidad de tiras 
% empleamos, y menor es el desperdicio producido.

% La matriz "Valor" contiene la sumatoria de los largos de ca�o empleado
% por las soluciones.

% Ahora calcularemos el desperdicio que resulta de cada liston utilizado 
% haciendo:
% 
%  MaterialRestantePorTira = Desp = Lmax - Valor   (en las tiras empleadas)
%                                     
% Notando que se pueden presentar las siguientes 3 alternativas:
% a)Desp>0   %desperdicio longitudinal real de la tira (situacion habitual)
% b)Desp<0   %situacion irrealizable, ya que gastamos mas longitud del 
             %liston que Lmax (penalizamos la aptitud a dicha solucion)
% c)Desp=0   %situacion optima, mayor aprovechamiento del liston (premiamos
             %la aptitud de estas soluciones) 

IteraActual=0;

for iteraciones=1:CantItera    %====== INICIO DEL LOOP ALGORITMICO ========   
%cantidad de ciclos que se repite el algoritmo (minimo 30)

IteraActual=IteraActual+1;                               

% Debemos inicializar cada vez las 2 matrices para que levanten los datos 
% de la nueva poblacion.
clear Valor;                                   
Valor=zeros(CantDeTirasTotales,P);       
% cada posicion sera el numero de tira al que pertenece el corte 
% (total de tiras = CantDeTirasTotales)
% En la matriz "Valor" haremos la sumatoria de los largos de las soluciones

for j=1:P
    for i=1:CantDeTirasTotales
          Valor(Datos(i,j),j)=Valor(Datos(i,j),j)+Largos(i);          
          %sumatoria // Fila:Datos(i,j) Columna:j         
    end
end

clear TirasNoEmpleadas;
TirasNoEmpleadas=Valor<=0;
MaterialRestantePorTira=ones(CantDeTirasTotales,P)*Lmax.*(~TirasNoEmpleadas);
MaterialRestantePorTira=MaterialRestantePorTira-Valor;     %incrementamos

% Hasta aqui tenemos:
% - Datos: la poblacion actual
% - Largos: las longitudes de tiras cortadas de cada codificacion binaria 
%           de tira
% - Valor: tengo la sumatoria en longitud, de los listones usados por ese 
%          codigo binario 
% - MaterialRestantePorTira: longitud sobrante de esa codificacion binaria 
%                            de tira
% -------------------------------------------------------------------------
% Notar que si el material sobrante por tira es cero, puede darse porque no
% se empleo dicha codificacion, o porque se realizo una combinacion 
% perfecta de cortes, de ser esta segunda premiaremos la aptitud de dicha 
% combinacion, y en el caso de que sea negativa, debemos penalizar ya que 
% estamos requiriendo un liston mas largo del que disponemos para hacer la 
% combinacion de cortes.


% Ahora obtendremos la APTITUD de cada solucion, osea de la poblacion:
%    Aptitud = Cantidad de tiras empleadas + Sumatoria de desperdicios

CantidadDeTirasEmpleadas=CantDeTirasTotales*ones(1,P)-sum(TirasNoEmpleadas);

% La Sumatoria de desperdicios es mas compleja porque debemos analizar los
% 3 casos posibles, para arrojar un valor numerico para el valor de Aptitud

% a) Desp > 0      
% desperdicio longitudinal real de la tira (situacion habitual)
DespA=sum(MaterialRestantePorTira.*(MaterialRestantePorTira>0));
DespA=DespA/Lmax;       %normalizamos con respecto a Lmax       MINIMIZAR

% b) Desp < 0      
% situacion irrealizable, ya que gastamos mas longitud del liston que Lmax 
%         (penalizamos la aptitud a dicha solucion) x10
DespB=sum(MaterialRestantePorTira.*(MaterialRestantePorTira<0));
DespB=DespB/Lmax;       %normalizamos con respecto a Lmax       MINIMIZAR

% c) Desp = 0
% situacion �ptima, mayor aprovechamiento del liston (premiamos) x5 
DespC=sum(MaterialRestantePorTira==0);                         %MAXIMIZAR

% Obtenemos la Sumatoria de desperdicios, recordar que menor valor num�rico
% es mas Apto !!!      -->     MINIMIZAR
Desp=1*DespA+10*abs(DespB)+5*(CantDeTirasTotales-DespC);


% Contemplamos que la long de nuestra solucion sea la necesaria
SumValor=sum(Valor);

Aptitud=CantidadDeTirasEmpleadas+Desp;     %aptitud del conj. de soluciones

AptiProm=(sum(Aptitud))/P;           %aptitud promedio de esta la poblaci�n

Evaluacion_AptiProm(iteraciones)=AptiProm;       %luego con un PLOT veremos
% la evolucion del conjunto de soluciones en funcion de las iteraciones 
   
                                                                                
% =========================================================================
% Criterios de:   - Apareamiento (reproduccion binaria, 2 padres generan 2 
% =============     hijos y 2 poco aptos fallecen) 
%                 - Mutaci�n (anomal�a gen�tica en la copia de genes a la 
%                   siguiente generaci�n de individuos)
%               
% Ahora definiremos en base a la "aptitud" que posee cada individuo de la 
% poblaci�n, con respecto a la aptitud promedio que posee dicha poblaci�n,
% quienes son las mejores soluciones (valor num�rico de la aptitud baja) y 
% quienes son las peores soluciones.
% Las mejores soluciones se Aparearan, para intercambiar material gen�tico 
% para intentar obtener una mejor soluci�n, las peores soluciones tendr�n 
% la posibilidad de mutar para ver si se pueden encaminar hacia una mejor 
% soluci�n, mientras tanto la media de las soluciones pasara directamente 
% a la siguiente generaci�n.

% El umbral de apareo debe ser menor que la media, ya que menor aptitud es
% mejor. Estoy empleando un criterio de selecci�n muy simple: EL ELITISTA.
if IteraActual<=(CantItera/2)
    UmbralApareo=0.97*AptiProm;     
else
    UmbralApareo=0.98*AptiProm;
end
% Notar que soy mas ELITISTA en la selecci�n de individuos, al comienzo de 
% la evoluci�n de mi poblaci�n.

ProbaMuta=randsrc(1,1,[0 1;.99 .01]);   
% Debemos ser cautelosos con la pobabilidad de Mutacion < 1/100

clear Indices_Para_Aparear;
Indices_Para_Aparear=find(Aptitud<=UmbralApareo);

% El apareamiento para realizar el intercambio gen�tico, se producira a 
% trav�s de una mascara binaria generada de manera aleatoria, de esta 
% manera podemos independizarnos la posici�n en la que se encuentran los 
% genes, ya que si tenemos una secuencia de genes 1-2-3-4-5-6-7-8, podemos
% hacer que s�lo se intercambien los genes 1 y 3, sin necesidad de 
% intercambiar el gen 2 que se encuentra entre �stos.

Mask=randsrc(CantDeTirasTotales,1,[0:1]);
% generamos un vector mascara binaria, de manera RANDOM

Not_Mask=~Mask;                   %obtenemos una mascara complementaria

[a1,a2]=size(Indices_Para_Aparear);    
% averiguamos cuantos individuos tenemos para aparear (a2)

Evaluacion_Apareos(iteraciones)=a2;     
% luego con un HIST veremos la cantidad de apareamientos del conjunto
% de soluciones en funcion de las iteraciones 

                                        
% Apareamiento: (si no hay al menos 2 en condiciones, no se puede aparear)
% =============

Datos=Datos([1:CantDeTirasTotales],[1:P]);  %PARCHE

if a2>1
    ExtractA=Datos(:,[Indices_Para_Aparear]);         
    %extraemos diversas columnas de la matriz datos
    ExtractB=ExtractA;
    for a1=1:(a2)                                     
        %para trabajar con las mascaras
        ExtractA(:,a1)=Not_Mask.*ExtractA(:,a1);
        ExtractB(:,a1)=Mask.*ExtractB(:,a1);
    end
    acumulador=ExtractB(:,1);                         
    %guardo la primer columna, el primer medio individuo
    %desplazamos para hacer el intercambio de genes
    for a1=1:(a2-1)                                   
        ExtractB(:,a1)=ExtractB(:,a1+1);  
    end
    ExtractB(:,a2)=acumulador;
    ExtractA=ExtractA+ExtractB;                  
    %tenemos los nuevos individuos de la poblacion, que reemplazaran a                                             
    %alguno de las peores soluciones (mayor aptitud numerica en nuestro caso)
    
    
    %Busqueda de los REEMPLAZOS:
 
    Aptitud_Decreciente=sort(Aptitud*-1);        
    %multiplicamos por -1 porque SORT ordena en forma creciente
    Aptitud_Decreciente=Aptitud_Decreciente*-1;
    
    %en este instante dentro de "Aptitud_Decreciente", en sus primeras "a2"
    %posiciones, tenemos las aptitudes de los peores individuos de la 
    %poblaci�n (valor num�rico mas grande), y guardaremos en 
    % "Indice_Para_Reemplazar" el indice que se corresponde en la matriz 
    % "Datos"
    
    Flag=find(Aptitud>Aptitud_Decreciente(a2));
    Flag1=find(Aptitud==Aptitud_Decreciente(a2));
    
    [c1,c2]=size(Flag);
    
    while c2<a2             %nos aseguramos de tener la cantidad necesaria
        Flag=[Flag Flag1(c1)];
        c1=c1+1;
        c2=c2+1;
    end
    
    Indice_Para_Reemplazar=Flag(1:a2);      
    %tenemos los indices de los individuos que reemplazaremos
    

    %REEMPLAZOS:
    for i=1:a2
        Datos(:,(Indice_Para_Reemplazar(i)))=ExtractA(:,i);
    end                                %lista la nueva generacion !!!
    
    
end                                               

        %---------------------------------------------------
                                                        
if (1==ProbaMuta)       
    % con ROUND redondeo al entero mas cercano y con RANDN obtengo n�meros 
    % entre -1 y 1
    Datos(randsrc(1,1,[1:256]),randsrc(1,1,[1:P]))=randsrc(1,1,[1:256]);
        m=1;                  %solo una mutaci�n
end

Evaluacion_Mutaciones(iteraciones)=m;     
% luego con un HIST veremos la cantidad de mutaciones del conjunto
% de soluciones en funcion de las iteraciones
m=0;                                      


end     %======== FIN DEL LOOP ALGORITMICO ==========


%Gr�ficas de los indicadores de funcionamiento del algoritmo:
%------------------------------------------------------------

subplot (3,1,1),plot(Iteracion,Evaluacion_AptiProm)
xlabel('Numero de iteracion del Algoritmo Genetico')
ylabel('Aptitud promedio de la poblacion')
title('Analisis de Convergencia (disminuir la aptitud = OK)')
grid on

subplot (3,1,3),bar(Iteracion,Evaluacion_Apareos)
xlim([0 Iteracion(end)])
xlabel('Numero de iteracion del Algoritmo Genetico')
ylabel('Individuos que Aparean')
grid on

subplot (3,1,2),bar(Iteracion,Evaluacion_Mutaciones)
xlim([0 Iteracion(end)])
xlabel('Numero de iteracion del Algoritmo Genetico')
ylabel('Mutaciones')
grid on


%Respuesta solicitada por el problema:
%-------------------------------------

clear i j;  
% Liberamos de la memoria las variables "j" e "i" utilizada anteriormente, 
% esto se deberia haber realizado siempre al dejar de utilizar cada 
% variable que no necesitaramos mas, pero no se hizo para no complicar el 
% entendimiento del codigo. Otro recordatorio.  :-)

j=min(Aptitud);
i=find(Aptitud==j);                  
%indice de la mejor soluci�n de la ultima poblaci�n(menor aptitud num�rica)

String=[String(1:4) 'G' 'D' 'G' String(5:8)];       
%formamos el nombre del archivo de salida con mis iniciales 

diary(String);                             %Generamos el archivo de salida

diary on                                   %Inicio del archivo

disp('Desechos acumulados de ca�os (DespA) :')
disp(DespA(1,i(1)))

disp('Desechos irrealizables de ca�os (DespB) :')
disp(DespB(1,i(1)))

disp('Combinaciones Perfectas (DespC) :')
disp(DespC(1,i(1)))

disp('Tiras de ca�os comprados empleados:')
disp(CantidadDeTirasEmpleadas(1,i(1)))

diary off                                  %Fin del archivo

disp('NOTA: miranfo la matriz Datos, subindicada por i(1), junto con el vector Largos, podemos ver como realizar los cortes.')