import sys

def choose(n, ls):
    if n >= len(ls):
        for l in ls:
            yield l
    else:
        for i in xrange(0, len(ls), len(ls) / n):
            yield ls[i]

if __name__ == '__main__':
    n = int(sys.argv[1])

    drop = 0
    if len(sys.argv) > 2:
        drop = int(sys.argv[2]);

    lines = []
    for line in sys.stdin:
        lines.append(line[:-1])

    for line in choose(n, lines[drop:]):
        print(line)

