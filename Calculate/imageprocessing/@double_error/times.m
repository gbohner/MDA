function s = times( a, b )
%TIMES calculates the product of a and b

  a = double_error( a );
  b = double_error( b );
  s = double_error( double(a.value) .* double(b.value), ...
        abs( double(b.value) .* double(a.error) ) + ...
        abs( double(a.value) .* double(b.error) ) );
end