#!/usr/bin/env python
"""
Finds all possible words that may be used to represent a number.
http://vecherka.cssum.net/v5/proglang-contest.html

Author: Artem Dudarev
"""

from itertools import product

MIN_WORD_LENGTH = 2

d2l = {
    "2": "abc",
    "3": "def",
    "4": "ghi",
    "5": "jkl",
    "6": "mno",
    "7": "pqrs",
    "8": "tuv",
    "9": "wxyz"}

# loads words that may be used
possible_words = set()

with open('../dictionary.txt', 'r') as f:
    for line in f:
        possible_words.add(line.strip().lower())

# loads numbers to check
numbers = []

with open('../input.txt', 'r') as f:
    for line in f:
        numbers.append(line.strip().lower())


def words_for_number(number_str):
    """
    Returns a list of all possible words
    that may correspond to a whole number string.

    For example: 63 - ['me', 'of']
    """
    words = []
    try:
        for p in product(*[d2l[d] for d in number_str]):
            w = ''.join(p)
            if w in possible_words:
                words.append(w)
    except KeyError:
        pass
    return words


def words_combinations(number_str):
    """
    Returns a list of all possible words *combinations*
    that may correspond to a whole number string.
    Words are separated by spaces.
    
    For example: 63263379355 - [..., 'me codes well', ...] - 57 combinations
    """
    combinations_list = []
    for i in range(MIN_WORD_LENGTH, len(number_str) + 1):
        first_word_list = words_for_number(number_str[:i])
        if first_word_list:
            if i == len(number_str):
                combinations_list.extend(first_word_list)
            else:
                remaining_combinations_list = words_combinations(number_str[i:])
                if remaining_combinations_list:
                    combinations_list.extend(
                        ' '.join(p) for p in product(
                            first_word_list, remaining_combinations_list))
    return combinations_list


# outputs in format:
# numberN cobination of words
with open('../output.txt', 'w') as f:
    for n in numbers:
        wc = words_combinations(n)
        for c in wc:
            f.write('{} {}\n'.format(n, c))
