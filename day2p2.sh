#!/usr/bin/env -S sed -E -n -f
# inspired by dc.sed
# Reformat line to format bb|bb|bb;gg|gg|gg;rr|rr|rr;
:red
s/(.*) ([0-9]+) red/0\2|\1/
s/(.*) ([0-9]+) red/0\2|\1/
/red/b red
s/^/;/
:green
s/(.*) ([0-9]+) green/0\2|\1/
s/(.*) ([0-9]+) green/0\2|\1/
/green/b green
s/^/;/
:blue
s/(.*) ([0-9]+) blue/0\2|\1/
s/(.*) ([0-9]+) blue/0\2|\1/
/blue/b blue

s/ame.*//g
s/\|[;G]/;/g
# truncate to 2 digits
s/0*([0-9]{2})([^0-9])/\1\2/g

: a_s
# replace numbers with counts of `a`s
# add lookup table
s/([0-9]{2})/\101a:02aa:03aaa:04aaaa:05aaaaa:06aaaaaa:07aaaaaaa:08aaaaaaaa:09aaaaaaaaa:10aaaaaaaaaa:11aaaaaaaaaaa:12aaaaaaaaaaaa:13aaaaaaaaaaaaa:14aaaaaaaaaaaaaa:15aaaaaaaaaaaaaaa:16aaaaaaaaaaaaaaaa:17aaaaaaaaaaaaaaaaa:18aaaaaaaaaaaaaaaaaa:19aaaaaaaaaaaaaaaaaaa:20aaaaaaaaaaaaaaaaaaaa:$/
s/([0-9]{2}).*\1(a*):[^$]*\$/\2/
/[0-9]/b a_s

# Find minimums
: find_min
s/;/Q/
s/^/!/
t right_greater
: right_greater
s/[^a](a+)[^a](.*)\1(a+)(.*Q)/.\2\1\3\4/
t right_greater
s/^.(a+).*Q(.*)/\2\1R/
/;/b find_min

# multiply
s/^a{20}/bb/
s/^a{10}/b/
: mul
s/R/QR/
s/QRa/QR/
: add_one
s/([^Q]+Q)Ra/\1\1R/
/QRa/b add_one
s/Q//g
s/R(R|$)/Q/
# rearrange to d->c->b->a
t b_front
: b_front
s/(.*)([^b])(b+)(.*Q)/\3\1\2\4/
t b_front
t c_front
: c_front
s/(.*)([^c])(c+)(.*Q)/\3\1\2\4/
t c_front
t d_front
: d_front
s/(.*)([^d])(d+)(.*Q)/\3\1\2\4/
t d_front

# Combine 10 copies of a place
t combine_as
: combine_as
s/(^|[^a])a{10}(.*Q)/\1b\2/
t combine_as
t combine_bs
: combine_bs
s/(^|[^b])b{10}(.*Q)/\1c\2/
t combine_bs
t combine_cs
: combine_cs
s/(^|[^c])c{10}(.*Q)/\1d\2/
t combine_cs

/R/! b total
s/Q/R/
b mul

: total
s/Q//
H
x
s/\n//
# place in order
s/(.*)([^b])(b+)/\3\1\2/
s/(.*)([^b])(b+)/\3\1\2/
s/(.*)([^c])(c+)/\3\1\2/
s/(.*)([^c])(c+)/\3\1\2/
s/(.*)([^d])(d+)/\3\1\2/
s/(.*)([^d])(d+)/\3\1\2/
s/(.*)([^e])(e+)/\3\1\2/
s/(.*)([^e])(e+)/\3\1\2/
s/(.*)([^f])(f+)/\3\1\2/
s/(.*)([^f])(f+)/\3\1\2/

s/a{10}/b/
s/b{10}/c/
s/c{10}/d/
s/d{10}/e/
s/e{10}/f/

$! { h; b }
t repl; : repl
s/aaaaaaaaa/9/; t next
s/aaaaaaaa/8/; t next
s/aaaaaaa/7/; t next
s/aaaaaa/6/; t next
s/aaaaa/5/; t next
s/aaaa/4/; t next
s/aaa/3/; t next
s/aa/2/; t next
s/a/1/; t next
s/($|[0-9])/0\1/; t next
: next
y/bcdef/abcde/
/[a-f]/b repl
p
