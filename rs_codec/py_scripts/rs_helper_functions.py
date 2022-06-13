#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Functions extracted from https://github.com/tomerfiliba/reedsolomon
# Copyright (c) 2019 Mateus Silva <matgonsil@gmail.com> 
import itertools
from array import array

################### INIT and stuff ###################

try:
    bytearray
except NameError:
    from array import array
    def bytearray(obj = 0, encoding = "latin-1"): # always use Latin-1 and not UTF8 because Latin-1 maps the first 256 characters to their bytevalue equivalents. UTF8 may mangle your data (particularly at vale 128)
        if isinstance(obj, str):
            obj = [ord(ch) for ch in obj.encode("latin-1")]
        elif isinstance(obj, int):
            obj = [0] * obj
        print(obj)
        return array("B", obj)

try: # compatibility with Python 3+
    xrange
except NameError:
    xrange = range

def dbytearray(obj = 0): 
    if isinstance(obj, str):
        obj = [ord(ch) for ch in obj.encode("latin-1")]
    elif isinstance(obj, int):
        obj = [0] * obj
    return array("I", obj)

def gf_mult_noLUT(x, y, prim=0, field_charac_full=1024, carryless=True):
    '''Galois Field integer multiplication using Russian Peasant Multiplication algorithm (faster than the standard multiplication + modular reduction).
    If prim is 0 and carryless=False, then the function produces the result for a standard integers multiplication (no carry-less arithmetics nor modular reduction).'''
    r = 0
    while y: # while y is above 0
        if y & 1: r = r ^ x if carryless else r + x # y is odd, then add the corresponding x to r (the sum of all x's corresponding to odd y's will give the final product). Note that since we're in GF(2), the addition is in fact an XOR (very important because in GF(2) the multiplication and additions are carry-less, thus it changes the result!).
        y = y >> 1 # equivalent to y // 2
        x = x << 1 # equivalent to x*2
        if prim > 0 and x & field_charac_full: 
            x = x ^ prim # GF modulo: if x >= 256 then apply modular reduction using the primitive polynomial (we just substract, but since the primitive number can be above 256 then we directly XOR).
    return r & (field_charac_full-1)

def gf_poly_mul_simple(p, q, prim=0, field=1024): # simple equivalent way of multiplying two polynomials without precomputation, but thus it's slower
    '''Multiply two polynomials, inside Galois Field'''
    # Pre-allocate the result array
    r = dbytearray(len(p) + len(q) - 1)
    # Compute the polynomial multiplication (just like the outer product of two vectors, we multiply each coefficients of p with all coefficients of q)
    for j in xrange(len(q)):
        for i in xrange(len(p)):
            r[i + j] ^= gf_mult_noLUT(p[i], q[j], prim, field) # equivalent to: r[i + j] = gf_add(r[i+j], gf_mul(p[i], q[j])) -- you can see it's your usual polynomial multiplication
    return r

def rs_generator_poly(nsym, b=0, generator=2, prim=0, field=1024):
    '''Generate an irreducible generator polynomial (necessary to encode a message into Reed-Solomon)'''
    g = dbytearray([1])
    exp = 1
    for i in range(b):
        exp = gf_mult_noLUT(exp, generator, prim, field)
    for i in xrange(nsym):
        g = gf_poly_mul_simple(g, [1, exp], prim, field)
        exp = gf_mult_noLUT(exp, generator, prim, field)
    return g

def gf_inverse(x, prim=0, field=1024):
    gf_exp = dbytearray([1] * 2 * field)
    gf_log = dbytearray(field)

    k = 1
    for i in xrange(field - 1): # we could skip index 1023 which is equal to index 0 because of modulo: g^1023==g^0 but either way, this does not change the later outputs (ie, the ecc symbols will be the same either way)
        gf_exp[i] = k # compute anti-log for this value and store it in a table
        gf_log[k] = i # compute log at the same time
        k = gf_mult_noLUT(k, 2, prim, field)

    for i in xrange(field -1, (field - 1) * 2):
        gf_exp[i] = gf_exp[i - field - 1]

    return gf_exp[field - 1 - gf_log[x]]
