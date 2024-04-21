clc;
clear;
parallelcomputing = false; %true is on %false is off
if parallelcomputing ==true
    parpool(4);
else
    delete(gcp('nocreate'))
end
StockData = readtable('5099.KL.csv','ReadVariableNames',true);    
%Ensure the data is in correct data type
if isnumeric(StockData.Open) == false
    Open =cellfun(@str2double,StockData.Open);
    High = cellfun(@str2double,StockData.High);
    Low = cellfun(@str2double,StockData.Low);
    Close = cellfun(@str2double,StockData.Close);
    AdjustedClose = cellfun(@str2double,StockData.AdjClose);
    Volume = cellfun(@str2double,StockData.Volume);
else
    Open = StockData.Open;
    High = StockData.High;
    Low = StockData.Low;
    Close = StockData.Close;
    AdjustedClose = StockData.AdjClose;
    Volume =  StockData.Volume;
end
Date = StockData.Date;
%Tranform the data to timetable
StockData_TimeTable = timetable(Date,Open,High,Low,Close,Volume);
StockData_TimeTable = sortrows(StockData_TimeTable) ;
%Check for missing Data
%Fill the missing data with linear
if any(any(ismissing(StockData_TimeTable)))==true
    StockData_TimeTable = fillmissing(StockData_TimeTable,'linear');
end

%Delete the row if volume is 0
StockData_TimeTable(StockData_TimeTable.Volume==0,:) =[];

%View the data
figure;
plot(StockData_TimeTable.Date,StockData_TimeTable.Close);
title('Car Inventory Price Stock Prediction from Jul2018 to Jul2023');
ylabel('SGD');
xlabel('Timeline');
grid on

%Extract Technical Indicators
%Relative Strength Index 1st-3th Features
rsi7 = rsindex(StockData_TimeTable.Close,'WindowSize',7);
rsi14 = rsindex(StockData_TimeTable.Close,'WindowSize',14);
rsi21 = rsindex(StockData_TimeTable.Close,'WindowSize',21);
%Moving Average 3th - 6th Features
EMA3 = movavg(StockData_TimeTable.Close,'linear',3);
EMA5 = movavg(StockData_TimeTable.Close,'linear',5);
EMA10 = movavg(StockData_TimeTable.Close,'linear',10);
%Exponential Moving Average 7 Feature
EXPMOV7 = movavg(StockData_TimeTable.Close,'exponential',7);
%Moving Average Convergent/Divergent 8-9th Features
[MACDLine, signalLine]= macd(StockData_TimeTable.Close);
%Negative Volume Index 10th Features
NVIind = negvolidx(StockData_TimeTable);
%Positive Volume Index 11th Features
PosVind = posvolidx(StockData_TimeTable);
%Accumulation/Distribution OSciallator 12th Features
ADOsc = adosc(StockData_TimeTable);
%Time Series Bollinger band 13-15 Features
[middle,upper,lower] = bollinger(StockData_TimeTable);
%Highest high 16 Features
highind = hhigh(StockData_TimeTable) ;
%Lowest low 17 Features
lowind = llow(StockData_TimeTable);
%Median Price 18 Features
MedIdx = medprice(StockData_TimeTable);
%on-balance volume 19 Features
volumeIdx = onbalvol(StockData_TimeTable);
%Price and Volume Trend(PVT) 20 Features
pvtInd = pvtrend(StockData_TimeTable); 
%williams Accumulation/Distribution line 21 Features
willadidx = willad(StockData_TimeTable);
%Ticket Return Series 22 Features
tick2retidx = tick2ret(StockData_TimeTable);
%Chaikin Volatility 23
volatility = chaikvolat(StockData_TimeTable);
%Stochastic Oscillator 24
percentKnD = stochosc(StockData_TimeTable);
%Acceleration between times 25
acceleration = tsaccel(StockData_TimeTable);
%Momentum between times 26
momentum = tsmom(StockData_TimeTable);

%As explained, price today will be used to predict the stock price tomorrow. Hence all the indicators move forward 1 date.
% Only Open price of stock will be considered as feature as it is the only price we know before opening market in the day.
% 1st data point will be removed as there does not have any value for their feature indicators.
PredictionTable = timetable(StockData_TimeTable.Date(2:end),rsi7(1:end-1),rsi14(1:end-1),rsi21(1:end-1),...
    EMA3(1:end-1),EMA5(1:end-1),EMA10(1:end-1),EXPMOV7(1:end-1),MACDLine(1:end-1),signalLine(1:end-1),NVIind.NegativeVolume(1:end-1),PosVind.PositiveVolume(1:end-1),ADOsc.ADOscillator(1:end-1),...
    middle.Open(1:end-1),upper.Open(1:end-1),lower.Open(1:end-1),highind.HighestHigh(1:end-1),...
    lowind.LowestLow(1:end-1),MedIdx.MedianPrice(1:end-1),pvtInd.PriceVolumeTrend(1:end-1),...
    volumeIdx.OnBalanceVolume(1:end-1), willadidx.WillAD(1:end-1), tick2retidx.Open(1:end),...
    volatility.ChaikinVolatility(1:end-1),percentKnD.FastPercentK(1:end-1),acceleration.Open(1:end-1),...
    momentum.Open(1:end-1),StockData_TimeTable.Open(2:end));

% get Year 2023 data out for training
tr = timerange('2022-01-01' , '2022-12-31');
PredictionTable_2022 = PredictionTable(PredictionTable.Time(tr),:);

% get 2H Year 2017 data out for prediction
tr = timerange('2023-01-01' , '2023-12-31');
PredictionTable_2023 = PredictionTable(PredictionTable.Time(tr),:);

% Deal with missing data
PredictionTable_2022(any(ismissing(PredictionTable_2022),2),:)=[];
PredictionTable_2023(any(ismissing(PredictionTable_2023),2),:)=[];

% Get the Open and Close Price Data for year 2023 & 2017
OpenClose_2022 = StockData_TimeTable(PredictionTable_2022.Time,:);
OpenClose_2023 = StockData_TimeTable(PredictionTable_2023.Time,:);

% In this strategy, it consider worth to buy the stock or not if we buy the stock at market open rate and sell out at the end of the day
% We does not know the close rate, but we will know the open rate before prediction.
% if the close rate higher than open rate more than 1%, then we classify it as 'buy' in our original data.

for i =1:height(OpenClose_2022)
if OpenClose_2022.Open(i)*1.01 < OpenClose_2022.Close(i)
    Response2022(i)="buy";
else 
    Response2022(i)="Not buy";
end
end

Response2022=categorical(Response2022);
Categ=categories(Response2022);

nnz(Response2022=="buy");
nnz(Response2022=="Not buy");
for i =1:height(OpenClose_2023)
if OpenClose_2023.Open(i)*1.01 < OpenClose_2023.Close(i)
    Response2023(i)="buy";
else 
    Response2023(i)="Not buy";
end
end

Response2023=categorical(Response2023);
categories(Response2023);
nnz(Response2023=="buy");
nnz(Response2023=="Not buy");



PredictionTable_2022 = normalize(PredictionTable_2022);
PredictionTable_2023 = normalize(PredictionTable_2023);
%add path to folder consisting modelling code
currentdirectory = pwd;
fileread=strcat(currentdirectory,'\models');
addpath(fileread);

% Convert Timestable to table
PredictionTable_2022_Table = timetable2table(PredictionTable_2022);
PredictionTable_2022_Table.Response=Response2022';
PredictionTable_2023_Table = timetable2table(PredictionTable_2023);
PredictionTable_2023_Table.Response=Response2023';

% Train Model, we are not seeking to deal with the features in order to improve the accuracy
%Fine Tree Model
tic;
[Model(1), validationAccuracy(1),validationPred{1}] = FineTree(PredictionTable_2022_Table);
ModelName(1) = "Fine Tree";
modeltime(1)= toc;
%Medium Tree Model
tic;
[Model(2), validationAccuracy(2),validationPred{2}] = MediumTree(PredictionTable_2022_Table);
ModelName(2) = "Medium Tree";
modeltime(2)= toc;

%Course Tree Model
tic;
[Model(3), validationAccuracy(3),validationPred{3}] = CourseTree(PredictionTable_2022_Table);
ModelName(3) = "Course Tree";
modeltime(3)= toc;

%Linear Discriminant Model
tic;
[Model(4), validationAccuracy(4),validationPred{4}] = LinearDiscriminant(PredictionTable_2022_Table);
ModelName(4) = "Linear Discriminant";
modeltime(4)= toc;

%Linear SVM
tic;
[Model(5), validationAccuracy(5),validationPred{5}] = LinearSVM(PredictionTable_2022_Table);
ModelName(5) = "Linear SVM";
modeltime(5)= toc;

%Quadratic SVM
tic;
[Model(6), validationAccuracy(6),validationPred{6}] = QuadraticSVM(PredictionTable_2022_Table);
ModelName(6) = "Quadratic SVM";
modeltime(6)= toc;

%Cubic SVM
tic;
[Model(7), validationAccuracy(7),validationPred{7}] = CubicSVM(PredictionTable_2022_Table);
ModelName(7) = "Cubic SVM";
modeltime(7)= toc;

%Fine Gaussian SVM
tic;
[Model(8), validationAccuracy(8),validationPred{8}] = FineGaussianSVM(PredictionTable_2022_Table);
ModelName(8) = "Fine Gaussian SVM";
modeltime(8)= toc;

%Medium Gaussian SVM
tic;
[Model(9), validationAccuracy(9),validationPred{9}] = MediumGaussianSVM(PredictionTable_2022_Table);
ModelName(9) = "Medium Gaussian SVM";
modeltime(9)= toc;

%Course Gaussian SVM
tic;
[Model(10), validationAccuracy(10),validationPred{10}] = CourseGaussianSVM(PredictionTable_2022_Table);
ModelName(10) = "Course Gaussian SVM";
modeltime(10)= toc;

%Fine KNN
tic;
[Model(11), validationAccuracy(11),validationPred{11}] = FineKNN(PredictionTable_2022_Table);
ModelName(11) = "Fine KNN";
modeltime(11)= toc;

%Medium KNN
tic;
[Model(12), validationAccuracy(12),validationPred{12}] = MediumKNN(PredictionTable_2022_Table);
ModelName(12) = "Medium KNN";
modeltime(12)= toc;

%Coarse KNN
tic;
[Model(13), validationAccuracy(13),validationPred{13}] = CoarseKNN(PredictionTable_2022_Table);
ModelName(13) = "Course KNN";
modeltime(13)= toc;

%Cosine KNN
tic;
[Model(14), validationAccuracy(14),validationPred{14}] = CosineKNN(PredictionTable_2022_Table);
ModelName(14) = "Cosine KNN";
modeltime(14)= toc;

%Cubic KNN
tic;
[Model(15), validationAccuracy(15),validationPred{15}] = CubicKNN(PredictionTable_2022_Table);
ModelName(15) = "Cubic KNN";
modeltime(15)= toc;

%Weighted KNN
tic;
[Model(16), validationAccuracy(16),validationPred{16}] = WeightedKNN(PredictionTable_2022_Table);
ModelName(16) = "Weighted KNN";
modeltime(16)= toc;

%Ensemble Boosted KNN
tic;
[Model(17), validationAccuracy(17),validationPred{17}] = EnsembleBoostedTree(PredictionTable_2022_Table);
ModelName(17) = "Ensemble Boosted Tree";
modeltime(17)= toc;

%Ensemble Bagged KNN
tic;
[Model(18), validationAccuracy(18),validationPred{18}] = EnsembleSubspaceDiscriminant(PredictionTable_2022_Table);
ModelName(18) = "Ensemble Subspace Discriminant";
modeltime(18)= toc;

%Ensemble Subspace KNN
tic;
[Model(19), validationAccuracy(19),validationPred{19}] = EnsembleSubspaceKNN(PredictionTable_2022_Table);
ModelName(19) = "Ensemble Subspace KNN";
modeltime(19)= toc;

%Ensemble RUSBoosted Trees KNN
tic;
[Model(20), validationAccuracy(20),validationPred{20}] = EnsembleRUSBoostedTrees(PredictionTable_2022_Table);
ModelName(20) = "Ensemble RUS Boosted Trees";
modeltime(20)= toc;


BestModelNo = 1;
for i =1:1:20
   
    earn = sum(validationPred{i}(Response2022 =='buy')=='buy');
    lost = sum(validationPred{i}(Response2022 =='Not buy') == 'buy');
    gain = earn-lost;
   %Display the best model
    figure;
    confmat=confusionmat(Response2022,validationPred{i});
    heatmap(Categ,Categ,confmat);
    titlecnf=strcat(ModelName(i),'. Chances of Gain : ',num2str(earn/(earn+lost)*100),'%');
    title(titlecnf);
    ylabel('True');
    xlabel('Prediction');
    ModelPrediction = Model(i);
    ModelNameFinal = ModelName(i);
    Model_Accuracy=validationAccuracy(i);
    Model_trainingTime = modeltime(i);
    % predict for first trading day of 2023 before stock market open
    predictionoutcome=ModelPrediction.predictFcn(PredictionTable_2023_Table(i,:)) ;   
   result(i,:) = table(OpenClose_2023.Date(1),OpenClose_2023.Open(i),OpenClose_2023.Close(i),Response2023(i), predictionoutcome,ModelNameFinal,Model_Accuracy, Model_trainingTime);
    % save our result in result table
end
% Result
display(result);

