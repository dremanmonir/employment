% Train Model, we are not seeking to deal with the features in order to improve the accuracy
%Fine Tree Model
tic;
[Model(1), validationAccuracy(1),validationPred{1}] = FineTree(PredictionTable_2022_Table);
ModelName(1) = "Fine Tree";
modeltime(1)= toc;% Train Model, we are not seeking to deal with the features in order to improve the accuracy
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

for i =1:1:20
    earn = sum(validationPred{i}(Response2022 =='buy')=='buy');
    lost = sum(validationPred{i}(Response2022 =='Not buy') == 'buy');
    gain = earn-lost;
   %Display the best model
   % figure;
  %  confmat=confusionmat(Response2022,validationPred{i});
  %  heatmap(Categ,Categ,confmat);
   % titlecnf=strcat(ModelName(i),'. Chances of Gain : ',num2str(earn/(earn+lost)*100),'%');
   % title(titlecnf);
  %  ylabel('True');
  %  xlabel('Prediction');
    ModelPrediction = Model(i);
    ModelNameFinal = ModelName(i);
    Model_Accuracy=validationAccuracy(i);
    Model_trainingTime = modeltime(i);
    % predict for first trading day of 2023 before stock market open
    predictionoutcome=ModelPrediction.predictFcn(PredictionTable_2023_Table(i,:)) ;   
   newresult(i,:) =  [ModelNameFinal  Model_Accuracy  Model_trainingTime];
    % save our result in result table
end

 

