import math
import random
from collections import defaultdict

sumLogDistancePerAdjective = defaultdict(int)
sumDistancePerAdjective = defaultdict(int)
marginalPerAdjective = defaultdict(int)
overallPairsCount = 0
def save1(table, name):
  with open(f"/john5/scr1/mhahn/PUKWAC/{name}", "w") as outFile:
    for x in table:
      try:
         print("\t".join([x, str(table[x])]), file=outFile)
      except UnicodeEncodeError:
         print("ERROR")


word = 0
lemma = 1
pos = 2
position = 3
head = 4
relation = 5

def process(sentence):
    sentence = [x.split("\t") for x in sentence]
#    print(sentence)
    for i in range(len(sentence)):
      if len(sentence[i]) < 6:
         print(sentence[i])
      else:
         if sentence[i][pos] == "JJ" and sentence[i][relation] == "NMOD":
            head_line = sentence[int(sentence[i][head])-1]
            if head_line[position] != sentence[i][head]:
               print("WEIRD!!!", head_line, sentence[i])
               continue
            if int(sentence[i][position]) < int(sentence[i][head]):
               adjective = sentence[i][lemma].encode('utf8', 'ignore').decode("utf8")
               if adjective.isalpha():
                 sumDistancePerAdjective[adjective] -= int(sentence[i][position]) - int(sentence[i][head])
                 sumLogDistancePerAdjective[adjective] += math.log( - (int(sentence[i][position]) - int(sentence[i][head])))
                 marginalPerAdjective[adjective] += 1 
                 global overallPairsCount
                 overallPairsCount += 1
                 if overallPairsCount % 1000 == 0:
                   print(overallPairsCount, len(marginalPerAdjective))
                 if overallPairsCount % 100000 == 0:
                   print("SAVING TABLES")
                   save1({adjective : sumDistancePerAdjective[adjective] / marginalPerAdjective[adjective] for adjective in marginalPerAdjective}, "avgDistancePerAdjective")
                   save1({adjective : sumLogDistancePerAdjective[adjective] / marginalPerAdjective[adjective] for adjective in marginalPerAdjective}, "avgLogDistancePerAdjective")
 #              else:
##                   print(adjective) 






#            if int(head_line[position]) > int(head_line[head]):
#               print(sentence[i], head_line)
       
#    if random.random() < 0.1:
 #      quit()

count = 0
sentence = []
for group in [1,2,3,4]:
 with open(f"/john5/scr1/mhahn/PUKWAC/ukwac{group}.xml", "r", errors="surrogateescape") as inFile:
   for line in inFile:
      if line.startswith("<s>"):
        count += 1
#        if count % 1000 == 0:
        # print(count)
        process(sentence)
        sentence = []
      elif line.startswith("<"):
        continue
      else:
        sentence.append(line.strip())
