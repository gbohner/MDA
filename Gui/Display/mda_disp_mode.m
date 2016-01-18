function mda_disp_mode( str )
%MDA_DISP_MODE Sets the current gui mode accordingly to the function
%   MDA_DISP_MODE changes the Gui.mode global variable and 
%   all the handle visibilities accordingly to the input
%
%   List of modes: 
%      {'tracking'}, 'averagegfp', 'flexalign'
%

global Config Gui

oldmode = Gui.mode;
Gui.mode = str;

%sets handle visibility according to current working mode of gui
  switch Gui.mode
    case 'none'
      mda_disp_set_none();
    case 'basic'
      mda_disp_set_basic();
    case 'tracking'
      mda_disp_set_tracking();
    case 'choosetracks'
      mda_disp_set_choosetracks();
    case 'averagegfp'
      mda_disp_set_averagegfp();
    case 'flexalign'
      mda_disp_set_flexalign();
    otherwise
      mda_disp_mode(oldmode);
      warning('MDA\Gui\mda_disp_mode.m had invalid input, and kept the previous mode settings');
  end
  
  function mda_disp_set_none()
    set(Gui.handles.left.panel,'Visible','off');
    set(Gui.handles.right.panel,'Visible','off');
    set(Gui.handles.middle.chbslider, 'Visible','off');
    set(Gui.handles.middle.chbthreshold, 'Visible','off');
    set(Gui.handles.middle.chbrect, 'Visible','off');
  end

 function mda_disp_set_basic()
    set(Gui.handles.left.panel,'Visible','on');
    set(Gui.handles.right.panel,'Visible','on');
    
    set(Gui.handles.left.popup, 'Visible','off');
    set(Gui.handles.left.axes, 'Visible','on');
    set(Gui.handles.left.slider, 'Visible','off');
    set(Gui.handles.left.slider_edit, 'Visible','off');
    set(Gui.handles.left.prev, 'Visible','off');
    set(Gui.handles.left.select, 'Visible','off');
    set(Gui.handles.left.next, 'Visible','off');
    set(Gui.handles.left.quit, 'Visible','off');
    
    set(Gui.handles.right.popup, 'Visible','off');
    set(Gui.handles.right.axes, 'Visible','on');
    set(Gui.handles.right.slider, 'Visible','off');
    set(Gui.handles.right.slider_edit, 'Visible','off');
    set(Gui.handles.right.slider2, 'Visible','off');
    set(Gui.handles.right.slider2_edit, 'Visible','off');
    set(Gui.handles.right.slider2_apply, 'Visible','off');
    set(Gui.handles.right.erase, 'Visible','off');

    
    set(Gui.handles.middle.chbslider, 'Visible','off');
    set(Gui.handles.middle.chbthreshold, 'Visible','off');
    set(Gui.handles.middle.chbrect, 'Visible','off');
    Gui.state.threshold = 0;
    Gui.state.slider_joint = 0;
    Gui.state.rect = 0;
    Gui.state.marking = 0;
    Gui.state.tracking = 0;
  end

  function mda_disp_set_tracking()
    set(Gui.handles.left.panel,'Visible','on');
    set(Gui.handles.right.panel,'Visible','on');
    
    set(Gui.handles.left.popup, 'Visible','on');
    set(Gui.handles.left.axes, 'Visible','on');
    set(Gui.handles.left.slider, 'Visible','on');
    set(Gui.handles.left.slider_edit, 'Visible','on');
    set(Gui.handles.left.prev, 'Visible','off');
    set(Gui.handles.left.select, 'Visible','off');
    set(Gui.handles.left.next, 'Visible','off');
    set(Gui.handles.left.quit, 'Visible','off');
    
    set(Gui.handles.right.popup, 'Visible','off');
    set(Gui.handles.right.axes, 'Visible','on');
    set(Gui.handles.right.slider, 'Visible','on');
    set(Gui.handles.right.slider_edit, 'Visible','on');
    set(Gui.handles.right.slider2, 'Visible','off');
    set(Gui.handles.right.slider2_edit, 'Visible','off');
    set(Gui.handles.right.slider2_apply, 'Visible','off');
    set(Gui.handles.right.erase, 'Visible','off');

    
    set(Gui.handles.middle.chbslider, 'Visible','on');
    set(Gui.handles.middle.chbthreshold, 'Visible','on');
    set(Gui.handles.middle.chbrect, 'Visible','on');
    Gui.state.threshold = 0;
    Gui.state.slider_joint = 1;
    Gui.state.rect = 0;
    Gui.state.marking = 0;
    Gui.state.tracking = 0;
  end

  function mda_disp_set_choosetracks()
    set(Gui.handles.left.panel,'Visible','on');
    set(Gui.handles.right.panel,'Visible','off');
    
    set(Gui.handles.left.popup, 'Visible','off');
    set(Gui.handles.left.axes, 'Visible','on');
    set(Gui.handles.left.slider, 'Visible','off');
    set(Gui.handles.left.slider_edit, 'Visible','off');
    set(Gui.handles.left.prev, 'Visible','off');
    set(Gui.handles.left.select, 'Visible','on');
    set(Gui.handles.left.next, 'Visible','on');
    set(Gui.handles.left.quit, 'Visible','on');
    
    set(Gui.handles.middle.chbslider, 'Visible','off');
    set(Gui.handles.middle.chbthreshold, 'Visible','off');
    set(Gui.handles.middle.chbrect, 'Visible','off');
    Gui.state.threshold = 0;
    Gui.state.slider_joint = 0;
    Gui.state.rect = 0;
    Gui.state.marking = 0;
    Gui.state.tracking = 0;
  end

  function mda_disp_set_averagegfp()
    set(Gui.handles.left.panel,'Visible','on');
    set(Gui.handles.right.panel,'Visible','on');
    
    set(Gui.handles.left.popup, 'Visible','off');
    set(Gui.handles.left.axes, 'Visible','on');
    set(Gui.handles.left.slider, 'Visible','off');
    set(Gui.handles.left.slider_edit, 'Visible','off');
    set(Gui.handles.left.prev, 'Visible','on');
    set(Gui.handles.left.select, 'Visible','on');
    set(Gui.handles.left.next, 'Visible','on');
    set(Gui.handles.left.quit, 'Visible','on');
    
    %TODO Need some plus checkboxes or radio buttons on the right
    set(Gui.handles.right.popup, 'Visible','on');
      argcell = {'Auto','Average MT', 'Average GFP', 'MT axial linescan', 'MT lateral linescan', ...
        'GFP axial linescan', 'GFP lateral linescan', 'MT-GFP axial linescan', 'MT-GFP lateral linescan'};
      set(Gui.handles.right.popup,'String',argcell);
    set(Gui.handles.right.axes, 'Visible','on');
    set(Gui.handles.right.slider, 'Visible','off');
    set(Gui.handles.right.slider_edit, 'Visible','off');
    set(Gui.handles.right.slider2, 'Visible','off');
    set(Gui.handles.right.slider2_edit, 'Visible','off');
    set(Gui.handles.right.slider2_apply, 'Visible','off');
    set(Gui.handles.right.erase, 'Visible','on');
    set(Gui.handles.right.editbox1, 'Visible','on');
    set(Gui.handles.right.editbox2, 'Visible','off');
    set(Gui.handles.right.editbox_label, 'Visible','on');
    
    set(Gui.handles.middle.chbslider, 'Visible','off');
    set(Gui.handles.middle.chbthreshold, 'Visible','off');
    set(Gui.handles.middle.chbrect, 'Visible','off');
    Gui.state.threshold = 0;
    Gui.state.slider_joint = 0;
    Gui.state.rect = 0;
    Gui.state.marking = 0;
    Gui.state.tracking = 0;
  end

  function mda_disp_set_flexalign()
    set(Gui.handles.left.panel,'Visible','on');
    set(Gui.handles.right.panel,'Visible','on');
    
    set(Gui.handles.left.popup, 'Visible','off');
    set(Gui.handles.left.axes, 'Visible','on');
    set(Gui.handles.left.slider, 'Visible','off');
    set(Gui.handles.left.slider_edit, 'Visible','off');
    set(Gui.handles.left.prev, 'Visible','off');
    set(Gui.handles.left.select, 'Visible','on');
    set(Gui.handles.left.next, 'Visible','on');
    set(Gui.handles.left.quit, 'Visible','on');
    
    %TODO Need some plus checkboxes or radio buttons on the right
    set(Gui.handles.right.popup, 'Visible','on');
      argcell = {'Average Pos+Int','Current Pos+Int', 'Current Slope+Int'};
      set(Gui.handles.right.popup,'String',argcell);
    set(Gui.handles.right.axes, 'Visible','on');
    set(Gui.handles.right.slider, 'Visible','off');
    set(Gui.handles.right.slider_edit, 'Visible','off');
    set(Gui.handles.right.slider2, 'Visible','off');
    set(Gui.handles.right.slider2_edit, 'Visible','off');
    set(Gui.handles.right.slider2_apply, 'Visible','off');
    set(Gui.handles.right.erase, 'Visible','on');
    set(Gui.handles.right.editbox1, 'Visible','off');
    set(Gui.handles.right.editbox2, 'Visible','off');
    set(Gui.handles.right.editbox_label, 'Visible','off');
    
    set(Gui.handles.middle.chbslider, 'Visible','off');
    set(Gui.handles.middle.chbthreshold, 'Visible','off');
    set(Gui.handles.middle.chbrect, 'Visible','off');
    Gui.state.threshold = 0;
    Gui.state.slider_joint = 0;
    Gui.state.rect = 0;
    Gui.state.marking = 0;
    Gui.state.tracking = 0;
  end

end

