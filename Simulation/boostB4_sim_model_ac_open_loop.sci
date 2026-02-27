//EPC 2025 - Progetto di un convertitore Boost
// Variabili per i modelli XCOS
clear;
clc;
close(winsid());

//Esegue script parte 2
exec('boostB2_m3.sci');
close(winsid());
clc;

//imposto parametri simulazione
Tsim=10e-3;
//impostare lo stesso valore numerico in 
// xcos -> simulazione -> configurazione -> tempo di integrazione finale 
// (non è parametrizzabile )
step_time=1e-4;
dt=5e-7;
N_vec=floor(Tsim/dt)+1


deltaVo_attesa=0.1;
// ***********************************************
// ********** PER SIMULAZIONE OPEN LOOP **********
// ***********************************************
//variazione a gradino del duty cycle
deltaD=deltaVo_attesa/Gvd0;

//gui mode
// xcos('boostB4_XCOS_mod_small_signal_open_loop.zcos')

//batch mode
importXcosDiagram('boostB4_XCOS_mod_small_signal_open_loop.zcos');
xcos_simulate(scs_m, 4);

close(winsid()); // chiudo e riplott ingresso e uscita

scf(1);

delta_min = part(%chars.greek.lower, 4)

subplot(2,1,1);
plot(ol_sim_dutycycle.time,ol_sim_dutycycle.values,'r','linewidth',2);
xlabel('time (s)','fontsize',4,'fontname','helvetica');
ylabel(delta_min+' d input','fontsize',4,'fontname','helvetica');

a=get("current_axes");//get the handle of the newly created axes
a.data_bounds=[0,0;Tsim,1.25*deltaD];
a.labels_font_size=3; a.labels_font_style=4;

subplot(2,1,2)
plot(ol_sim_vout.time,ol_sim_vout.values,'b','linewidth',2);
xlabel('time (s)','fontsize',4,'fontname','helvetica');
ylabel(delta_min+' vout response ','fontsize',4,'fontname','helvetica');

a=get("current_axes");//get the handle of the newly created axes
a.data_bounds=[0,0;Tsim,2*deltaVo_attesa];
a.labels_font_size=3; a.labels_font_style=4;
