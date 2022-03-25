import random
from collections import defaultdict

pairsCount = defaultdict(int)

def save11(table, name):
  with open(f"/john5/scr1/mhahn/PUKWAC/{name}", "w") as outFile:
    for x in table:
      try:
         print("\t".join([x[0], x[1], x[2], str(table[x])]), file=outFile)
      except UnicodeEncodeError:
         print("ERROR", x[0].encode ('utf8', 'ignore'))

word = 0
lemma = 1
pos = 2
position = 3
head = 4
relation = 5

pairsTotal = 0

def process(sentence):
    global pairsTotal
    sentence = [x.split("\t") for x in sentence]
#    print(sentence)
    adjectives = [word for word in sentence if word[pos] == "JJ" and word[relation] == "NMOD" and int(word[position]) < int(word[head])]
    heads = set([int(word[head]) for word in adjectives])
    for headIndex in heads:
      adjectives = [adjective for adjective in adjectives if int(adjective[head]) == headIndex]
      for i in range(len(adjectives)):
          for j in range(i):
              ADVERB_i = adjectives[i][lemma].encode('utf8', 'ignore').decode("utf8")
              ADVERB_j = adjectives[j][lemma].encode('utf8', 'ignore').decode("utf8")
              if ADVERB_i.isalpha() and ADVERB_j.isalpha():
               pairsCount[(ADVERB_j, ADVERB_i, sentence[headIndex-1][lemma].encode('utf8', 'ignore').decode("utf8"))] += 1
               assert adjectives[j][head] == adjectives[i][head]
               assert int(adjectives[j][head]) == headIndex
               pairsTotal += 1
               if pairsTotal % 1000 == 0:
                 print(pairsTotal)
#                 print(pairsCount)
 #                quit()
               if pairsTotal % 100000 == 0:
                  print("SAVING")
                  save11(pairsCount, "adjectivePairsWithNoun")
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
