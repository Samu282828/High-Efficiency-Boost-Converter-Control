//EPC 2025 - Progetto di un convertitore Boost
//PAPER MODEL, Large Signal, Steady State, W.O. & W. Losses

clear;
clc;
close(winsid());

//SPEC "OPEN LOOP"
    ViN=10;  //[V]
    VoN=20;   //[V]
    R=[40,120];     //[ohm]
    fsw=500e3;  //[Hz]
    Tsw=1/fsw;  //[s]
    Vo_rip_spec = 0.01*VoN; //[V]
    
    i=2;     // seleziona il carico, quindi la corrente di uscita

// 0) calcolo D (duty cycle) "ideale" ed R di carico
    D=1-ViN/VoN;   //adimensionale
    Iload=VoN/R(i); //[Ohm]


// Impongo: delta_iL (ripple di iL)< 0.2*IL = 0.4A (NB. IL=IO=Iload)
    L_min=VoN*(1-D)*D*Tsw/(2*(0.4*Iload))  //[H]

// TOOL RICERCA INDUTTORI COILCRAFT: 
// https://www.coilcraft.com/apps/power_tools/power/

//L> 75 uH
// L_nom = 82  uH con RLESR=110 mohm (tolleranze del 10%)

    L=82E-6; //[H]
    RLESR=0.110;  //[Ohm]
    delta_iL =VoN*(1-D)*D*Tsw/(2*L) //[A]



//NB: delta_iL = Io_boundary (NB: se IO scende al di sotto IOB si va in DCM!)
//--> DCM per Iload < 30 mA
//--> CCM per Iload compresa tra 30 mA e ILoadMAX (0.5A, da specifica)

//Ripple di vout, valutato
//a) su C (assumendo RCESR nulla) 
//b) su RCESR (assumendo C infinita)
    C_min = VoN*D/(R(i)*fsw*Vo_rip_spec)
    RCESR_MAX = Vo_rip_spec/Iload

// TOOL RICERCA CONDENSATORI KEMET:
// http://ksim.kemet.com/  (tutte le tecnologie)
// http://ksim.kemet.com/Ceramic/CeramicCapSelection.aspx  (MLCC)

// C > C_min=2.5 uF (attenzione al derating con VDC)
// RCESR < RCESR_MAX = 400 mOhm


// Cnom = 10 uF 
// RCESR= 10 mOhm
    C=10E-6;  //[F] //valore a 20V
    RCESR=0.010; //[Ohm]

//Diodo --> Shottky per avere Vgamma piccole
// La caduta sul diodo in diretta è modellizzata come Vak=Vgamma+RonD*Id
// RD non è dichiarata esplicitamente sul datasheet, è stata stimata
// https://www.farnell.com/datasheets/112128.pdf

    Vgamma=[0.43, 0.31];   // 0.41V corrisponde a Iload=0.5A, quindi R=40ohm
    //Ron_D stimata dai grafici
    Ron_D=0.005;  //[Ohm]

// TOOL RICERCA POWER-MOSFET INFINEON:
// https://www.infineon.com/cms/en/product/power/mosfet/


// https://www.infineon.com/dgdl/Infineon-IRLML6344-DataSheet-v01_01-EN.pdf?fileId=5546d462533600a4015356689c44262c
// Ron= 63 mOhm @ Vgs=4.5V , Ciss = 270 pF, Coss = 32 pF, Crss = 21 pF;
    Ron_Mos= 0.063; //[Ohm]
  //assumiamo Vgs=4.5V
    Vgs_on=4.5;  //[V]
    Ciss_Mos = 270e-12;  //[F]
    Coss_Mos = 32e-12;  //[F]
    Crss_Mos = 21e-12;  //[F]
    
    Cgd=Crss_Mos;
    Cds=Coss_Mos-Cgd;
    Cgs=Ciss_Mos-Cgd;

    
//Quale D usare per VoN/ViN = 2 (ovvero Vout=20V per Vin=10V) se considero le perdite?
D_with_losses= (1 + (RLESR+Ron_D)/R(i) + (Vgamma(i)-ViN)/VoN)/(1 + Vgamma(i)/VoN + (Ron_D-Ron_Mos)/R(i));
    
    
    
//Stima Ploss
    //switching losses
Ploss_M_sw= fsw * (Cgs*Vgs_on^2 + Cds*VoN^2 + Cgd*(VoN+Vgs_on)^2)
Ploss_M_drv= fsw * (Cgs*Vgs_on^2 + Cgd*(VoN+Vgs_on)^2)

    //conduction losses
Ploss_M = (D_with_losses/(1-D_with_losses)^2)*Ron_Mos*Iload^2     //[W]
Ploss_D = (1-D_with_losses)*(Ron_D*Iload^2 + Vgamma(i)*Iload)    //[W]
Ploss_L = (RLESR*Iload^2)/(1-D_with_losses)^2         //[W]
Ploss_C = (RCESR*Iload^2)*(D_with_losses/(1-D_with_losses))  //[W] approssimato (IRMS)

Ploss_tot = Ploss_M_sw + Ploss_M + Ploss_D + Ploss_L + Ploss_C  //[W]
Pout= VoN*Iload;  //[W]
Pin=Ploss_tot+Pout; // [W]
Efficiency= Pout/Pin  //adimensionale

//grafico a torta
loss_contribution=[Ploss_L,Ploss_C,Ploss_D,Ploss_M_sw,Ploss_M]./Ploss_tot;
pie(loss_contribution,['Inductor','Capacitor','Diode','MOSFET switching','MOSFET conduction']);
legend(['Inductor','Capacitor','Diode','MOSFET switching','MOSFET conduction'],4)


//PWM e Sensore
VM=1;
Vref=2; // [V] 
Hsensor=Vref/VoN;

    disp('***** Da copiare in LT-SPICE ******')
    disp('Direttiva per definizione parametri:');
    disp('(Direttiva parametri) .param ViN='+string(ViN)+' R='+string(R)+' C='+string(C)+' RCESR='+string(RCESR)+' L='+string(L)+' RLESR='+string(RLESR)+' VM='+string(VM)+' Vgs_on='+string(Vgs_on)+' Tsw='+string(Tsw)+' Hsensor='+string(Hsensor)+' Vref='+string(Vref)+' D='+string(D));

