#!/usr/bin/env python
import sys

def fizz_buzz(limit):
    for i in range(1, int(limit)):
        if i % 3 == 0:
            print('fizz')
        if i % 5 == 0:
            print('buzz')
        if i % 3 == 0 and i % 5 ==0:
            print('fizz', 'buzz')

def main(limit):
    fizz_buzz(limit)

main(sys.argv[1])
