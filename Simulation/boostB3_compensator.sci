//EPC 2025 - Progetto di un convertitore Boost
// Design compensatore

clear;
clc;
close(winsid());

exec('boostB2_m3.sci');
close(winsid());
clc;

fc=2900;  // [Hz] fc 1/100 di fsw

Tu_at_fc = repfreq(syslin('c',Tu), fc);

Tu_at_fc_modulo=abs(Tu_at_fc); // modulo di Tu a fc
teta_Tufc=angle(Tu_at_fc); // fase di Tu a fc

//Q_spec --> Q del sistema a loop chiuso, fc e Q definiscono la risposta 
//dinamica di Vo (rise time, overshoot, settling time)
//Q_spec = 0.8;  //Q di 1/(1+T) e T/(1+T)

//M_phi_spec = pi/2 +/- 10%
M_phi = 0.9*pi/2;
M_phi_gradi=M_phi*180/pi;

// Q =sqrt(cos(M_phi))/sin(M_phi)
// invertendo -> M_phi=atan(sqrt( (1+sqrt(1+4*Q_spec^4))/(2*Q_spec^4)))
// M_phi=atan(sqrt( (1+sqrt(1+4*Q_spec^4))/(2*Q_spec^4)));//[rad]
Q =sqrt(cos(M_phi))/sin(M_phi)

//M_phi= fase(T(fc))+pgrec = fase(Tu(fc))+fase(C(fc)+pgrec 
//Inverterndo [teta_Cfc] fase(C(fc)= M_phi - (pgrec+fase(Tu(fc)))
teta_Cfc= M_phi - (pi+teta_Tufc);

//fp ed fz t.c. il rapporto fp/fz sia il minimo necessario per ottenere 
//%il margine di fase desiderato, assumendo di centrare fc
//esattamente tra fp ed fz (media geometrica), ovvero fc=sqrt(fp*fz)
fz=fc*sqrt((1-sin(teta_Cfc))/(1+sin(teta_Cfc)));
fp=fc*sqrt((1+sin(teta_Cfc))/(1-sin(teta_Cfc)));
wz=2*pi*fz;
wp=2*pi*fp;

Gc0_pd=((1/Tu_at_fc_modulo)*fz/fc)

//Compensator P-D
Gc_PD=Gc0_pd*(1+s/wz)/(1+s/wp);

//Compensator P-I-D
//aggiungo un polo nell'origine e uno zero a 1/10 di fz
fzsx=fz;
wzsx=2*pi*fzsx;
Gc_PID= Gc_PD * (wzsx+s)/s * (wzsx+s)/s;

//Compensator I
//solo polo nell'origine
wa = Gc0_pd*wzsx
Gc_I= wa/s;

//sprova1=w0_ol;
//sprova2=w0_ol;
//sprova3=10e2;
//Gprova=[3/((1+s/sprova1)*(1+s/sprova2)*(1+s/sprova3))]

wib=190e-4; wzb=1e-3;
wpx1=0.9e2; wpx2=1e6;
//per il Q del compensatore metto Q=15 che va bene per entrambi i carichi
Qx=15;
Gcx=[(wib/s)*(1+s/wzb)*(1+s/(Qx*w0_ol)+(s/w0_ol)^2)/((1+s/wpx1)*(1+s/wpx2)^2)]

//SELEZIONARE QUALE Gc usare (PD o PID?)
//Gc=Gc_PD;
//Gc=Gc_PID;
//Gc=Gc_I;
Gc=Gcx;
//Gc=Gprova;

//Loop gain
T=Tu*Gc;

T_s=syslin('c',T);

//questo codice mi restituisce le frequenze a cui T taglia l'asse a 0dB
frequenze=logspace(-1,3,10000);                     //vettore di frequenze da analizzare
modul=zeros(1,length(frequenze));
for i=1:length(frequenze)
    jw=%i*frequenze(i);
    modul(i)=abs(horner(T,jw));
end
soglia=0.1;
indici=find(abs(modul-1)<soglia);
frequenze_taglio=frequenze(indici);
disp("frequenze a 0dB");
disp(frequenze_taglio);



//Stima errore a regime relativo con Controllore PD
//T0 = repfreq(syslin('c',T), 0); 
// NB: se ho lo zero nell'origine mi da errore, uso 10^(-9) invece di zero
T0 = repfreq(syslin('c',T), 1e-9); // 1 nHz

T0=abs(T0);
Errore_a_regime=1/(1+T0)
Offset_Vo=VoN*Errore_a_regime //V

//Verifica rumore @fsw dovuto al ripple di Vo in ingresso al PWM
NoisePWM_at_fsw=Vo_rip_spec*Hsensor*abs(repfreq(syslin('c',Gc_PD),fsw));
//assicurarsi che sia NoisePWM_at_fsw<<VM

Gvg_CL = Gvg/(1+T);

//Verifica spec di controllo @100Hz dovuto al ripple di Vi
Noise_rippleIN_at_100hz=abs(repfreq(syslin('c',Gvg_CL),100));
//assicurarsi che sia Noise_rippleIN_at_100hz<200m


scf(1);
bode(syslin('c',Gc),logspace(-6,6,1000));
title('Bode plot of compensator');

scf(2);
bode(syslin('c',Tu),1e2,1e6)
title('Bode plot of uncompensated T (Tu)');

scf(3);
bode(syslin('c',T),1e2,1e6)
title('Bode plot of compensated T');

scf(4);
bode(syslin('c',Gvg_CL),1e2,1e6)
title('Bode plot of Gvg_CL');


// verifico il margine di fase sulla T ottenuta 
// (ridotto a causa dell'ulteriore coppia polo-zero del PID)
M_phi_gradi_reale=p_margin(syslin('c',T));
disp('Margine di fase = '+string(M_phi_gradi_reale)+'°');

    disp('***** Da copiare in LT-SPICE ******')
if Gc==Gc_PD then
    disp('Campo value del genearatore controllato <e> che mima il compensatore:');
    disp('(Campo value di <e> ) Laplace=Gc0_pd*(1+s/wz)/(1+s/wp)');
    disp('Direttiva per definizione parametri:');
    disp('(Direttiva parametri) .param Gc0_pd='+string(Gc0_pd)+' wz='+string(wz)+' wp='+string(wp));
else  //allora è quella del PID
    disp('Campo value del genearatore controllato <e> che mima il compensatore:');
    disp('Laplace=Gc0_pd*(wzsx+s)*(1+s/wz)/((s+1e-9)*(1+s/wp))');
    disp('Direttiva per definizione parametri:');
    disp('.param Gc0_pd='+string(Gc0_pd)+' wzsx='+string(wzsx)+' wz='+string(wz)+' wp='+string(wp));
    disp('**** NB: LTspice non può simulare il transient di una FDT con polo in zero, la ');
    disp('****     risposta DC restituirebbe infinito, si usa quindi un polo a bassissime ');
    disp('****     frequenze con wp_integr = 1 nano rad/s  ****');
end
