function model_strings = ModelLibrary( type )
%MODELLIBRARY Summary of this function goes here
%   Detailed explanation goes here

if strcmp(type,'MT_end')
  model_strings{1} = 'Exponentially Modified Gaussian';
  model_strings{2} = 'Gaussian wall end';
  model_strings{3} = 'Gaussian error function';
elseif strcmp(type, 'GFP_end')
  model_strings{1} = 'Exponentially Modified Gaussian';
  model_strings{2} = 'Expenentially decaying wall';
  model_strings{3} = 'Stretched gaussian';
  model_strings{4} = 'Asymmetric stretched gaussian';
  model_strings{5} = 'Exp Mod Gauss with lattice binding';
else
  model_strings = {};
end

