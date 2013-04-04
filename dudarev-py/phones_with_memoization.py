#!/usr/bin/env python
"""
Finds all possible words that may be used to represent a number.
http://vecherka.cssum.net/v5/proglang-contest.html

Author: Artem Dudarev
"""

from itertools import product

MIN_WORD_LENGTH = 2

l2d = {
    'a': '2', 'b': '2', 'c': '2',
    'd': '3', 'e': '3', 'f': '3',
    'g': '4', 'h': '4', 'i': '4',
    'j': '5', 'k': '5', 'l': '5',
    'm': '6', 'n': '6', 'o': '6',
    'p': '7', 'q': '7', 'r': '7', 's': '7',
    't': '8', 'u': '8', 'v': '8',
    'w': '9', 'x': '9', 'y': '9', 'z': '9'}


# dictionary holds all words for a given digits combination
# { ..., '63': ['me', 'of'], ... }
number2words = {}

with open('../dictionary.txt', 'r') as f:
    for line in f:
        word = line.strip().lower()
        try:
            number = ''.join([l2d[c] for c in list(word)])
        except KeyError:
            # a word has character not in l2d map
            continue
        number2words[number] = number2words.get(number, []) + [word]


# loads numbers to check
numbers = []

with open('../input.txt', 'r') as f:
    for line in f:
        numbers.append(line.strip().lower())


# for simple memoization
words_combinations_cache = {}


def words_combinations(number_str):
    """
    Returns a list of all possible words *combinations*
    that may correspond to a whole number string.
    Words are separated by spaces.
    
    For example: 63263379355 - [..., 'me codes well', ...] - 57 combinations
    """
    if number_str in words_combinations_cache:
        return words_combinations_cache[number_str]
    combinations_list = []
    for i in range(MIN_WORD_LENGTH, len(number_str) + 1):
        first_word_list = number2words.get(number_str[:i], None)
        if first_word_list:
            if i == len(number_str):
                combinations_list.extend(first_word_list)
            else:
                remaining_combinations_list = words_combinations(number_str[i:])
                if remaining_combinations_list:
                    combinations_list.extend(
                        ' '.join(p) for p in product(
                            first_word_list, remaining_combinations_list))
    words_combinations_cache[number_str] = combinations_list
    return combinations_list


# outputs in format:
# numberN cobination of words
with open('../output.txt', 'w') as f:
    for n in numbers:
        wc = words_combinations(n)
        for c in wc:
            f.write('{} {}\n'.format(n, c))
