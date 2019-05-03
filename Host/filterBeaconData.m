function [filteredBeaconDistances, filteredBeaconLocations, validLocalizationTx] = ...
    filterBeaconData(beaconErrorCodes,beaconDistances,beaconLocations)
% "squeezes" beacon data arrays down so that they only contain data from
% successful transmissions

filteredBeaconDistances(1) = 0;
filteredBeaconLocations(1,:) = [0,0];

validLocalizationTx = false;

j = 0;
for i = 1:length(beaconLocations)
   if beaconErrorCodes(i) == 0
       validLocalizationTx = true;
       j = j + 1;
       filteredBeaconDistances(j) = beaconDistances(i);
       filteredBeaconLocations(j,:) = beaconLocations(i,:);
   end
end