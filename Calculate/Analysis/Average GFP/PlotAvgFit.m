function [ mt_fit, gfp_fit ] = PlotAvgFit( AvgIm, varargin )
%PLOTAVGFIT Summary of this function goes here
%  varargin{1} specifies what background to add. 0-none, 1-only from fit (so still bg-subtracted image)
%                      2 - adds the original image's background too.

if numel(varargin) > 0
   addbg = varargin{1};
else
   addbg = 2;
end

global Config;

global xg yg;

[xg, yg] = meshgrid(1:size(AvgIm.mt.im,1));

% AvgIm.gfp.fit.w = (AvgIm.gfp.fit.w).^2 ./ 2.77258872223978;
% if ~strcmp(AvgIm.mt.model,'s')
%    AvgIm.mt.fit.w = (AvgIm.mt.fit.w).^2 ./ 2.77258872223978;
% end

mt_model = find_model(AvgIm.mt.model, convert_fitstruct_to_guess(AvgIm.mt.fit) );
mt_fit = evaluate( mt_model, convert_fitstruct_to_x(AvgIm.mt.fit));

gfp_model = find_model(AvgIm.gfp.model, convert_fitstruct_to_guess(AvgIm.gfp.fit) );
gfp_fit = evaluate( gfp_model, convert_fitstruct_to_x(AvgIm.gfp.fit));

if addbg > 0
   mt_fit = mt_fit + double(AvgIm.mt.fit.b);
   gfp_fit = gfp_fit + double(AvgIm.gfp.fit.b);
   if addbg > 1
      mt_fit = mt_fit + (AvgIm.mt.im - AvgIm.mt.im_nobg);
      gfp_fit = gfp_fit + (AvgIm.gfp.im - AvgIm.gfp.im_nobg);
   end
end


   function x = convert_fitstruct_to_x(fit)
      x = [fit.x(:).value', fit.o(:).value, fit.w(:).value', fit.h(:).value];
      
      if numel(fit.l(:).value) > 1
         x = [x, fit.l(:).value'];
      else
         x = [x fit.l(:).value];
      end
   end

   function guess = convert_fitstruct_to_guess(fit)
      guess.x = double(fit.x);
      guess.h = double(fit.h);
      guess.w = double(fit.w);
      guess.o = double(fit.o);
      guess.b = double(fit.b);
      try
         guess.lambda = double(fit.l(1));
         guess.mtLattice = double(fit.l(2));
         guess.l = double(fit.l);
      end
   end

   function fit_model = find_model(modelstr, guess)
      switch modelstr
         % point-like objects
         case 'p'
           fit_model = Model2DGaussSymmetric( guess );
         case 'b'
           fit_model = Model2DGaussStreched( guess );
         case 'r'
           fit_model = Model2DGaussPlusRing( guess );
         case 'f'
           fit_model = Model2DGaussPlus2Rings( guess );        
         case 'n'        
           fit_model = ModelNeg2DGaussPlusRing( guess ); 
         case 'c'
           fit_model = Model2DComet( guess );
         case 'u'
           fit_model = Model2DExponentiallyModifiedGaussian( guess );
         case 'a'
           fit_model = Model2DGaussStrechedAsymmetric( guess ); %gauss with lattice binding;

         % elongated objects
         case 'e'
           fit_model = Model2DFilamentEnd( guess );
         case 's'
           fit_model = Model2DFilamentEndGaussSurv( guess );
         case 'm'
   %         if strcmp( params.ridge_model, 'quadratic' )
           fit_model = Model2DFilamentMiddleBend( guess );
   %         else % fall back to linear model
   %           fit_model = Model2DFilamentMiddle( guess );
   %         end
         case 't'
           fit_model = Model2DShortFilament( guess );
         case 'v'
           fit_model = Model2DEMG_lattice( guess );

      end
   end

end

