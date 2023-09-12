% La Ilma Lana Illa Ma Allamtana. Wallahu Aalam Bisawab 

% Clear workspace
% clc
% clear all
% close all

%Minimum allowed soil moisture level
Moist_min = 0.15;
%Maximum allowed soil moisture level
Moist_max = 0.85;

%Initial soil moisture level (Initial condition)
Moist_ini = 0.5;

%Soil moisture decay rate (Depends on soil properties)
dec_rate1 = 0.095;
dec_rate2 = 0.04;
dec_rate3 = 0.06;
dec_rate4 = 0.07;

%step size (number of days in a sixteen weeks season = 119)
num_days = 7*17; 

%Moisture level from time t=1 till t=num_days
M1 = zeros(1,num_days);
M1(1) = Moist_ini;

M2 = zeros(1,num_days);
M2(1) = Moist_ini;

M3 = zeros(1,num_days);
M3(1) = Moist_ini;

M4 = zeros(1,num_days);
M4(1) = Moist_ini;

%Rain Input
rain_prob = 0.00;   
R = full(sprand(1,num_days,rain_prob));  % Generate sparse rain events with a uniform distribution  

% Irrigation Supply 
I_total = 3;
Inlet_size = 0.2;
water_delay = 21; 
I = zeros(1,num_days);
I(1) = I_total; 

% Yield 
Yield_max = 100;

ydecay_rate1 = 0.03;
ydecay_rate2 = 0.08;
ydecay_rate3 = 0.075;
ydecay_rate4 = 0.045;

Y1 = zeros(1,num_days);
Y2 = zeros(1,num_days);
Y3 = zeros(1,num_days);
Y4 = zeros(1,num_days);

Y1(1) = Yield_max;
Y2(1) = Yield_max;
Y3(1) = Yield_max;
Y4(1) = Yield_max;

%%%%%% GETTING READY TO PLOT %%%%%%%%% 
s = get(0, 'ScreenSize');
figure('Position', [0 0 s(3) s(4)]);
subplot(10,1,3); plot([1:num_days],Moist_min*ones(1,num_days),'.');
hold on
subplot(10,1,3); plot([1:num_days],Moist_max*ones(1,num_days),'.');
axis([1 num_days 0 1.2])

subplot(10,1,5); plot([1:num_days],Moist_min*ones(1,num_days),'.');
hold on
subplot(10,1,5); plot([1:num_days],Moist_max*ones(1,num_days),'.');
axis([1 num_days 0 1.2])

subplot(10,1,7); plot([1:num_days],Moist_min*ones(1,num_days),'.');
hold on
subplot(10,1,7); plot([1:num_days],Moist_max*ones(1,num_days),'.');
axis([1 num_days 0 1.2])

subplot(10,1,9); plot([1:num_days],Moist_min*ones(1,num_days),'.');
hold on
subplot(10,1,9); plot([1:num_days],Moist_max*ones(1,num_days),'.');
axis([1 num_days 0 1.2])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% MAIN SIMULATION FOR LOOP %%%%% 
for t = 1:1:num_days
    
    %%%% Soil moisture system update at step t+1      
    dec_moisture1 = M1(t)*dec_rate1;  %Decrease in moisture level in one day
    M1(t+1) = M1(t) - dec_moisture1 + R(t); %Moisture level at the next day
    
    dec_moisture2 = M2(t)*dec_rate2; 
    M2(t+1) = M2(t) - dec_moisture2 + R(t); 
    
    dec_moisture3 = M3(t)*dec_rate3; 
    M3(t+1) = M3(t) - dec_moisture3 + R(t);
    
    dec_moisture4 = M4(t)*dec_rate4; 
    M4(t+1) = M4(t) - dec_moisture4 + R(t);
    
    
    %%%%%%% Control action at time step t %%%%%%%%%%%%
    
    
    % task 2
    irrigated = false;
    
    %%%%% FIXED DELIVERY %%%%%: 
    
    if (t > 20) % so it doesn't deliver water before first irrigation day
        
        % farm 1 surface water delivery
        if (mod(t,water_delay) == 0 && I(t) > 0)
                water_input = min(Inlet_size, I(t));
                M1(t+1) = M1(t+1) + water_input;
                I(t+1) = I(t) - water_input; 

                irrigated = true;   
        end

        % farm 2 surface water delivery
        if (mod(t-1,water_delay) == 0 && I(t) > 0)
                water_input = min(Inlet_size, I(t));
                M2(t+1) = M2(t+1) + water_input;
                I(t+1) = I(t) - water_input;  

                irrigated = true;
        end

        % farm 3 surface water delivery
        if (mod(t-2,water_delay) == 0 && I(t) > 0)
                water_input = min(Inlet_size, I(t));
                M3(t+1) = M3(t+1) + water_input;
                I(t+1) = I(t) - water_input;  

                irrigated = true;
        end

        % farm 4 surface water delivery
        if (mod(t-3,water_delay) == 0 && I(t) > 0)
                water_input = min(Inlet_size, I(t));
                M4(t+1) = M4(t+1) + water_input;
                I(t+1) = I(t) - water_input;  

                irrigated = true;
        end
    end
    
    
    % to check if any surface water irrigation has been done
    if (irrigated == false)
        I(t+1) = I(t);
    end
    
    
    %%%%% GROUND WATER %%%%%: 
    
    % farm 1 ground water calculation
    if (M1(t) <= Moist_min || M1(t+1) <= Moist_min)
        
        % calculate days left till surface water arrives
        daysleft = 21 - mod(t, 21);
        
        % calculate how much water is needed to survive that many days
        required = M1(t);
        
        for a = 1:daysleft
            required = required / (1 - dec_rate1);
        end
        
        % add that much water to farm
        waterneeded = required - M1(t);
        M1(t+1) = M1(t+1) + waterneeded; 
    end
    
    % farm 2 ground water calculation
    if (M2(t) <= Moist_min || M2(t+1) <= Moist_min)
        
        % calculate days left till surface water arrives
        daysleft = 21 - mod(t-1, 21);
        
        % calculate how much water is needed to survive that many days
        required = M2(t);
        
        for a = 1:daysleft
            required = required / (1 - dec_rate2);
        end
        
        % add that much water to farm
        waterneeded = required - M2(t);
        M2(t+1) = M2(t+1) + waterneeded; 
    end
    
    % farm 3 ground water calculation
    if (M3(t) <= Moist_min || M3(t+1) <= Moist_min)
        
        % calculate days left till surface water arrives
        daysleft = 21 - mod(t-2, 21);
        
        % calculate how much water is needed to survive that many days
        required = M3(t);
        
        for a = 1:daysleft
            required = required / (1 - dec_rate3);
        end
        
        % add that much water to farm
        waterneeded = required - M3(t);
        M3(t+1) = M3(t+1) + waterneeded; 
    end

    % farm 4 ground water calculation
    if (M4(t) <= Moist_min || M4(t+1) <= Moist_min)
        
        % calculate days left till surface water arrives
        daysleft = 21 - mod(t-3, 21);
        
        % calculate how much water is needed to survive that many days
        required = M4(t);
        
        for a = 1:daysleft
            required = required / (1 - dec_rate4);
        end
        
        % add that much water to farm
        waterneeded = required - M4(t);
        M4(t+1) = M4(t+1) + waterneeded; 
    end


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%% Expected Yield update after every time step t+1 %%%%%%%% 
    if (M1(t) < Moist_min | M1(t) > Moist_max) 
        Y1(t+1) = Y1(t) - Y1(t)*ydecay_rate1;
    else 
        Y1(t+1) = Y1(t);
    end
    
    if (M2(t) < Moist_min | M2(t) > Moist_max) 
        Y2(t+1) = Y2(t) - Y2(t)*ydecay_rate2;
    else 
        Y2(t+1) = Y2(t);
    end
    
    if (M3(t) < Moist_min | M3(t) > Moist_max) 
        Y3(t+1) = Y3(t) - Y3(t)*ydecay_rate3;
    else 
        Y3(t+1) = Y3(t);
    end
    
    if (M4(t) < Moist_min | M4(t) > Moist_max) 
        Y4(t+1) = Y4(t) - Y4(t)*ydecay_rate4;
    else 
        Y4(t+1) = Y4(t);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

%%    
    %%%%% PLOTTING GRAPHS at time t 
    
    % rain and irrigation supply:
    subplot(10,1,1); plot(1:t,I(1:t),'bo-'); hold on;
    axis([1 num_days 0 I_total + 0.2])
    subplot(10,1,2); stem(1:t,R(1:t),'r'); hold on;
    axis([1 num_days 0 1.2])
    
    % farm 1:
    subplot(10,1,3); plot(1:t,M1(1:t),'*m-'); hold on;
    axis([1 num_days 0 1.2])
    subplot(10,1,4); plot(1:t,Y1(1:t),'*g-'); hold on;
    subplot(10,1,4); plot([1:num_days],Yield_max*ones(1,num_days),'g.');
    axis([1 num_days 0 Yield_max*1.2])
    
    % farm 2:
    subplot(10,1,5); plot(1:t,M2(1:t),'*m-'); hold on;
    axis([1 num_days 0 1.2])
    subplot(10,1,6); plot(1:t,Y2(1:t),'*g-'); hold on;
    subplot(10,1,6); plot([1:num_days],Yield_max*ones(1,num_days),'g.');
    axis([1 num_days 0 Yield_max*1.2])
    
    % farm 3:
    subplot(10,1,7); plot(1:t,M3(1:t),'*m-'); hold on;
    axis([1 num_days 0 1.2])
    subplot(10,1,8); plot(1:t,Y3(1:t),'*g-'); hold on;
    subplot(10,1,8); plot([1:num_days],Yield_max*ones(1,num_days),'g.');
    axis([1 num_days 0 Yield_max*1.2])
    
    % farm 4:
    subplot(10,1,9); plot(1:t,M4(1:t),'*m-'); hold on;
    axis([1 num_days 0 1.2])
    subplot(10,1,10); plot(1:t,Y4(1:t),'*g-'); hold on;
    subplot(10,1,10); plot([1:num_days],Yield_max*ones(1,num_days),'g.');
    axis([1 num_days 0 Yield_max*1.2])
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    pause(0.3);   % stalls the code before processing next t. Creates a video-like effect on figures
end
