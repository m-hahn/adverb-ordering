import random
from collections import defaultdict

pairsPerAdverb = {}
pairsPerVerb = {}
marginalPerAdverb = defaultdict(int)
marginalPerVerb = defaultdict(int)
overallPairsCount = 0
def load1(table, name):
  with open(f"/john5/scr1/mhahn/PUKWAC/{name}", "r") as outFile:
    for line in outFile:
       x, value = line.strip().split("\t")
       table[x] = int(value)

def load2(table, name):
  with open(f"/john5/scr1/mhahn/PUKWAC/{name}", "r") as outFile:
    for line in outFile:
       x, y, value = line.strip().split("\t")
       if x not in table:
           table[x] = defaultdict(int)
       table[x][y] = int(value)

load2(pairsPerAdverb, "pairsPerAdverb")
load2(pairsPerVerb, "pairsPerBerb")
load1(marginalPerAdverb, "marginalPerAdverb")
load1(marginalPerVerb, "marginalPerVerb")

overallCount = sum([y for _, y in marginalPerVerb.items()])
import math
with open("/john5/scr1/mhahn/PUKWAC/pmis.tsv", "w") as outFile:
  for adverb in pairsPerAdverb:
    if marginalPerAdverb[adverb] < 100:
      continue
    assert adverb in marginalPerAdverb
    mi = 0
    for verb in pairsPerAdverb[adverb]:
      assert verb in marginalPerVerb
#      print(adverb, verb)
      assert pairsPerVerb[verb][adverb] == pairsPerAdverb[adverb][verb]
      pmi = math.log(pairsPerVerb[verb][adverb]) - math.log(marginalPerAdverb[adverb]) - math.log(marginalPerVerb[verb]) + math.log(overallCount)
      print("\t".join([adverb, verb, str(pmi)]), file=outFile)
      mi += pmi * pairsPerVerb[verb][adverb]
    mi = mi / marginalPerAdverb[adverb]
    print(adverb, mi, "MAXIMUM", math.log(len(pairsPerAdverb[adverb])))
#    assert mi <= math.log(len(pairsPerAdverb[adverb])) + 0.1



