import random
from collections import defaultdict

pairsPerAdverb = {}
pairsPerVerb = {}
marginalPerAdverb = defaultdict(int)
marginalPerVerb = defaultdict(int)
overallPairsCount = 0
def save1(table, name):
  with open(f"/john5/scr1/mhahn/PUKWAC/{name}", "w") as outFile:
    for x in table:
      try:
         print("\t".join([x, str(table[x])]), file=outFile)
      except UnicodeEncodeError:
         print("ERROR")

def save2(table, name):
  with open(f"/john5/scr1/mhahn/PUKWAC/{name}", "w") as outFile:
    for x in table:
      for y in table[x]:
        try:
          print("\t".join([x, y, str(table[x][y])]), file=outFile)
        except UnicodeEncodeError:
          pass
def record(verb, adverb):
   if adverb not in     pairsPerAdverb:
     pairsPerAdverb[adverb] = defaultdict(int)
   if verb not in     pairsPerVerb:
     pairsPerVerb[verb] = defaultdict(int)
   pairsPerAdverb[adverb][verb] += 1
   pairsPerVerb[verb][adverb] += 1
   marginalPerAdverb[adverb] += 1
   marginalPerVerb[verb] += 1
   global overallPairsCount
   overallPairsCount += 1
   if overallPairsCount % 1000 == 0:
     print(overallPairsCount, len(marginalPerVerb), len(marginalPerAdverb))
   if overallPairsCount % 100000 == 0:
     print("SAVING TABLES")
     save2(pairsPerAdverb, "pairsPerAdverb")
     save2(pairsPerVerb, "pairsPerBerb")
     save1(marginalPerAdverb, "marginalPerAdverb")
     save1(marginalPerVerb, "marginalPerVerb")


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
         if sentence[i][pos] == "RB" and sentence[i][relation] == "ADV":
            head_line = sentence[int(sentence[i][head])-1]
            assert head_line[position] == sentence[i][head]
            if int(sentence[i][position]) < int(sentence[i][head]):
               record(verb = head_line[lemma], adverb = sentence[i][lemma])
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
