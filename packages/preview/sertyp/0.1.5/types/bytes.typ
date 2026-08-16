#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer = generic.raw_serializer(bytes);

#let deserializer = generic.raw_deserializer(bytes);

#let test(cycle) = {
    cycle(bytes((1,2,3,4,5,76,77,0)));
};