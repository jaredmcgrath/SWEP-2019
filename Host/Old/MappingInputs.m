function [Wl, Wr] = MappingInputs(Wl, Wr, leftInputSlope, leftInputIntercept, rightInputSlope, rightInputIntercept)
%this cycle maps the inputs so they can be sent to arduino

Wr = rightInputSlope*Wr + sign(Wr)*rightInputIntercept;
Wl = leftInputSlope*Wl + sign(Wl)*leftInputIntercept;

if abs(Wr) > 255
    Wr = 255*sign(Wr);
elseif abs(Wr) <= 100
    Wr = 0;
end

Wr = round(Wr);

if abs(Wl) > 255
    Wl = 255*sign(Wl);
    elseif abs(Wl) <= 100
    Wl = 0;
end

Wl = round(Wl);

end 
