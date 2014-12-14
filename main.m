close all; clear all; clc;
warning('off','all');

%% EXEMPLO MATLAB HELP REFERENCIA
% http://www.mathworks.com/help/control/examples/temperature-control-in-a-heat-exchanger.html#zmw57dd0e6207
% -----------------------------------

%% Must be defined

% Tempo de simula��o
simulation_time = 300;

% Valores para entrada Ut1 (Step 1)
ut1_step_time = 50;
ut1_initial_value = 0;
ut1_final_value = 1;
ut1_sample_time = 0; %Precis�o da amostra, influencia nos gr�ficos

% Valores para entrada Ut2 (Step 2)
ut2_step_time = 50;
ut2_initial_value = 0;
ut2_final_value = 1;
ut2_sample_time = 0; %Precis�o da amostra, influencia nos gr�ficos

%% Para ver a resposta na fase minima
model_minimum_phase;
% Fun��o model_evalute_params est� com erro, precisa ser verificada
% definindo parametros do controladores manual mente
Kp1 = 0.87; Kp2 = Kp1;
Ti1 = 2.25; Ti2 = Ti1;
Td1 = 0; Td2 = Td1;
pid_minimum_phase;

%% Para ver a resposta na fase n�o minima
model_nonminimum_phase;
% Fun��o model_evalute_params est� com erro, precisa ser verificada
% definindo parametros do controladores manual mente
Kp1 = 0.78; Kp2 = Kp1;
Ti1 = 2.25; Ti2 = Ti1;
Td1 = 0; Td2 = Td1;
pid_nonminimum_phase;