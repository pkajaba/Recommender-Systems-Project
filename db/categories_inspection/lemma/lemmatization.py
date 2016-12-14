#!/usr/bin/python3

import string
import os
from collections import defaultdict

def create_corpus():
    dictionary = {}
    with open("lemmatization-sk.txt", 'r') as l:
        for line in l:
            splitted = line.split('\t')
            dictionary[splitted[1].rstrip('\n')] = splitted[0]

    return dictionary


def calculate_category(category):
    punc = str.maketrans({key: None for key in string.punctuation})
    white = str.maketrans({key: None for key in string.whitespace})
    joke_keywords = []
    total = defaultdict(lambda: 0)
    for f in os.listdir(category):
        with open(os.path.join(category,f)) as j:
            joke = []
            joke_keyword = defaultdict(lambda: 0)
            for line in j:
                splt = line.split(' ')
                for s in splt:
                    word = s.translate(punc).translate(white).lower()
                    if len(word) > 2:
                        joke_keyword[dictionary.get(word, word)] += 1
                        total[dictionary.get(word, word)] += 1

            joke_keywords.append(joke_keyword)

    return {'total' : total, 'joke_keywords': joke_keywords}

def dice(set1, set2):
    inter = set1.intersection(set2)
    return 2*len(inter)/(len(set1)+len(set2))

dictionary = create_corpus()
path = '../jokes'
jokes_result = '../jokes_result'
cccc = {}
for c in os.listdir(path):
    category_result = calculate_category(os.path.join(path,c))
    if category_result['total'] == 0:
          break

    jokes_sets = []
    joks = set()
    for res in sorted(category_result['total'], key=category_result['total'].get, reverse=True):
        joks.add(res)
        #if len(joks):
        #    break
    cccc[c] = joks


for i in cccc.keys():
    print("\'{}\' ".format(i), end="")

print('\n')
for i in cccc.keys():
    print("\'{}\' ".format(i), end="")
    for j in cccc.keys():
        print('{} '.format(dice(cccc[i], cccc[j])), end="")
    print('')




    #for j in category_result['joke_keywords']:
    #    for i in category_result['joke_keywords']:

    #for j in category_result['joke_keywords']:
    #    s = set()
    #    for res in sorted(j, key=j.get, reverse=True):
    #        s.add(res)
    #        if len(s) > 5:
    #            break
    #    jokes_sets.append(s)

    #average = 0
    #count = 0
    #for i in jokes_sets:
    #    for j in jokes_sets:
    #        average += dice(i,j)
    #        count += 1
    #print('{},{}'.format(c, average/count))
    #cccc[c] = jokes_sets


#for a in cccc.keys():
#    for b in cccc.keys():
#        average = 0
#        count = 0
#        for i in cccc[a]:
#        #for k in cccc['Cudzinci_versus_cudzinci']:
#            for k in cccc[b]:
#                average += dice(i, k)
#                count += 1
#        print(a,b,average/count)

#    break
    #with open(os.path.join(jokes_result, c), 'w') as cat:
    #    for res in sorted(category_result['total'], key=category_result['total'].get, reverse=True):
    #        output = '{} {}\n'.format(res, category_result['total'][res])
    #        cat.write(output)
