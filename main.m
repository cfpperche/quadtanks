close all; clear all; clc;
warning('off','all');
% Must be defined
simulation_time = 500;

% Para ver a resposta na fase minima
model_minimum_phase;
% Fun��o model_evalute_params est� com erro, precisa ser verificada
% definindo parametros do controladores manual mente
Kp1 = 0.87; Kp2 = Kp1;
Ti1 = 2.25; Ti2 = Ti1;
Td1 = 0; Td2 = Td1;
pid_minimum_phase;

% Para ver a resposta na fase n�o minima
model_nonminimum_phase;
% Fun��o model_evalute_params est� com erro, precisa ser verificada
% definindo parametros do controladores manual mente
Kp1 = 0.87; Kp2 = Kp1;
Ti1 = 2.25; Ti2 = Ti1;
Td1 = 0; Td2 = Td1;
pid_nonminimum_phase;