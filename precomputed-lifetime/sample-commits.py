#!/usr/bin/env python

# Usage: python sample-commits.py COMMIT_LIST_PATH COMMIT_NUM <random|uniform>

import math
import random
import sys

def read_lines(filename):
    contents = ''
    with open(filename) as f:
        contents = f.read()

    return filter(lambda l: l, contents.split('\n'))

def choose(n, ls):
    if n >= len(ls):
        for l in ls:
            yield l
    else:
        length = float(len(ls))
        for i in xrange(n):
            yield ls[int(math.ceil(i * length / n))]

def staggered_pair(l):
    for a, b in zip(l, l[1:]):
        yield (a, b)

if __name__ == '__main__':
    commit_list = read_lines(sys.argv[1])

    # Select one extra so that we get the right number of pairs
    commit_num = int(sys.argv[2]) + 1

    select_type = sys.argv[3]

    if select_type == 'random':
        commit_pairs = random.sample(commit_list, min(len(commit_list), commit_num))
    else:
        commit_pairs = list(choose(commit_num, commit_list))

    commit_pairs = list(staggered_pair(commit_pairs))

    with open('new-commit-list.txt', 'a') as f:
        f.write('\n'.join(map(lambda (_, new): new, commit_pairs)) + '\n')

    with open('old-commit-list.txt', 'a') as f:
        f.write('\n'.join(map(lambda (old, _): old, commit_pairs)) + '\n')

