#!/usr/bin/env -S sed -E -n -f
# normalize formatting
s/\./ /g
s/[^0-9 ]/X/g

# Collect all lines into the hold buffer, duplicating the first and last so we
# can easily iterate over 3 lines at a time
1h
H
$! b
H

# iterate over groups of 3
: loop
g
/\n[^\n]*\n/! b convert
# remove one line from hold buffer
s/^[^\n]*\n//
x

# trim to three lines
s/(\n[^\n]*\n[^\n]*).*/\1/
# remove pre-collected numbers
s/\|.*//
# duplicate line
s/^([^\n]*\n)([^\n]*\n)(.*)/\1\2\3\2/

# collect locations where one of three lines contains a symbol
t collect
: collect
s/^X([^\n]*)\n.([^\n]*)\n.([^\n]*)(.*)/\1\n\2\n\3\4X/; t collect_next
s/^.([^\n]*)\nX([^\n]*)\n.([^\n]*)(.*)/\1\n\2\n\3\4X/; t collect_next
s/^.([^\n]*)\n.([^\n]*)\nX([^\n]*)(.*)/\1\n\2\n\3\4X/; t collect_next
s/^.([^\n]*)\n.([^\n]*)\n.([^\n]*)(.*)/\1\n\2\n\3\4 /; t collect_next
: collect_next
/^[^\n]/b collect

# trim beginning lines
s/^\n\n//

# add space at ends to simplify side checkc
s/(^|\n)/\1 /g
s/($|\n)/ \1/g

# collect numbers
: collect_nums
    /^[^\n]*[0-9]/! {
        # Add numbers to hold space
        s/^[^|]*//
        H
        g
        s/\n([^\n]*)$/\1/
        h
        b loop
    }
    # skip ahead until we have a number starting at the second
    # character on the first line
    : num_start
        /^.[0-9]/b num_end
        s/^.([^\n]*\n).(.*)/\1\2/
        b num_start
    : num_end

    s/^(.)([0-9]+)(.*)/\1\2\3|\2/
    # If left diagonal, set left edge
    s/^([^\n]*\n)X./\1XX/

    : check_num
        # Trim start
        s/^.([^\n]*\n).(.*)/\1\2/
        /\nX/b remove_beginning
    /^[0-9]/b check_num

    # We don't have a symbol, remove the number
    s/\|[0-9]+$//

    # remove any leftover beginning
    : remove_beginning
        /^[0-9]/! b done_removing
        s/^.([^\n]*\n).(.*)/\1\2/
        b remove_beginning
    : done_removing

b collect_nums

: convert
s/^[^|]*\|//

s/$/|/
# convert numbers
s/9\|/aaaaaaaaa|/g
s/8\|/aaaaaaaa|/g
s/7\|/aaaaaaa|/g
s/6\|/aaaaaa|/g
s/5\|/aaaaa|/g
s/4\|/aaaa|/g
s/3\|/aaa|/g
s/2\|/aa|/g
s/1\|/a|/g
s/0\|/|/g
s/9(a*\|)/bbbbbbbbb\1/g
s/8(a*\|)/bbbbbbbb\1/g
s/7(a*\|)/bbbbbbb\1/g
s/6(a*\|)/bbbbbb\1/g
s/5(a*\|)/bbbbb\1/g
s/4(a*\|)/bbbb\1/g
s/3(a*\|)/bbb\1/g
s/2(a*\|)/bb\1/g
s/1(a*\|)/b\1/g
s/0(a*\|)/\1/g
s/9(b*a*\|)/ccccccccc\1/g
s/8(b*a*\|)/cccccccc\1/g
s/7(b*a*\|)/ccccccc\1/g
s/6(b*a*\|)/cccccc\1/g
s/5(b*a*\|)/ccccc\1/g
s/4(b*a*\|)/cccc\1/g
s/3(b*a*\|)/ccc\1/g
s/2(b*a*\|)/cc\1/g
s/1(b*a*\|)/c\1/g
s/0(b*a*\|)/\1/g
s/\|$//

# sum numbers
: sum
s/\|//
s/^(f*)(e*)(d*)(c*)(b*)(a*)(c*)(b*)/\1\2\3\4\7\5\8\6/
s/a{10}/b/
s/b{10}/c/
s/c{10}/d/
s/d{10}/e/
s/e{10}/f/
/\|/b sum

: to_dec
t clear; : clear
s/a{9}/9/; t next
s/a{8}/8/; t next
s/a{7}/7/; t next
s/a{6}/6/; t next
s/a{5}/5/; t next
s/a{4}/4/; t next
s/a{3}/3/; t next
s/a{2}/2/; t next
s/a{1}/1/; t next
s/($|[0-9])/0\1/
: next
y/bcdef/abcde/
/[a-e]/b to_dec
p
