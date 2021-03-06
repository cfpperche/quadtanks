
%% Script Quadruple Tanks for Nonminimum Phase

%% Initialize common model params
model_const_params

%% Nonminimun Phase Parameters
gamma1 = 0.3; % Parcela do fluxo da bomba 1 para o tq 1
gamma2 = gamma1; % Parcela do fluxo da bomba 2 para o tq 2

h30 = ((1-gamma2)*k2*u20/a3)^2/(2*g); %4.9 cm
h40 = ((1-gamma1)*k1*u10/a4)^2/(2*g); %4.9 cm

T1 = (A1/a1)*sqrt((2*h10)/g);
T2 = (A2/a2)*sqrt((2*h20)/g);
T3 = (A3/a3)*sqrt((2*h30)/g);
T4 = (A4/a4)*sqrt((2*h40)/g);

Ap = [-1/T1 0 A3/(A1*T3) 0; 0 -1/T2 0 A4/(A2*T4); 0 0 -1/T3 0; 0 0 0 -1/T4];
Bp = [gamma1*k1/A1 0; 0 gamma2*k2/A2; 0 (1-gamma2)*k2/A3; (1-gamma1)*k1/A4 0];
Cp = [kc 0 0 0; 0 kc 0 0];

% Gnonmin
Gnonmin = tf(ss(Ap,Bp,Cp,0));
% Zeros of Gnonmin
Gnonmin_z = zero(minreal(ss(Gnonmin)));
% Gnonmin RGA of Gnonmin(0)
Gnonmin_rga = evalfr(Gnonmin,0*i);
Gnonmin_rga = Gnonmin_rga.*transpose(inv(Gnonmin_rga));

[num dem]  = tfdata(Gnonmin);

gs_num11 = num{1,1};
gs_dem11 = dem{1,1};

gs_num12 = num{1,2};
gs_dem12 = dem{1,2};

gs_num21 = num{2,1};
gs_dem21 = dem{2,1};

gs_num22 = num{2,2};
gs_dem22 = dem{2,2};

%%

c1 = (T1*k1*kc)/A1;
c2 = (T2*k2*kc)/A2;

% numeradores fun��o G(s)
gs11_n = gamma1*c1;
gs12_n = (1-gamma2)*c1;
gs21_n = (1-gamma1)*c2;
gs22_n = gamma2*c2;

% encontra denominadores fun��o G(s)
syms s;
gs11 = expand(T1*s + 1);
coeff_gs11 = coeffs(gs11);
gs11_ds = double(coeff_gs11(2));
gs11_d = double(coeff_gs11(1));

gs12 = expand((T1*s + 1)*(T3*s + 1));
coeff_gs12 = coeffs(gs12);
gs12_ds2 = double(coeff_gs12(3));
gs12_ds = double(coeff_gs12(2));
gs12_d = double(coeff_gs12(1));

gs21 = expand((T2*s + 1)*(T4*s + 1));
coeff_gs21 = coeffs(gs21);
gs21_ds2 = double(coeff_gs21(3));
gs21_ds = double(coeff_gs21(2));
gs21_d = double(coeff_gs21(1));

gs22 = expand(T2*s + 1);
coeff_gs22 = coeffs(gs22);
gs22_ds = double(coeff_gs22(2));
gs22_d = double(coeff_gs22(1));

Gs11 = tf([gs11_n],[gs11_ds gs11_d]);
Gs12 = tf([gs12_n],[gs12_ds2 gs12_ds gs12_d]);
Gs21 = tf([gs21_n],[gs21_ds2 gs21_ds gs21_d]);
Gs22 = tf([gs22_n],[gs22_ds gs22_d]);

Gs = [Gs11 Gs12;Gs21 Gs22]

Poles = pole(Gs);
Zeros = zero(Gs);

%% Executa modelo em malha aberta
simOut = sim('quadtanks_model',simulation_time);
%% Parametros do modelo
%[Kc_gs11, Tau_gs11, Theta_gs11] = model_evaluate_params(U1t, Yt_gs11);
%[Kc_gs12, Tau_gs12, Theta_gs12] = model_evaluate_params(U1t, Yt_gs12);
%[Kc_gs21, Tau_gs21, Theta_gs21] = model_evaluate_params(U2t, Yt_gs21);
%[Kc_gs22, Tau_gs22, Theta_gs22] = model_evaluate_params(U2t, Yt_gs22);

%% Step response Nonminimum Phase
t = [-10:0.001:200];

% G12
figure
%subplot(2,1,2);
[GsY GsT] = step(Gnonmin(1,2),t);
plot(GsT,GsY,'b');
hold on
grid on
axis auto;
xLimits = get(gca,'XLim');  %# Get the range of the x axis
yLimits = get(gca,'YLim');  %# Get the range of the y axis
title(sprintf('Step response\nNonminimum Phase - G[12]'));
datacursormode on

StepY = heaviside(t);
plot(t,StepY,'r')

Kc = (GsY(end)-GsY(1))/(StepY(end)-StepY(1));

TauY = Kc*0.63;
TauI = find(GsY<=TauY);
[TauV TauI] = max(GsY(TauI));
TauX = GsT(TauI);

plot(xLimits(1:2),[TauY TauY],'k:') %horizontal line
plot([TauX TauX],yLimits(1:2),'k:') %vertical line

Str = strcat('Kc = ',num2str(Kc)); 
TextKc = text(xLimits(2), yLimits(2), Str, ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'top');
set(TextKc, 'FontSize', 12);


Str = strcat('Kc\times63% = ',num2str(TauY)); 
Text63Kc = text(xLimits(1), TauY, Str, ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'top');
set(Text63Kc, 'rotation', 90);
set(Text63Kc, 'FontSize', 12);

Str = strcat('\tau = ',num2str(TauX)); 
TextTau = text(TauX, yLimits(1)+0.3, Str, ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top');
set(TextTau, 'FontSize', 12);

% Estimate the 2nd deriv. by finite differences
ypp = diff(GsY,2);  
% Find the root using FZERO
t_infl = fzero(@(T) interp1(GsT(2:end-1),ypp,T,'linear','extrap'),0);
y_infl = interp1(GsT,GsY,t_infl,'linear');
plot(t_infl,y_infl,'k.','markers',15);

t_infl2 = GsT(max(find(GsT<=t_infl))-10);
y_infl2 = interp1(GsT,GsY,t_infl2,'linear');
plot(t_infl2,y_infl2,'k.','markers',12);

slope = (y_infl2-y_infl)/(t_infl2-t_infl);
b = y_infl-(slope*t_infl);

auxx = [0:0.001:60];
auxy = slope*auxx+b;
plot(auxx,auxy,'k');

CutX = -b/slope;
plot(CutX,0,'k.','markers',15);

Str = strcat('\theta = ',num2str(CutX)); 
TextTheta = text(CutX, 0, Str, ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top');
set(TextTheta, 'FontSize', 12);
% -------------------------------------------------------------------------
% G21
figure
%subplot(2,1,2);
[GsY GsT] = step(Gnonmin(2,1),t);
plot(GsT,GsY,'b');
hold on
grid on
axis auto;
xLimits = get(gca,'XLim');  %# Get the range of the x axis
yLimits = get(gca,'YLim');  %# Get the range of the y axis
title(sprintf('Step response\nNonminimum Phase - G[21]'));
datacursormode on

StepY = heaviside(t);
plot(t,StepY,'r')

Kc = (GsY(end)-GsY(1))/(StepY(end)-StepY(1));

TauY = Kc*0.63;
TauI = find(GsY<=TauY);
[TauV TauI] = max(GsY(TauI));
TauX = GsT(TauI);

plot(xLimits(1:2),[TauY TauY],'k:') %horizontal line
plot([TauX TauX],yLimits(1:2),'k:') %vertical line

Str = strcat('Kc = ',num2str(Kc)); 
TextKc = text(xLimits(2), yLimits(2), Str, ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'top');
set(TextKc, 'FontSize', 12);

Str = strcat('Kc\times63% = ',num2str(TauY)); 
Text63Kc = text(xLimits(1), TauY, Str, ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'top');
set(Text63Kc, 'rotation', 90);
set(Text63Kc, 'FontSize', 12);

Str = strcat('\tau = ',num2str(TauX)); 
TextTau = text(TauX, yLimits(1)+0.3, Str, ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top');
set(TextTau, 'FontSize', 12);

% Estimate the 2nd deriv. by finite differences
ypp = diff(GsY,2);  
% Find the root using FZERO
t_infl = fzero(@(T) interp1(GsT(2:end-1),ypp,T,'linear','extrap'),0);
y_infl = interp1(GsT,GsY,t_infl,'linear');
plot(t_infl,y_infl,'k.','markers',15);

t_infl2 = GsT(max(find(GsT<=t_infl))-10);
y_infl2 = interp1(GsT,GsY,t_infl2,'linear');
plot(t_infl2,y_infl2,'k.','markers',12);

slope = (y_infl2-y_infl)/(t_infl2-t_infl);
b = y_infl-(slope*t_infl);

auxx = [0:0.001:60];
auxy = slope*auxx+b;
plot(auxx,auxy,'k');

CutX = -b/slope;
plot(CutX,0,'k.','markers',15);

Str = strcat('\theta = ',num2str(CutX)); 
TextTheta = text(CutX, 0, Str, ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top');
set(TextTheta, 'FontSize', 12);

%%

Kc_gs12 = Kc;
Tau_gs12= TauX;
Theta_gs12 = CutX;

Kc_gs21 = Kc_gs12; 
Tau_gs21 = Tau_gs12;
Theta_gs21 = Theta_gs12;

%% Sintonia PID - M�todo IMC com atraso

%Controlador 1 G(s) 12
lambda1 = (Tau_gs12+Theta_gs12)/2;
[Kp1 Ti1 Td1] = tuning_imc_wdelay(Kc_gs12, Tau_gs12, Theta_gs12, lambda1, 'PI');

%Controlador 2 G(s) 21
lambda2 = (Tau_gs21+Theta_gs21)/2;
[Kp2 Ti2 Td2] = tuning_imc_wdelay(Kc_gs21, Tau_gs21, Theta_gs21, lambda2, 'PI');

%% Resultados
fprintf('------------- Fase N�o M�nima Dados G(s) -------------\n');
%fprintf('C1: %.5f\n', c1);
%fprintf('C2: %.5f\n', c2);
fprintf('gamma1: %.5f\n', gamma1);
fprintf('gamma2: %.5f\n', gamma2);
fprintf('Zeros: %.5f\n', Zeros);
fprintf('--------------------- Modelo G12 ---------------------\n');
fprintf('Kc: %.3f\n', Kc_gs12);
fprintf('Tau: %.3f\n', Tau_gs12);
fprintf('Theta: %.5f\n', Theta_gs12);
fprintf('--------------------- Modelo G21 ---------------------\n');
fprintf('Kc: %.3f\n', Kc_gs21);
fprintf('Tau: %.3f\n', Tau_gs21);
fprintf('Theta: %.5f\n', Theta_gs21);
fprintf('----------------- Controlador 1 IMC -----------------\n');
fprintf('Lambda: %.5f\n', lambda1);
fprintf('Kp: %.5f\n', Kp1);
fprintf('Ti: %.5f\n', Ti1);
fprintf('Td: %.5f\n', Td1);
fprintf('----------------- Controlador 1 IMC -----------------\n');
fprintf('Lambda: %.5f\n', lambda2);
fprintf('Kp: %.5f\n', Kp2);
fprintf('Ti: %.5f\n', Ti2);
fprintf('Td: %.5f\n', Td2);

%% Plot resposta em malha aberta para o modelo de fase minima
%{
figure
% G11
subplot(2,2,1);
plot(simOut,U1t);
hold on;
plot(simOut,Yt_gs11, 'k');
grid on;
xlabel('Time (ms)');
ylabel('Amplitude');
title(sprintf('Resposta modelo\nfase n�o m�nima G11'));
axis auto
datacursormode on
% G12
subplot(2,2,2);
plot(simOut,U1t);
hold on;
plot(simOut,Yt_gs12, 'k');
grid on;
xlabel('Time (ms)');
ylabel('Amplitude');
title(sprintf('Resposta modelo\nfase n�o m�nima G12'));
axis auto
datacursormode on
% G21
subplot(2,2,3);
plot(simOut,U2t);
hold on;
plot(simOut,Yt_gs21, 'k');
grid on;
xlabel('Time (ms)');
ylabel('Amplitude');
title(sprintf('Resposta modelo\nfase n�o m�nima G21'));
axis auto
datacursormode on
% G22
subplot(2,2,4);
plot(simOut,U2t);
hold on;
plot(simOut,Yt_gs22, 'k');
grid on;
xlabel('Time (ms)');
ylabel('Amplitude');
title(sprintf('Resposta modelo\nfase n�o m�nima G22'));
axis auto
datacursormode on
%}
