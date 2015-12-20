clear all;
clc;
%% Program code for AB1
% Find the electricity price given the conditions in the problem
%% Construct the hydro generation schedule
% Define the intervals for the hydro generation schedule
int1 = @(x) x>0 & x<=73;
int2 = @(x) x>73 & x<=151;
int3 = @(x) x>151 & x<=243;
int4 = @(x) x>243 & x<=365;

% Define the hydro generation schedule functions
landskraft = @(x) (((21-19)/(73)).*(x-1) + 19).*int1(x) + 21.*int2(x)...
                    + 21.*int3(x) ...
                    + (((22-21)/(365-243)).*(x-243) + 21).*int4(x);
bygdens = @(x) (((10-9)/(73)).*(x-1) + 9).*int1(x)...
                    + (((11-10)/(151-73)).*(x-73) + 10).*int2(x)...
                    + 11.*int3(x) ...
                    + (((12-11)/(365-243)).*(x-243) + 11).*int4(x);
stads = @(x) 6.*int1(x) + (((7-6)/(151-73)).*(x-73) + 6).*int2(x) ...
                    + 7.*int3(x) + 7.*int4(x);

%% Construct the nuclear generation schedule
% Define the intervals for the nuclear schedule

nuc_int1 = @(x) x>0 & x<=212;
nuc_int2 = @(x) x>212 & x<=365;

% Define the Nuclear generation schedule function
stralinge = @(x) 26.*nuc_int1(x) + 25.*nuc_int2(x);

%% Determine the demand for thermal power plants
x = 1:365;
hydro_agg = landskraft(x) + bygdens(x) + stads(x);
residual_demand = 80 - hydro_agg; % Subtract constant load by hydro

thermal_demand = residual_demand - stralinge(x);
plot(x, thermal_demand);
xlim([1 365])
ylim([0 max(thermal_demand)+1])

%% Determine the electricity price given the load demand
% Assume production varies linearly with the variable cost range
chp = [14 100 380];
cc = [9 360 420];
oil = [6 500 560];
gas = [1 800 900];

chp_int1 = @(x) x>100 & x<=380;
chp_int2 = @(x) x>380;
cc_int1 = @(x) x>360 & x<=420;
cc_int2 = @(x) x>420;
oil_int1 = @(x) x>500 & x<=560;
oil_int2 = @(x) x>560;
gas_int1 = @(x) x>800 & x<=900;
gas_int2 = @(x) x>900;

x=1:900;
thermal_agg = @(x) (chp(1)/(chp(3)-chp(2))).*(x-chp(2)).*chp_int1(x) +chp(1).*chp_int2(x)...
                    +(cc(1)/(cc(3)-cc(2))).*(x-cc(2)).*cc_int1(x) + cc(1).*cc_int2(x)...
                    +(oil(1)/(oil(3)-oil(2))).*(x-oil(2)).*oil_int1(x) + oil(1).*oil_int2(x)...
                    +(gas(1)/(gas(3)-gas(2))).*(x-gas(2)).*gas_int1(x) + gas(1).*gas_int2(x);

thermal_supply = thermal_agg(x);
price = zeros(1,365);
for i=1:length(thermal_demand)
    temp = thermal_demand(i) - thermal_supply;
    val = find(temp<0,1);
    price(i) =((thermal_demand(i)-thermal_supply(val-1))/(thermal_supply(val)-thermal_supply(val-1)))+(val-1);
end
x=1:365;
plotyy(x,price,x,thermal_demand);