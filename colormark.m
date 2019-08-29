function [ marked ] = colormark( image, mark, a )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inizializzazione, preparazione, e cose varie e segrete
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[X,Y,Z,W] = dwt2(image, 'Haar');%Passaggio al dominio Wavelet
LIMIT_GLOBAL = std(std(double(image)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Filtro Passa Alto

X_high=uint8(X);
kernel = [-1 -1 -1;-1 8 -1;-1 -1 -1];%Filtro passa alto
filtered = imfilter(X_high, kernel, 'same');%Filtro passa alto
mark_long = size(mark,2);
LIMIT_FILTER = std(std(double(filtered)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[m,n] = size(X);%La dimensione dell'immagine deve essere divisibile per 4!
n1 = m/4; %righe
n2 = n/4; %colonne

N1 = 4*ones(1,n1);
N2 = 4*ones(1,n2);
LIMIT_SHAPE = 2*LIMIT_FILTER +1;
LIMIT_CHANNEL = 2*LIMIT_GLOBAL +1;
z=1;%Inizializzazione controllo
k=0;%Inizializzazione controllo
record = [1:n1*n2];

filtered_cell = mat2cell(filtered,N1,N2);
image_cell = mat2cell(X,N1,N2);
marked_cell = image_cell;

while z<mark_long
        
    for i = record
        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Cerchiamo alti valori di variazione sulle alte frequenze per
            %decidere dove marchiare
            DEV_SHAPE = std(std(double(filtered_cell{i})));
            DEV_CHANNEL = std(std(double(image_cell{i})));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

          if DEV_SHAPE>=LIMIT_SHAPE && DEV_CHANNEL>=LIMIT_CHANNEL && z<mark_long

              supp = dct2(image_cell{i});
              supp(1,2) = supp(1,2) + a*mark(z);
              supp(2,1) = supp(2,1) + a*mark(z+1);      
              supp = idct2(supp);
              marked_cell{i} = supp;
              z = z+2; 
              record(find(record == i)) = [];
              
           end

    end  
    
    if k>149
        
      LIMIT_SHAPE = 0; 
      
    elseif k>99
        
      LIMIT_CHANNEL = 0;
      LIMIT_SHAPE = abs(LIMIT_SHAPE/2);
      
    else
        
        if z<mark_long

            LIMIT_SHAPE = abs(LIMIT_SHAPE -(LIMIT_SHAPE)/20);
            LIMIT_CHANNEL = abs(LIMIT_CHANNEL -(LIMIT_CHANNEL)/10);

        end
    end
    
    k=k+1;
    
end

    marked = cell2mat(marked_cell);
    marked = idwt2(marked, Y, Z, W, 'Haar');
    marked = uint8(marked);
    
end