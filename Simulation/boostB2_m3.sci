//EPC 2025 - Progetto di un convertitore Boost
// Paper Model (small signal) and Open Loop Transfer Functions

clear;
clc;
close(winsid());

exec('boostB1_m1_m2.sci');
close(winsid());
clc;

//PWM e Sensore
VM=1;
Vref=2; // [V] 
Hsensor=Vref/VoN;

s=%s;
pi=%pi;

//Definisce le TF
//Parametri forma canonica (Boost)
E=VoN-(L*s*Iload)/(1-D)^2;
J=Iload/(1-D)^2;
VCR=1/(1-D);
Le=L/(1-D)^2;

//parametri del filtro LPF
w0_ol=1/sqrt(Le*C);
f0_ol=w0_ol/(2*pi);
Q_ol=R(i)*sqrt(C/Le);
LPF=1/(1+s/(Q_ol*w0_ol)+(s/w0_ol)^2);

//Trovo la frequenza dei poli del LowPassFilter 
//attraverso gli zeri del polinomio del denominatore
roots_den=roots([(1/w0_ol)^2,1/(Q_ol*w0_ol) , 1]);
lpf_poles_freq=(-1/(2*pi))*roots_den;
lpf_poles_freq_mod=abs(lpf_poles_freq); //modulo, se complesi coniugati

//Gvg
Gvg0=VCR;
Gvg=Gvg0*LPF;
//Gvd
Gvd0=VoN*VCR;
Gvd=E*VCR*LPF;
//Zout
Zout=Le*s*LPF;
//Tu (uncompensated T)
Tu0=Hsensor*Gvd0*(1/VM);
Tu=Hsensor*Gvd*(1/VM);

// def sistemi lineari
LPF_s=syslin('c',LPF);
Gvg_s=syslin('c',Gvg);
Gvd_s=syslin('c',Gvd);
Zout_s=syslin('c',Zout);

scf(1);
bode(LPF_s,1e2,1e6)
title('Bode plot of LPF')


scf(2);
bode(Gvg_s,1e2,1e6)
title('Bode plot of Gvg')

scf(3);
bode(Gvd_s,1e2,1e6)
title('Bode plot of Gvd')

scf(4);
bode(Zout_s,1e2,1e6)
title('Bode plot of Zout')

