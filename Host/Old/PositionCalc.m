function [positionEstimation, errorCovMat] = PositionCalc(botTagLower, ...
    beaconLocations, errorCovMat, XbeeSerial, rpi, localizeThisIteration, ...
    beaconGPIO, pingBeaconPath, pingBeaconDelay, debug, oldPosition)
% Args
    % botTagLower
    % beaconLocations - an array of beacon locations [x1,y1;x2,y2,...]
    % errorCovMat - error covariance matrix used in EKF
    % XbeeSerial
    % rpi
    % localizeThisIteration
    % beaconGPIO
    % pingBeaconPath - path to relevant files on the RPi
    % pingBeaconDelay
    

%% Get data from bot
% If we would like to localize this loop, localizeThisIteration will be true.
% Else, EKF uses dead reckoning
if (localizeThisIteration)
    if (debug)
        disp("Localizing");
    end
    
    %write the character 'P' to the robots, 3 times to ensure that all of
    %the robots enter the localization loop
    fopen(XbeeSerial);
    fwrite(XbeeSerial, 'P');
    fwrite(XbeeSerial, 'P');
    fwrite(XbeeSerial, 'P');
    fclose(XbeeSerial);
    %wait to have the loops start on the robots, this can potentially be
    %reduced if more testing finds it is able to do this
    pause(0.2);
    
    if (debug)
        fprintf("Pinging beacon:\n");
    end
    
    %ping each becaon so that each robot can collect a distance measurement
    %for that beacon
    for i = 1:length(beaconGPIO)
        if (debug)
            fprintf("                %d",i);
        end
        tic;
        start = toc;
        pingBeacon(rpi, beaconGPIO, i, pingBeaconPath);
        stop = toc;
        if (debug)
            fprintf(" (took %f sec)\n", stop-start);
        end
        if (pingBeaconDelay-(stop-start)) < 0
            error("Ping beacon took a while to run. Consider increasing pingBeaconDelay");
        end
        pause(pingBeaconDelay-(stop-start));
    end
    if (debug)
        fprintf("Pinging beacons complete\n");
    end
    %get all of the data gathered from the pinging of the beacons (x, y,
    %theta, error codes, and distances)
    [positionPrediction,beaconErrorCodes,beaconDistances] = getAllDataXbee(botTagLower, XbeeSerial);
    if (debug)
        disp("Beacon distances: ");
        disp(beaconDistances);
        disp("Beacon error codes: ");
        disp(beaconErrorCodes);
    end
else
    if (debug)
        disp("Using dead reckoning");
    end
    %get all of the information from the bots without the beacon pinging
    %(x, y, and theta)
    positionPrediction = getSensorsXbee(botTagLower, XbeeSerial);
end


if (debug)
    disp("Position prediction: ");
    disp(positionPrediction);
end
%this can be removed, it is included to be able to see the beacon distances
%after they are gathered by the bots
pause(4);

% Convert from mm to m, since distances are communicated as ints in mm
beaconDistances = beaconDistances/1000;     % Convert from mm to m
%% Estimate new position using EKF
% Only feed the EKF the transmissions which were successful
% Loop through each bot
for i = 1:length(botTagLower)
    [filteredBeaconDistances(i,:), filteredBeaconLocations(:,:,i), validLocalizationTx] = ...
        filterBeaconData(beaconErrorCodes(i,:),beaconDistances(i,:),beaconLocations(:,:,i));

    [errorCovMat, positionEstimation] = EKF(positionPrediction(i,:), oldPosition(i,:), ...
        filteredBeaconDistances(i,:), filteredBeaconLocations(:,:,i), errorCovMat(:,:,i), ...
        validLocalizationTx);
    
    if (debug)
        disp("errorCovMat:")
        disp(errorCovMat(:,:,i));
    end

    % Reset flag
    validLocalizationTx = false;                                                                    
end


end

