module Array1 = Bigarray.Array1

type t = (char, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Array1.t

let create =
  Bigarray.(Array1.create Char C_layout)

let length =
  Array1.dim

let get =
  Array1.get

let set =
  Array1.set

let sub buffer ~offset ~length =
  Array1.sub buffer offset length

let blit ~source ~destination =
  Array1.blit source destination

let fill =
  Array1.fill

let unsafe_get =
  Array1.unsafe_get

let unsafe_set =
  Array1.unsafe_set

let blit_to_bytes bigstring bytes ~destination_offset =
  C.Functions.Bigstring.memcpy_to_bytes
    Ctypes.(ocaml_bytes_start bytes +@ destination_offset)
    Ctypes.(bigarray_start array1 bigstring)
    (length bigstring)

let blit_from_bytes bigstring bytes ~source_offset =
  C.Functions.Bigstring.memcpy_from_bytes
    Ctypes.(bigarray_start array1 bigstring)
    Ctypes.(ocaml_bytes_start bytes +@ source_offset)
    (Bytes.length bytes)

let blit_from_string bigstring string ~source_offset =
  blit_from_bytes bigstring (Bytes.unsafe_of_string string) ~source_offset

let to_bytes bigstring =
  let bytes = Bytes.create (length bigstring) in
  blit_to_bytes bigstring bytes ~destination_offset:0;
  bytes

let to_string bigstring =
  Bytes.unsafe_to_string (to_bytes bigstring)

let from_bytes bytes =
  let bigstring = create (Bytes.length bytes) in
  blit_from_bytes bigstring bytes ~source_offset:0;
  bigstring

let from_string string =
  from_bytes (Bytes.unsafe_of_string string)
