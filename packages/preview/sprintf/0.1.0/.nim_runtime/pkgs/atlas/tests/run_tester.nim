# Small program that runs the test cases

import std / [strutils, os, osproc, sequtils, strformat, unittest]
import basic/context
import integration_test_utils

import integration_tests

infoNow "tester", "All tests run successfully"
