use aiken/builtin

pub type Datum {
  Constr0
  Constr1(Int)
  Constr2 { field_1: ByteArray, field_2: Bool }
}

test choose_data() {
  is_valid_([Pair(0, 1)])
}

fn constr_data_to_datum(constr: Data) -> Datum {
  let Pair(i, ds) = builtin.un_constr_data(constr)
  when (i, ds) is {
    (0, []) -> Constr0
    (1, [d]) -> {
      expect i: Int = d
      Constr1(i)
    }
    (2, [d1, d2]) -> {
      expect field_1: ByteArray = d1
      expect field_2: Bool = d2
      Constr2(field_1, field_2)
    }
    _ -> fail
  }
}

fn when_constr(cd: Data) -> Bool {
  when constr_data_to_datum(cd) is {
    Constr0 -> True
    Constr1(i) -> i == 1
    Constr2 { field_2, .. } -> field_2
  }
}

fn when_map(md: Data) -> Bool {
  expect [Pair(k, v)] = builtin.un_map_data(md)

  expect 0 = k
  expect 1 = v
  True
  // Or,
  // ```
  // expect a: Int = k
  // expect b: Int = v
  //
  // a == 0 && b == 1
  // ```
  //
  // Alternatively, you can use the `and` block:
  // ```
  // and {
  //   a == 0,
  //   b == 1,
  // }
  // ```
}

fn when_list(ld: Data) -> Bool {
  when builtin.un_list_data(ld) is {
    [] -> True
    [tuple] -> {
      expect (i, bs): (Int, List<ByteArray>) = tuple
      i == 0 && bs == [#"01"]
    }
    _ -> False
  }
}

fn when_int(id: Data) -> Bool {
  builtin.un_i_data(id) == 1
}

fn when_bytearray(bd: Data) -> Bool {
  when builtin.un_b_data(bd) is {
    "1" | #"01" -> True
    _ -> False
  }
}

pub fn is_valid_(datum: Data) -> Bool {
  builtin.choose_data(
    datum,
    when_constr(datum),
    when_map(datum),
    when_list(datum),
    when_int(datum),
    when_bytearray(datum),
  )
}
