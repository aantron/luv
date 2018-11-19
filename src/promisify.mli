include module type of Promisify_signatures

module With_promise_type :
  functor (P : PROMISE) -> PROMISIFIED with type 'a promise := 'a P.promise
