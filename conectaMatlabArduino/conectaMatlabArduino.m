%% CONFIGURE A SERIAL PROPERTY NAME
delete(instrfindall);

%% CREATE AN OBJECT SERIAL
serialPort = serial('COM3');     %choose your apropriate COM port
set(serialPort,'BAUD',57600,'Parity','none','DataBits',8);

%% OPEN COMMUNICATIONS
disp('Abrindo Porta...');
fopen(serialPort);
AckRead = 'a';
TC = 0;
TC2 = 0;

%% PORT OPEN RECEIVING FIRST DATA
while(TC == 0)
    AckRead=fscanf(serialPort,'%s');
    TC=strcmp(AckRead,'Matlab?');    %TC=1 if strcmp is OK
end

%% SERIAL SENDING DATA
if(TC == 1)
    disp('Estabelecendo conexão...');
    fprintf(serialPort,'%c','Q');    %Envia 'Q' para o arduino iniciar
    disp('Enviando dados...');
end

%% READ SERIAL DATA
num_pontos = 2000;
disp('Conectando...');
acelX = zeros(num_pontos,1);
acelY = zeros(num_pontos,1);
acelZ = zeros(num_pontos,1);
cont = zeros(num_pontos,1);     %Contador de ms entre os envios
fs = num_pontos;
x = 1;
dataRead = fgetl(serialPort);   %discards the first measure (?)
dataRead = 0;

while(x <= num_pontos)
    fprintf('Lendo itens posição (%d) / ', x);
    
    %reads Accelerometer x-axis
    dataRead = fgetl(serialPort);
    acelX(x) = str2double(dataRead);
    
    %reads Accelerometer y-axis
    dataRead = fgetl(serialPort);
    acelY(x) = str2double(dataRead);
    
    %reads Accelerometer z-axis
    dataRead = fgetl(serialPort);
    acelZ(x) = str2double(dataRead);
    
    %reads Contador
    dataRead = fgetl(serialPort);
    cont(x) = str2double(dataRead);
    fprintf('Tempo = %.3fs\n',cont(x));  %show data
    
    x = x + 1;
    dataRead = 0;
end

%% RETIRAR OFFSET

% %Calcula a média dos valores para subtrair como offset
% soma_acelX = 0;
% soma_acelY = 0;
% soma_acelZ = 0;
% 
% for i=1:num_pontos
%    soma_acelX = soma_acelX + acelX(i);
%    soma_acelY = soma_acelY + acelY(i);
%    soma_acelZ = soma_acelZ + acelZ(i);
% end
% 
% %Calcula offset
% offset_acelX = soma_acelX / num_pontos;
% offset_acelY = soma_acelY / num_pontos;
% offset_acelZ = soma_acelZ / num_pontos;
% 
% fprintf('%f,',offset_acelX);
% fprintf('%f,',offset_acelY);
% fprintf('%f,',offset_acelZ);

%Subtrai offset
for i=1:num_pontos
   acelX(i) = acelX(i) - (-635.796000);
   acelY(i) = acelY(i) - (-157.980000);
   acelZ(i) = acelZ(i) - (16373.976000);
end

%% Guarda em variáveis os valores dos arquivos TXT
fid = fopen('DataAccelerometer.txt','wt');
    for i=1:num_pontos
        fprintf(fid,'%f,',acelX(i));
        fprintf(fid,'%f,',acelY(i));
        fprintf(fid,'%f,',acelZ(i));
        fprintf(fid,'%f\n',cont(i));
    end
fclose(fid);

%% FFT (FAST FOURIER TRANSFORMATION)
fftacelX = fft(acelX);    %FFTs sem centralização
fftacelY = fft(acelY);
fftacelZ = fft(acelZ);

N = num_pontos;       % numero de pontos da fft
w = -fs/2:fs/2-1;     % intervalo de frequência centralizado

fftacelXshift = fftshift(fftacelX);    %FFTs centralizadas
fftacelYshift = fftshift(fftacelY);
fftacelZshift = fftshift(fftacelZ);

%% GRAPHS PLOTTING
dataAccelerometer = importdata('DataAccelerometer.txt');
acelX = dataAccelerometer(:,1);
acelY = dataAccelerometer(:,2);
acelZ = dataAccelerometer(:,3);
tempo = dataAccelerometer(:,4);

%plotting acelX/acelY/acelZ data
subplot(2,1,1);
grid on;
hold on;
plot(tempo,acelX,'-bs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',1)
plot(tempo,acelY,'-rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',1)
plot(tempo,acelZ,'-gs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',1)
legend('acelX','acelY','acelZ');
hold off;
xlabel('Tempo (s)')
ylabel('Amplitude de aceleração')
title('DADOS DO ACELERÔMETRO (X, Y, Z)')
%axis([1 30.1 -10 10])

%plotting FFT acelX/acelY/acelZ
subplot(2,1,2);
grid on;
hold on;
plot(w/10,2*abs(fftacelXshift)/(N),'-bs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',1)
plot(w/10,2*abs(fftacelYshift)/(N),'-rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',1)
plot(w/10,2*abs(fftacelZshift)/(N),'-gs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',1)
legend('FFT-Roll','FFT-Pitch','FFT-Yaw');
hold off;
xlabel('Frequência (Hz)')
ylabel('Amplitude')
title('ESPECTRO DE FREQUÊNCIAS (FFT centralizada)')
%axis([-30 30 0 5])

%% CLOSE COMMUNICATIONS 
fclose(serialPort);
