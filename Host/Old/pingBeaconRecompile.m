function pingBeaconRecompile(pingBeaconPath, enableDebuggingRPi, rpi)

% Recompiles the ping beacon c code, located on the RPi. Set enableDebuggingRPi to 1 
% (ie. true) to turn on debuging, else set it to 0 (zero).
% pingBeaconPath is where the relevant files for firing the beacons are 
% stored on the RPi

if enableDebuggingRPi == 1
    recompileCommand = 'gcc -Wall -pthread -o pingBeacon pingBeacon.c -lpigpio -lrt -lm -DDEBUG=1';
elseif enableDebuggingRPi == 0
    recompileCommand = 'gcc -Wall -pthread -o pingBeacon pingBeacon.c -lpigpio -lrt -lm -DDEBUG=0';
else
    warning("-DDEBUG_ argument for RPi pingBeacon recompile is not valid. Must be 1 or 0");
end

value = system(rpi, strcat('cd',32,pingBeaconPath,';',recompileCommand));
            
if not(value)
    error("RPi ping beacon compile error. Command returned:");
    disp(value);
end

end