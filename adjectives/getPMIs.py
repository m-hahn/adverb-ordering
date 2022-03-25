import random
from collections import defaultdict

pairsPerAdjective = {}
pairsPerNoun = {}
marginalPerAdjective = defaultdict(int)
marginalPerNoun = defaultdict(int)
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

load2(pairsPerAdjective, "pairsPerAdjective")
load2(pairsPerNoun, "pairsPerNoun")
load1(marginalPerAdjective, "marginalPerAdjective")
load1(marginalPerNoun, "marginalPerNoun")

overallCount = sum([y for _, y in marginalPerAdjective.items()])
import math
with open("/john5/scr1/mhahn/PUKWAC/adj_mis.tsv", "w") as outFile_MIs:
 with open("/john5/scr1/mhahn/PUKWAC/adj_pmis.tsv", "w") as outFile:
  for adjective in pairsPerAdjective:
    if marginalPerAdjective[adjective] < 50:
      continue
    assert adjective in marginalPerAdjective
    mi = 0
    countAcrossNouns = 0
    for noun in pairsPerAdjective[adjective]:
      assert noun in marginalPerNoun
#      print(adjective, noun)
      assert pairsPerNoun[noun][adjective] == pairsPerAdjective[adjective][noun], (noun, adjective, pairsPerNoun[noun][adjective], pairsPerAdjective[adjective][noun])
      countAcrossNouns += pairsPerNoun[noun][adjective]
      pmi = math.log(pairsPerNoun[noun][adjective]) - math.log(marginalPerAdjective[adjective]) - math.log(marginalPerNoun[noun]) + math.log(overallCount)
      print("\t".join([adjective, noun, str(pmi)]).encode('utf8', 'ignore').decode("utf8"), file=outFile)
      mi += pmi * pairsPerNoun[noun][adjective] / marginalPerAdjective[adjective]
    assert countAcrossNouns == marginalPerAdjective[adjective]
    print("\t".join([adjective, str(mi)]).encode('utf8', 'ignore').decode("utf8"), file=outFile_MIs)
    print(adjective, mi, "MAXIMUM", math.log(len(pairsPerAdjective[adjective])))
#    assert mi <= math.log(len(pairsPerAdjective[adjective])) + 0.1



