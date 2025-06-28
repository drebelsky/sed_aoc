#!/usr/bin/env -S sed -E -n -f
# No size is larger than 20
# Change invalid ids to 0 (that way the $! at the end works)
/1[3-9] red/s/.*/Game 0:/
/1[4-9] green/s/.*/Game 0:/
/1[5-9] blue/s/.*/Game 0:/
/20 [rgb]/s/.*/Game 0:/

# Collect ids
s/Game ([0-9]+):.*/\1/
# pad to length 3
s/^/000/
s/.*(.{3})/\1/

t hundreds
: hundreds
s/^0//; t tens
s/^1/c/; t tens
s/^2/cc/; t tens
s/^3/ccc/; t tens
s/^4/cccc/; t tens
s/^5/ccccc/; t tens
s/^6/cccccc/; t tens
s/^7/ccccccc/; t tens
s/^8/cccccccc/; t tens
s/^9/ccccccccc/; t tens
: tens
s/^(c*)0/\1/; t ones
s/^(c*)1/\1b/; t ones
s/^(c*)2/\1bb/; t ones
s/^(c*)3/\1bbb/; t ones
s/^(c*)4/\1bbbb/; t ones
s/^(c*)5/\1bbbbb/; t ones
s/^(c*)6/\1bbbbbb/; t ones
s/^(c*)7/\1bbbbbbb/; t ones
s/^(c*)8/\1bbbbbbbb/; t ones
s/^(c*)9/\1bbbbbbbbb/; t ones
: ones
s/0//; t add
s/1/a/; t add
s/2/aa/; t add
s/3/aaa/; t add
s/4/aaaa/; t add
s/5/aaaaa/; t add
s/6/aaaaaa/; t add
s/7/aaaaaaa/; t add
s/8/aaaaaaaa/; t add
s/9/aaaaaaaaa/; t add

: add
H
g
s/\n//
s/^(d*)(c*)(b*)(a*)(d*)(c*)(b*)(a*)$/\1\5\2\6\3\7\4\8/
s/aaaaaaaaaa/b/
s/bbbbbbbbbb/c/
s/cccccccccc/d/
$! {
    h
    b
}

# See day1, adapted from GNU print
: loop
/a/! s/[b-d]*/&0/
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
y/bcd/abc/
/[a-d]/ b loop
p
