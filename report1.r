#1. What a rule is  interesting? definition based on available rule parameters
# e.g. a rule is interesting if it has support > threshold and contains 'k' in consequent

#2. how to choose the best rule(s)
#e.g. the greatest the support the  better

#3.what is a potential practical application of the discovered rules?
# no clues about that

# Task1 Discovering rules for different values of minimum support - added (to review)
# Task2 Assessment of discovered rules with the lift parameter less than 1 and greater than 1 ... - not yed done
# Task3 Comparison of the average confidence value of "short" rules and "long" rules - not yet done

library(arules) # association rules
library(arulesViz) # visualization of rules

our_support = 0.2
our_confidence = 0.8
our_lift = 1.2
our_interest_measure = 0.01

download.file('http://staff.ii.pw.edu.pl/~gprotazi/dydaktyka/dane/supermarket.csv','supermarket.csv')
marketSet = read.csv('supermarket.csv',sep=';')
marketSet = as.data.frame(sapply(marketSet, function(x) as.logical(x)))
summary(marketSet);
head(marketSet);
# Make into transactional data
marketTR <- as(marketSet, "transactions");
freqTbl = itemFrequency(marketTR, type = "relative");
freqTbl = sort(freqTbl, decreasing = TRUE);


#number of elements with support >= 20%


length(freqTbl[freqTbl>=our_support]);


#chart of that data
itemFrequencyPlot(marketTR, type ="relative", support= our_support);

aParam  = new("APparameter", "confidence" = our_confidence, "support" = our_support, "minlen"= 1, "target" = "frequent itemsets");
#frequent itemsets discovery - Apriori algorithm
asets <-apriori(marketTR,aParam);
summary(asets)
# Not sure what this plots tbh
#plot(asets[size(asets)>5], method = "graph"); ######### it generates an error
plot(asets[size(asets)>4], method = "paracoord", control = list(reorder = TRUE));
# subset to find specific subsets
#closed itemsets
is.closed(asets);
#maximal itemsets
maxSets <- asets[is.maximal(asets)==TRUE];
?is.maximal


#Eclat
ecParam  = new("ECparameter", "confidence" = our_confidence, "support" = our_support);
fsets <- eclat(marketTR,ecParam);

#selection of frequent itemset found by means of  Eclat algorithm 
# and not found by means of Apriori algorithm

inspect(fsets[which(is.na(fsets %in% asets))]); ############does not return any result

# Association rules

#setting of parameters
aParam@target ="rules";
aParam@minlen = 2L; # Guarantee 2 to be an integer
aParam@confidence = our_confidence;

#Discovering of association rules by means of Apriori algorithm
aRules <-apriori(marketTR,aParam);
#Discovering rules for a different value of minimum  support
aParam@support = our_support + 0.2;
aRules2 <-apriori(marketTR,aParam);

rulesLift1.2 <- subset(aRules, subset = lift > our_lift);
summary(rulesLift1.2)
#charts presenting association rules
plot(rulesLift1.2, shading="order", control=list(main = "Two-key plot"));
plot(rulesLift1.2, method="matrix", measure="lift", interactive = TRUE);

#rules based on maximal frequent itemsets
maxRul <- aRules[is.maximal(aRules) == TRUE];

#removing reduntant rules (rules with the same consequent and confidence but with less items in the antecedent
notRedun <- aRules[is.redundant(aRules) == FALSE];

#Selecting rules based on the selected indicator of rule interestingness 
#rules with improvement indicator greater than 0.01

resTbl <- interestMeasure(aRules,"improvement", asets);
intres <- which(sapply(resTbl, function(x) {x > our_interest_measure  && x <= 1 })==TRUE);
intersRule <- aRules[intres];

#generation of association rules based on discovered frequent itemsets

ecParam  = new("ECparameter", "confidence" = our_confidence, "support" = our_support);
#discvoring frequent itemsets
fsets <- eclat(marketTR,ecParam);

iERules = ruleInduction(fsets, marketTR, confidence = our_confidence, control=list(method ="ptree"))

# General note: length() to count elements, summary() to get stats on object, str() to display the structure
