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
    total = defaultdict(lambda: 0)
    for f in os.listdir(category):
        with open(os.path.join(category,f)) as j:
            joke = []
            for line in j:
                splt = line.split(' ')
                for s in splt:
                    word = s.translate(punc).translate(white).lower()
                    if len(word) > 0:
                        total[dictionary.get(word, word)] += 1

    return total

dictionary = create_corpus()
path = '../jokes'
jokes_result = '../jokes_result'
for c in os.listdir(path):
    category_result = calculate_category(os.path.join(path,c))
    if category_result == 0:
          break
    with open(os.path.join(jokes_result, c), 'w') as cat:
        for res in sorted(category_result, key=category_result.get, reverse=True):
            output = '{} {}\n'.format(res, category_result[res])
            cat.write(output)
