clc, clear, close all

mocap_data = readtable('D:\Downloads\wed-23-mocap.csv');
telemetry_data = readtable('D:\Downloads\wed-23-telemetry.csv');

% Check if the tables contain the expected columns
% the units are meters for the positions
% the units are meters per second squared for accelerations and whatever
% you found in lab for angular velocities :)

expectedCols1 = {'time', 'posx', 'posy', 'posz', 'attyaw', 'attpitch', 'attroll'};
if ~all(ismember(expectedCols1, mocap_data.Properties.VariableNames))
    error('CSV file does not contain the expected columns.');
end
expectedCols2 = {'time', 'rollrate', 'pitchrate', 'yawrate', 'accx', 'accy', 'accz'};
if ~all(ismember(expectedCols2, telemetry_data.Properties.VariableNames))
    error('CSV file does not contain the expected columns.');
end

% the data can be accessed typing data.[name of variable]
% for example mocap_data.posx returns the data corresponding to the position of
% the object along axis 1 of the mo-cap space
% the possible data labels are shown above in the expectedCols variable


% you are supposed to follow the instructions on the *updated* Lab2
% instructions document. 
% you might find useful functions like sum() and ypr_to_rotation(), which
% is provided to you

% For task 12
figure;
plot(telemetry_data.time, telemetry_data.accx, 'g-');
title("Acceleration in X Direction Vs Time");
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');
grid on;

figure;
plot(telemetry_data.time, telemetry_data.accy, 'r-');
title("Acceleration in Y Direction Vs Time");
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');
grid on;

figure;
plot(telemetry_data.time, telemetry_data.accz, 'y-');
title("Acceleration in Z Direction Vs Time");
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');
grid on;



%Calculating velocity 
vel_E = [];

for k = 1:(length(mocap_data.time)-1)
    p_k_E = [mocap_data.posx(k), mocap_data.posy(k), mocap_data.posz(k)];
    p_k1_E = [mocap_data.posx(k+1), mocap_data.posy(k+1), mocap_data.posz(k+1)];
    vel_E = [vel_E; mocap_data.time(k),(p_k1_E - p_k_E)/(mocap_data.time(k+1)-mocap_data.time(k))];
end

%Velocity Table
vel_E = array2table(vel_E,"VariableNames",{'time','vel_x','vel_y','vel_z'});

acc_B = [];
g = [0,0,-9.81];

for j = 1:(length(vel_E.time)-1)
    v_j_E = [vel_E.vel_x(j),vel_E.vel_y(j),vel_E.vel_z(j)];
    v_j1_E = [vel_E.vel_x(j+1),vel_E.vel_y(j+1),vel_E.vel_z(j+1)];
    acc_j_E = ((v_j1_E-v_j_E)/(vel_E.time(j+1)-vel_E.time(j)))-g;
    %Using the function from GSI to find the transformation matrix
    yaw_j = deg2rad(mocap_data.attyaw(j));
    pitch_j = deg2rad(mocap_data.attpitch(j));
    roll_j = deg2rad(mocap_data.attroll(j));
    [T_j_EB,T_j_BE] = ypr_to_rotation(yaw_j, pitch_j, roll_j);
    acc_B = [acc_B; (T_j_BE*(acc_j_E)')'];
end


N = 40;
% Smooth out the data by moving average

acc_B_smooth = zeros(size(acc_B,1)-N+1,3);
for a = 1:size(acc_B,1)-N+1
    acc_B_smooth(a,:) = (sum(acc_B(a:a+N-1,:),1))./N;
end

acc_B_smooth = [mocap_data.time(1:size(acc_B_smooth,1)),acc_B_smooth];
acc_B_smooth = array2table(acc_B_smooth, "VariableNames",{'time','acc_x','acc_y','acc_z'});

figure;
plot(telemetry_data.time, telemetry_data.accx, 'g-');
hold on;
plot(acc_B_smooth.time,acc_B_smooth.acc_x,'r-');
title("Acceleration in X Direction Vs Time");
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');
grid on;
hold off;

figure;
plot(telemetry_data.time, telemetry_data.accy, 'g-');
hold on;
plot(acc_B_smooth.time,acc_B_smooth.acc_y,'r-');
title("Acceleration in Y Direction Vs Time");
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');
grid on;
hold off;

figure;
plot(telemetry_data.time, telemetry_data.accz, 'g-');
hold on;
plot(acc_B_smooth.time,acc_B_smooth.acc_z,'r-');
grid on;
title("Acceleration in Z Direction Vs Time");
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');
grid on;
hold off;
