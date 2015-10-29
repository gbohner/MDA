 function set_children_callback(haxes, btndwnfcn)
      children = get(haxes, 'Children');
      for r1 = 1:numel(children)
         set(children(r1), 'ButtonDownFcn',btndwnfcn);
      end
 end

