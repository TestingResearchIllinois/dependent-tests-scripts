import os
import sys

def get_totaltime(lines, isorig, origorderfile):
    # Look for test order list
    for idx, line in enumerate(lines):
        if 'Test order list:' in line:
            tests = lines[idx + 1].replace('[', '').replace(']', '').split(', ')
            break

    # Look for the test times for running in this order
    totaltime = 0
    for idx, line in enumerate(lines):
        if 'Time each test takes to run in the new order:' in line:
            totaltime += sum([abs(int(x)) for x in lines[idx + 1].replace('[', '').replace(']', '').split(', ')])
            break

    # Look for the test results
    failedtests = set()
    for idx, line in enumerate(lines):
        if 'Test order results:' in line:
            for elem in lines[idx + 1].replace('{', '').replace('}', '').split(', '):
                test = elem.split('=')[0]
                status = elem.split('=')[1]
                if status == 'ERROR' or status == 'FAILURE':
                    failedtests.add(test)
            break

    # If no failed tests, can quit early
    if len(failedtests) == 0:
        return totaltime
        return

    # Get the results from running in isolation
    for idx, line in enumerate(lines):
        if 'Isolation results:' in line:
            isolationresults = {}
            for elem in lines[idx + 1].replace('{', '').replace('}', '').split(', '):
                test = elem.split('=')[0]
                status = elem.split('=')[1]
                isolationresults[test] = status
            break

    # Get the times from running in isolation
    for idx, line in enumerate(lines):
        if 'Isolation times:' in line:
            isolationtimes = {}
            for elem in lines[idx + 1].replace('{', '').replace('}', '').split(', '):
                test = elem.split('=')[0]
                time = int(elem.split('=')[1])
                isolationtimes[test] = abs(time)
            break

    # Get the times from the original order
    for idx, line in enumerate(lines):
        if 'Original order times:' in line:
            origordertimes = {}
            for elem in lines[idx + 1].replace('{', '').replace('}', '').split(', '):
                test = elem.split('=')[0]
                time = int(elem.split('=')[1])
                origordertimes[test] = abs(time)
            break

    # Get the original order of the tests
    origorder = []
    # Read the file if from original, but just sort if auto
    if isorig:
        with open(origorderfile) as f:
            for line in f:
                origorder.append(line.strip())
    else:
        origorder = sorted(origordertimes.keys())

    # For each failed test, obtain its status from isolation
    stillfailedtests = set()
    for ft in failedtests:
        totaltime += isolationtimes[ft]
        if not isolationresults[ft] == 'PASS':
            stillfailedtests.add(ft)

    # Now if there are still some failed tests, run the original order, up to the latest
    maxidx = 0
    for sft in stillfailedtests:
        idx = origorder.index(sft)
        if idx > maxidx:
            maxidx = idx
    for idx in range(maxidx):
        if origorder[idx] in origordertimes:
            totaltime += origordertimes[origorder[idx]]

    return totaltime


def main(args):
    logfile = args[1]       # The log file for a run
    origorderfile = args[2] # The file with the tests in order

    # Get all the lines in the file into a list
    lines = []
    with open(logfile) as f:
        for line in f:
            lines.append(line.strip())

    # Report the chunk of runs that gives the largest total time
    maxtotaltime = 0
    chunk = []
    for line in lines:
        if line == '--------------------------':
            totaltime = get_totaltime(chunk, '-ORIG-' in logfile, origorderfile)
            if totaltime > maxtotaltime:
                maxtotaltime = totaltime
            chunk = []
        else:
            chunk.append(line)

    print maxtotaltime

if __name__ == '__main__':
    main(sys.argv)
