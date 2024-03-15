// the format of the data transfer
// the structure
// |--type(1 byte)--|--payload--|--EOF--|
// EOF : 0x00
// type : 
//        0x01 - none
//        0x02 - bool
//        0x03 - type
//        0x04 - int64 
//        0x05 - float64 
//        0x06 - duration
//        0x07 - datetime
//        0x08 - bytes 
//        0x09 - string 
//        0x0A - regex
//        0x0B - array
//        0x0C - dict
// (extended type, not necessarily implemented):
//        0x0D - label 
//        0x0E - selector
//        0x0F - color
//        0x10 - reserved for future type 1
//        0x11 - reserved for future type 2
//        ...
// -----------------------------------
// in payload
// none :    |--data(0 bytes)--|

// type :    |--type_id(1 byte,same as previous type code)--|

// bool :    |--data(1 byte)--|
//            0x00 for false, 0x01 for true

// int64 :   |--data(8 bytes)--|

// datetime :|--year(4 bytes)--|--month(1 byte)--|--day(1 byte)--|
//           |--hour(1 byte)--|--minute(1 byte)--|--second(1 byte)--|

// duration :|--seconds(8 bytes)--|--minutes(8 bytes)--|
//           |--hours(8 bytes)--|--days(8 bytes)--|--weeks(8 bytes)--|

// bytes :   |--len(8 bytes, int64)--|--data(len bytes)--|

// float64/string/label/regex : |--len(8 bytes, int64)--|--data(len bytes)--|

// array :   |--len(8 bytes, int64)--|--elt1_type(1 byte)--|--elt1_payload--|...
//            ...repeat for len elements...

// dict :    |--len(8 bytes, int64)--|--key1_len(4 bytes, int64)--|--key1_data--|
//           |--value1_type(1 byte)--|--value1_payload--|...
//            ...repeat for len pairs...

// selector :|--selector_type(1 byte)--|--selector_payload--|


#let arr2int(arr, byte_order : "big",signed : true) = {
  let sum = 0
  arr = if byte_order != "big" {arr.rev()} else {arr}
  let highest_byte = arr.at(0)

  let is_negative = highest_byte >= 128
  if is_negative and signed {
    arr = arr.map((v)=>255-v)
    arr.at(-1) += 1
    sum = -sum
    for elt in arr {
      sum = sum * 256 - elt
    }
    sum
  }
  else{
    for elt in arr {
      sum = sum * 256 + elt
    }
    sum
  }
}

#let div_remainder(dividend, divisor) = {
  let quotient = int(dividend / divisor)
  let remainder = dividend - (quotient * divisor)
  return remainder
}

#let pow2f(i) = {
  let result = 1
  if i < 0{
    for j in range(0,-i) {
        result = result * 2.0
    }
    result = 1 / result
  }else{
    for j in range(0,i) {
        result = result * 2.0
    }
  }
  
  result
}

#let arr2float(arr, byte_order : "big") = {
  let is_negative = false
  arr =  if byte_order != "big" {arr.rev()} else {arr}
  let highest_byte = arr.at(0)

  is_negative = highest_byte >= 128
  
  let exponent = calc.rem-euclid(highest_byte,128) * 16 + calc.div-euclid(arr.at(1) , 16)
  let new_slice = arr.slice(1)
  new_slice.at(0) = calc.rem-euclid(highest_byte,16)
  let mantissa =  arr2int(new_slice,signed : false)

  if is_negative {-mantissa * calc.pow(2.0, exponent - 1024 - 51) - calc.pow(2.0, exponent - 1024) } else {mantissa * calc.pow(2.0, exponent - 1024 - 51) + calc.pow(2.0, exponent - 1024)}
}

#let type_res = (none,
                true,
                int,
                1,
                1.0,
                datetime(year:2000,month:3,day:3),
                duration(),
                bytes("t"),
                "",
                regex(""),
                (),
                (:)
                ).map(type)


#let deserialize(data) = {
  let _deserialize(data) = {

    let deserialize_none(data) = {
      assert(data.at(0) == 0x01, message: "error when parsing none")
      (none,1)
    }

    let deserialize_bool(data) = {
      assert(data.at(0) == 0x02, message: "error when parsing bool")
      (data.at(1) != 0,2)
    }

    let deserialize_int(data) = {
      assert(data.at(0) == 0x04, message: "error when parsing int")
      (arr2int(array(data.slice(1, count:8))), 9)
    }

    let deserialize_type(data) = {
      assert(data.at(0) == 0x03, message: "error when parsing type")
      let typecode = data.at(1)
      (type_res.at(typecode - 1),2)
    }

    let _deserialize_bytes_without_typecode(data) = {
      let data_len = arr2int(array(data.slice(0,count:8)))
      (data.slice(8,count:data_len),8 + data_len)
    }


    let _deserialize_bytes(data) = {
      let data_len = arr2int(array(data.slice(1,count:8)))
      (bytes(data.slice(9,count:data_len)),9 + data_len)
    }

    let deserialize_bytes(data) = {
      assert(data.at(0) == 0x8,message: "error when parsing bytes")
      _deserialize_bytes(data)
    }

    let bytes2str(data) = {
      assert(data.at(0) in (0x05,0x09,0x0A), message: "type is not string")
      let bytes_r = _deserialize_bytes(data)
      bytes_r.at(0) = str(bytes(bytes_r.at(0)))
      bytes_r
    }
    let deserialize_float(data) = {
      assert(data.at(0) == 0x05, message: "error when parsing float")
      let bytes_r = _deserialize_bytes(data)
      bytes_r.at(0) = float(str(bytes(bytes_r.at(0))))
      bytes_r
    }
    let deserialize_duration(data) = {
      assert(data.at(0) == 0x6,message: "error when parsing duration")
      let seconds = arr2int(array(data.slice(1,count:8)))
      let minutes = arr2int(array(data.slice(9,count:8)))
      let hours = arr2int(array(data.slice(17,count:8)))
      let days = arr2int(array(data.slice(25,count:8)))
      let weeks = arr2int(array(data.slice(33,count:8)))
      (duration(seconds: seconds,
                minutes:minutes,
                hours:hours,
                days:days,
                weeks:weeks),41)
    }


    let deserialize_datetime(data) = {
      assert(data.at(0) == 0x7,message: "error when parsing datetime")
      let datetime_type = data.at(1)
      if datetime_type == 0x1{
        let year = arr2int(array(data.slice(2,count:8)))
        let month = arr2int(array(data.slice(10,count:8)))
        let day = arr2int(array(data.slice(18,count:8)))
        (datetime(year: year,month : month,day :day),26)
      }
      else if datetime_type == 0x2{
        let hour = arr2int(array(data.slice(2,count:8)))
        let minute = arr2int(array(data.slice(10,count:8)))
        let second = arr2int(array(data.slice(18,count:8)))
        (datetime(hour: hour,minute : minute,second :second),26)
      }
      else if datetime_type == 0x3{
        let year = arr2int(array(data.slice(2,count:8)))
        let month = arr2int(array(data.slice(10,count:8)))
        let day = arr2int(array(data.slice(18,count:8)))
        let hour = arr2int(array(data.slice(26,count:8)))
        let minute = arr2int(array(data.slice(34,count:8)))
        let second = arr2int(array(data.slice(42,count:8)))
        (datetime(year: year,month : month,day :day,hour: hour,minute : minute,second :second),50)
      }
      else{
        assert(false,message: "invalid datetime type")
      }
    }


    let deserialize_regex(data) = {
      assert(data.at(0) == 0x0A, message: "error when parsing regex")
      let bytes_r = _deserialize_bytes(data)
      bytes_r.at(0) = regex(str(bytes_r.at(0)))
      bytes_r
    }


    let deserialize_array(data) = {
      assert(data.at(0) == 0x0B, message: "error when parsing array")
      let result_array = ()
      let size = 9
      let length = arr2int(array(data.slice(1,count:8)))
      for i in range(length){
        let new_slice = data.slice(size)
        let r = _deserialize(new_slice)
        result_array.push(r.at(0))
        size += r.at(1)
      }
      (result_array,size)
    }
    let deserialize_dict(data) = {
      assert(data.at(0) == 0x0C, message: "error when parsing dict")
      let result_dict = (:)
      let length = arr2int(array(data.slice(1,count:8)))
      let size = 9
      for i in range(length){
        let new_slice = data.slice(size)
        let key_r = _deserialize_bytes_without_typecode(new_slice)
        let key = str(bytes(key_r.at(0)))
        size += key_r.at(1)
        let r = _deserialize(new_slice.slice(key_r.at(1)))
        result_dict.insert(key, r.at(0))
        size += r.at(1)
      }
      (result_dict,size)
    }

    let type_code = data.at(0)
    let type_arr = (
      (v) => {assert(false,message: "EOF parsed")},
      deserialize_none,
      deserialize_bool,
      deserialize_type,
      deserialize_int,
      deserialize_float,
      deserialize_duration,
      deserialize_datetime,
      deserialize_bytes,
      bytes2str,
      (data) => {
        let r = bytes2str(data)
        r.at(0) = regex(str(bytes(r.at(0))))
        r
      },
      deserialize_array,
      deserialize_dict,
    )

    type_arr.at(type_code,
                default : (data)=>assert(false,message: "not a valid data")
                )(data)
  }
  let data_ = array(data)
  _deserialize(data_).at(0)
}


#let int2arr(value) = {
  let arr = ()
  for i in range(8) {
    let byte = calc.abs(calc.rem-euclid(value, 256))
    arr.push(byte)
    value = calc.div-euclid(value, 256)
  }
  arr.rev()
}


#let _string2bytes(value) = {
  int2arr(value.len()) + array(bytes(value))
}
#let string2bytes(value) = {
  (0x09,) + _string2bytes(value) + (0x00,)
}

// Main serialization functions
#let serialize_none() = {
  (0x01, 0x00)
}
#let serialize_type(data) = {
  let result_pos = type_res.position((val)=> data == val)
  result_pos = result_pos
  if result_pos != none{
    (0x03,calc.rem(result_pos,256) + 1,0x00)
  }else{
    assert(false,message: "unsupport type")
  }
  
}

#let serialize_bool(value) = {
  (0x02, int(value), 0x00)
}

#let serialize_int(value) = {
  (0x04,) + int2arr(value) + (0x00,)
}

#let serialize_float(value) = {
  value = str(value)
  (0x05,) + _string2bytes(value) + (0x00,)
}

#let serialize_datetime(dt) = {
  
  let d = eval(repr(dt).slice(8))
  let datetime_type = 0
  let result = ()
  if d.at("day",default:none) != none{
    datetime_type += 1
    result += int2arr(d.at("year"))
    result += int2arr(d.at("month"))
    result += int2arr(d.at("day"))
  }
  if d.at("second",default:none) != none{
    datetime_type += 2
    result += int2arr(d.at("hour"))
    result += int2arr(d.at("minute"))
    result += int2arr(d.at("second"))
  }
  assert(datetime_type != 0,message: "datetime not valid")
  (0x07, calc.rem(datetime_type,256)) +result+(0x00,)
}

#let serialize_duration(dur) = {
  // this code is too tricky
  let seconds = dur.seconds()
  let d = eval(repr(dur).slice(8))
  if seconds == 0{
    d = (:)
  }
  let middle = (d.at("seconds",default:0),
                d.at("minutes",default:0),
                d.at("hours",default:0),
                d.at("days",default:0),
                d.at("weeks",default:0)).map(int2arr).join()

  (0x06,) + middle + (0x00,)
}

#let serialize_bytes(bytes) = {
  (0x08,) + _string2bytes(bytes) + (0x00,)
}

#let serialize_string(value) = {
  (0x09,) + _string2bytes(value) + (0x00,)
}

#let serialize_regex(reg) = {
  let s = (repr(reg).match(regex("\"(.*)\"")).captures.at(0))
  (0x0A,) + _string2bytes(s) + (0x00,)
}

#let serialize_array(arr) = {
  let _serialize(value) = {
    if type(value) == type(none) {
      serialize_none()
    } else if type(value) == type(true) {
      serialize_bool(value)
    } else if type(value) == int {
      serialize_int(value)
    } else if type(value) == float {
      serialize_float(value)
    } else if type(value) == datetime {
      serialize_datetime(value)
    } else if type(value) == duration {
      serialize_duration(value)
    } else if type(value) == bytes {
      serialize_bytes(value)
    } else if type(value) == type("") {
      serialize_string(value)
    } else if type(value) == regex {
      serialize_regex(value)
    } else if type(value) == array {
      serialize_array(value)
    } else if type(value) == dictionary {
      serialize_dict(value)
    } else if type(value) == type{
      serialize_type(value)
    }
    else {
      assert(false, message: "Unsupported type for serialization")
    }
  }

  let len = arr.len()
  let serialized_array = int2arr(len)
  let r = (0x0B,) + serialized_array
  for elt in arr {
    let serialized_elt = _serialize(elt)
    let _ = serialized_elt.pop()
    r +=  serialized_elt
  }
  r += (0x00,)
  r
}

#let serialize_dict(dict) = {
  let _serialize(value) = {
    if type(value) == type(none) {
      serialize_none()
    } else if type(value) == type(true) {
      serialize_bool(value)
    } else if type(value) == int {
      serialize_int(value)
    } else if type(value) == float {
      serialize_float(value)
    } else if type(value) == datetime {
      serialize_datetime(value)
    } else if type(value) == duration {
      serialize_duration(value)
    } else if type(value) == bytes {
      serialize_bytes(value)
    } else if type(value) == type("") {
      serialize_string(value)
    } else if type(value) == regex {
      serialize_regex(value)
    } else if type(value) == array {
      serialize_array(value)
    } else if type(value) == dictionary {
      serialize_dict(value)
    } else if type(value) == type{
      serialize_type(value)
    }
    else {
      assert(false, message: "Unsupported type for serialization")
    }
  }
  let len = dict.len()
  let serialized_dict = int2arr(len)
  let r = (0x0C,) + serialized_dict
  for pair in dict {
    let key = pair.at(0)
    let value = pair.at(1)

    let serialized_key = _string2bytes(key)
    let serialized_value = _serialize(value)
    let _ = serialized_value.pop()
    r += serialized_key + serialized_value
  }
  r += (0x00,)
  r
}


// Main serialize function that dispatches to specific type serialization
#let serialize(value) = {
  let result = if type(value) == type(none) {
    serialize_none()
  } else if type(value) == type(true) {
    serialize_bool(value)
  } else if type(value) == int {
    serialize_int(value)
  } else if type(value) == float {
    serialize_float(value)
  } else if type(value) == datetime {
    serialize_datetime(value)
  } else if type(value) == duration {
    serialize_duration(value)
  } else if type(value) == bytes {
    serialize_bytes(value)
  } else if type(value) == type("") {
    serialize_string(value)
  } else if type(value) == regex {
    serialize_regex(value)
  } else if type(value) == array {
    serialize_array(value)
  } else if type(value) == dictionary {
    serialize_dict(value)
  } else if type(value) == type{
    serialize_type(value)
  }
  else {
    assert(false, message: "Unsupported type for serialization")
  }
  bytes(result)
}
