function model_char = GetModelChar(model)

switch model
  case 'Gaussian wall end'
    model_char = 'e';
  case 'Exponentially Modified Gaussian'
    model_char = 'u';
  case 'Gaussian error function'
    model_char = 's';
  case 'Expenentially decaying wall'
    model_char = 'c';
  case 'Stretched gaussian'
    model_char = 'b';
  case 'Asymmetric stretched gaussian'
    model_char = 'a';
  case 'Exp Mod Gauss with lattice binding'
    model_char = 'v';
  otherwise
    model_char = '';
end

end
