#!/usr/bin/env -S sed -E -n -f
# Collect numbers
s/[^[:digit:]]//g
s/^([[:digit:]]).*([[:digit:]])$/\1\2/
s/^([[:digit:]])$/\1\1/

# Arithmetic adapted from GNU Info sed example scrript 7.13 Counting Characters

t tens
: tens
s/^0//; t ones
s/^1/b/; t ones
s/^2/bb/; t ones
s/^3/bbb/; t ones
s/^4/bbbb/; t ones
s/^5/bbbbb/; t ones
s/^6/bbbbbb/; t ones
s/^7/bbbbbbb/; t ones
s/^8/bbbbbbbb/; t ones
s/^9/bbbbbbbbb/; t ones
: ones
s/0//; t don
s/1/a/; t don
s/2/aa/; t don
s/3/aaa/; t don
s/4/aaaa/; t don
s/5/aaaaa/; t don
s/6/aaaaaa/; t don
s/7/aaaaaaa/; t don
s/8/aaaaaaaa/; t don
s/9/aaaaaaaaa/
: don

H 
x
s/\n//

# Notable: the GNU example only adds one digits, but we add two digit numbers,
# so we handle sorting the `b`s and `a`s
s/(a+)(b+)(a+)/\2\1\3/

# Do the carry.  The t's and b's are not necessary, but they do speed up the
# thing
t a
# Note, we need the conditional branch to reset the flag, but even if we don't
# replace 9 `a`s with a `b`, we might need to replace 9 `b`s with an `a`
: a;  s/aaaaaaaaaa/b/g; t b
: b;  s/bbbbbbbbbb/c/g; t c; b add_done
: c;  s/cccccccccc/d/g; t d; b add_done
: d;  s/dddddddddd/e/g; t e; b add_done
: e;  s/eeeeeeeeee/f/g; t f; b add_done
: f;  s/ffffffffff/g/g; t g; b add_done
: g;  s/gggggggggg/h/g; t h; b add_done
: h;  s/hhhhhhhhhh//g

: add_done
$! {
    h
    b
}

# On the last line, convert back to decimal

: loop
/a/! s/[b-h]*/&0/
s/aaaaaaaaa/9/
s/aaaaaaaa/8/
s/aaaaaaa/7/
s/aaaaaa/6/
s/aaaaa/5/
s/aaaa/4/
s/aaa/3/
s/aa/2/
s/a/1/

: next
y/bcdefgh/abcdefg/
/[a-h]/ b loop
p
