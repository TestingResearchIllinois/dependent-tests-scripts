#!/usr/bin/env python

# Usage: python check-enhanced-results.py PRIO_RESULTS SELE_RESULTS PARA_RESULTS

from datetime import datetime
import itertools
import sys

def ints_in_seq(s, delim):
    result = []

    started = False
    for section in s.split(delim):
        if section.isdigit():
            if not started:
                started = True
            result.append(section)
        else:
            if started:
                break

    return map(int, result)

class ResultLine:
    def __init__(self, all_values):
        self.all_values = all_values
        self.values = self.all_values[1:]

        self.date = datetime(*ints_in_seq(self.all_values[0], '-'))

    def __repr__(self):
        return str(self.date) + ' & ' + ' '.join(self.values)

def read_results(fname):
    contents = ''
    with open(fname) as f:
        contents = f.read()

    contents = contents.replace('\\', '').replace('\r', '').replace('%', '').split('\n')

    return map(ResultLine, filter(lambda l: l, map(lambda line: filter(lambda s: s, map(lambda s: s.strip(), line.split('&'))), contents)))

def gather_results(results):
    columns = []

    for result_line in results:
        for i, v in enumerate(result_line.values):
            if len(columns) <= i:
                columns.append([])

            columns[i].append((result_line.date, v))

    return columns

def process_results(gathered_results):
    result = []

    for i, col in enumerate(gathered_results):
        better = list(itertools.takewhile(lambda (date, v): not v.startswith('-'), col))
        start_date = col[0][0]

        if better:
            end_date = better[-1][0]

            timespan = end_date - start_date
            print('Column {}: Better from {} to {} ({} days)'.format(i, start_date, end_date, timespan.days))
            result.append(timespan.days)
        else:
            print('Column {}: Immediately worse.'.format(i))
            result.append(0)

    return result

def results(fname):
    return process_results(gather_results(read_results(fname)))

def mean(ns):
    return sum(ns) / float(len(ns))

def run(argv):
    print('')
    print('-----------------------------------------------------------')
    print('Prioritization results:')
    prio_results = results(argv[1])

    print('')
    print('-----------------------------------------------------------')
    print('Selection results:')
    sele_results = results(argv[2])

    print('')
    print('-----------------------------------------------------------')
    print('Parallelization results:')
    para_results = results(argv[3])

    all_results = prio_results + sele_results + para_results

    print('')
    print('-----------------------------------------------------------')
    print(all_results)
    print('Average: {} days'.format(mean(all_results)))
    
if __name__ == '__main__':
    run(sys.argv)

