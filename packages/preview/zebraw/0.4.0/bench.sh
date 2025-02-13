TEST_LIST="test test-zbr test-zbr-copyable test-cdl"
for test in $TEST_LIST
do
    cp bench/$test.typ $test.typ
    crityp $test.typ --bench-output .
    rm $test.typ
done

# Benchmarking /test.typ@bench
# Benchmarking /test.typ@bench: Warming up for 3.0000 s
# Benchmarking /test.typ@bench: Collecting 100 samples in estimated 6.0377 s (20k iterations)
# Benchmarking /test.typ@bench: Analyzing
# /test.typ@bench         time:   [300.06 µs 300.52 µs 301.04 µs]
#                         change: [-7.8956% -5.6054% -3.6934%] (p = 0.00 < 0.05)
#                         Performance has improved.
# Found 6 outliers among 100 measurements (6.00%)
#   1 (1.00%) low severe
#   1 (1.00%) low mild
#   4 (4.00%) high mild

# Benchmarking /test-zbr.typ@bench
# Benchmarking /test-zbr.typ@bench: Warming up for 3.0000 s
# Benchmarking /test-zbr.typ@bench: Collecting 100 samples in estimated 6.4507 s (10k iterations)
# Benchmarking /test-zbr.typ@bench: Analyzing
# /test-zbr.typ@bench     time:   [625.83 µs 630.28 µs 636.44 µs]
#                         change: [-2.0113% -0.0384% +1.5734%] (p = 0.97 > 0.05)
#                         No change in performance detected.
# Found 5 outliers among 100 measurements (5.00%)
#   3 (3.00%) high mild
#   2 (2.00%) high severe

# Benchmarking /test-zbr-copyable.typ@bench
# Benchmarking /test-zbr-copyable.typ@bench: Warming up for 3.0000 s
# Benchmarking /test-zbr-copyable.typ@bench: Collecting 100 samples in estimated 6.3769 s (10k iterations)
# Benchmarking /test-zbr-copyable.typ@bench: Analyzing
# /test-zbr-copyable.typ@bench
#                         time:   [621.05 µs 622.34 µs 624.03 µs]
# Found 8 outliers among 100 measurements (8.00%)
#   1 (1.00%) low severe
#   4 (4.00%) high mild
#   3 (3.00%) high severe

# Benchmarking /test-cdl.typ@bench
# Benchmarking /test-cdl.typ@bench: Warming up for 3.0000 s
# Benchmarking /test-cdl.typ@bench: Collecting 100 samples in estimated 5.0748 s (2100 iterations)
# Benchmarking /test-cdl.typ@bench: Analyzing
# /test-cdl.typ@bench     time:   [2.3803 ms 2.3928 ms 2.4116 ms]
# Found 2 outliers among 100 measurements (2.00%)
#   1 (1.00%) high mild
#   1 (1.00%) high severe