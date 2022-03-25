import random
from collections import defaultdict

pairsPerAdverb = {}
pairsPerVerb = {}
marginalPerAdverb = defaultdict(int)
marginalPerVerb = defaultdict(int)
overallPairsCount = 0
def load1(table, name):
  duplicateCount = 0
  with open(f"/john5/scr1/mhahn/PUKWAC/{name}", "r") as outFile:
    for line in outFile:
       x, value = line.strip("\n").split("\t")
       if x in table:
         print("DUPLICATE", x)
         duplicateCount += 1
         assert False
       table[x] = int(value)
  print(duplicateCount/len(table))
#  quit()

def load2(table, name):
  with open(f"/john5/scr1/mhahn/PUKWAC/{name}", "r") as outFile:
    for line in outFile:
       x, y, value = line.strip("\n").split("\t")
       if x not in table:
           table[x] = defaultdict(int)
       assert y not in table[x], (x,y)
       table[x][y] = int(value)

load2(pairsPerAdverb, "pairsPerAdverb")
load2(pairsPerVerb, "pairsPerVerb")
load1(marginalPerAdverb, "marginalPerAdverb")
load1(marginalPerVerb, "marginalPerVerb")

overallCount = sum([y for _, y in marginalPerAdverb.items()])
import math
with open("/john5/scr1/mhahn/PUKWAC/mis.tsv", "w") as outFile_MIs:
 with open("/john5/scr1/mhahn/PUKWAC/pmis.tsv", "w") as outFile:
  for adverb in pairsPerAdverb:
    if marginalPerAdverb[adverb] < 50:
      continue
    assert adverb in marginalPerAdverb
    mi = 0
    countAcrossVerbs = 0
    for verb in pairsPerAdverb[adverb]:
      assert verb in marginalPerVerb
#      print(adverb, verb)
      assert pairsPerVerb[verb][adverb] == pairsPerAdverb[adverb][verb], (verb, adverb, pairsPerVerb[verb][adverb], pairsPerAdverb[adverb][verb])
      countAcrossVerbs += pairsPerVerb[verb][adverb]
      pmi = math.log(pairsPerVerb[verb][adverb]) - math.log(marginalPerAdverb[adverb]) - math.log(marginalPerVerb[verb]) + math.log(overallCount)
      print("\t".join([adverb, verb, str(pmi)]).encode('utf8', 'ignore').decode("utf8"), file=outFile)
      mi += pmi * pairsPerVerb[verb][adverb] / marginalPerAdverb[adverb]
    assert countAcrossVerbs == marginalPerAdverb[adverb]
    print("\t".join([adverb, str(mi)]).encode('utf8', 'ignore').decode("utf8"), file=outFile_MIs)
    print(adverb, mi, "MAXIMUM", math.log(len(pairsPerAdverb[adverb])))
#    assert mi <= math.log(len(pairsPerAdverb[adverb])) + 0.1



