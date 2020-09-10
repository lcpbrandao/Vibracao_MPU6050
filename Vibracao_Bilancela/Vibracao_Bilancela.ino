#include <Wire.h>
#include <TimerOne.h>
#include <I2Cdev.h>
#include <MPU6050.h>
 
//Endereco I2C do MPU6050
const int MPU=0x68;  //pino aberto (0X68) pino ligado em 3,3V (0x69)
 
//Variaveis globais
MPU6050 accelgyro;
int acelX, acelY, acelZ, temperatura, giroX, giroY, giroZ;
double acelX_real, acelY_real, acelZ_real;
char c = 'a';
double cont = 0;

//configurações iniciais
void setup()
{
  //Inicialização da Serial e Comunicação com Matlab
  Serial.begin(57600); 		//inicia a comunicação serial
  
  Serial.println("Matlab?");
  delay(2);
  while(c != 'Q'){             //Aguarda resposta do Matlab
    if(Serial.available()){
      c = Serial.read();
      delay(1);
      }
    }
    if(c == 'Q'){
      Serial.println("Ready!");
    }
 
  Wire.begin();                  //inicia I2C
  Wire.beginTransmission(MPU);   //Inicia transmissão para o endereço do MPU
  Wire.write(0x6B);             
  Wire.write(0);                 //Inicializa o MPU-6050 
  Wire.endTransmission(true);    //Finaliza transmissão   
  
  //Inicialização do Timer1
  Timer1.initialize(1000);       //inicia o timer 1 setado para interromper a cada 5ms
  Timer1.attachInterrupt(conta);
}

void conta() {
  cont++;  
}

void loop() {
  Wire.beginTransmission(MPU);   //Inicia transmissão
  Wire.write(0x3B);              //Endereço 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU,14,true);   //Requisita bytes
   
  accelgyro.getMotion6(&acelX, &acelY, &acelZ, &giroX, &giroY, &giroZ);
  
  //Armazena o valor dos sensores nas variaveis correspondentes
//  acelX=Wire.read()<<8|Wire.read();          //0x3B (ACCEL_XOUT_H) & 0x3C (ACCEL_XOUT_L)     
//  acelY=Wire.read()<<8|Wire.read();          //0x3D (ACCEL_YOUT_H) & 0x3E (ACCEL_YOUT_L)
//  acelZ=Wire.read()<<8|Wire.read();          //0x3F (ACCEL_ZOUT_H) & 0x40 (ACCEL_ZOUT_L)
//  temperatura=Wire.read()<<8|Wire.read();    //0x41 (TEMP_OUT_H) & 0x42 (TEMP_OUT_L)
//  giroX=Wire.read()<<8|Wire.read();          //0x43 (GYRO_XOUT_H) & 0x44 (GYRO_XOUT_L)
//  giroY=Wire.read()<<8|Wire.read();          //0x45 (GYRO_YOUT_H) & 0x46 (GYRO_YOUT_L)
//  giroZ=Wire.read()<<8|Wire.read();          //0x47 (GYRO_ZOUT_H) & 0x48 (GYRO_ZOUT_L)
     
  //Envia valores lidos do acelerômetro
  //Serial.println("ACELEROMETRO (raw values):"); 
  Serial.println(acelX);
  Serial.println(acelY);
  Serial.println(acelZ);
 
  
//  acelX_real = acelX / 16384;
//  acelY_real = acelY / 16384;
//  acelZ_real = acelZ / 16384;
//  
//  Serial.println("ACELEROMETRO (real values):"); 
//  Serial.println(acelX_real);
//  Serial.println(acelY_real);
//  Serial.println(acelZ_real);
  
  //Envia valor da temperatura em graus Celsius
  //Serial.print("\nTEMPERATURA:\t\t");
  //Serial.println(temperatura/340.00+36.53);
  
  Serial.println(cont/1000);
   
  //Aguarda 5 ms entre os dados (aprox.)
  //delay(5);
}
