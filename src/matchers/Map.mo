/// Matchers for core/Map
///
/// This module contains utility matchers that make it easier
/// to write assertions that involve core/Map.

import Map "mo:core/Map";
import M "../Matchers";
import Option "mo:core/Option";
import T "../Testable";
import Order "mo:core/Order"

module {

  /// Tests that a HashMap contains a key
  public func hasKey<K, V>(compare : (K, K) -> Order.Order, key : T.TestableItem<K>) : M.Matcher<Map.Map<K, V>> = {
    matches = func(map : Map.Map<K, V>) : Bool = Option.isSome(Map.get(map, compare, key.item));
    describeMismatch = func(map : Map.Map<K, V>, description : M.Description) {
      description.appendText("Missing key " # key.display(key.item));
    };
  };

  /// Tests that a HashMap matches at a given key
  public func atKey<K, V>(compare : (K, K) -> Order.Order, key : T.TestableItem<K>, matcher : M.Matcher<V>) : M.Matcher<Map.Map<K, V>> = {
    matches = func(map : Map.Map<K, V>) : Bool = Option.getMapped(Map.get(map, compare, key.item), matcher.matches, false);
    describeMismatch = func(map : Map.Map<K, V>, description : M.Description) {
      switch (Map.get(map, compare, key.item)) {
        case null {
          description.appendText("Missing key " # key.display(key.item));
        };
        case (?v) {
          matcher.describeMismatch(v, description);
        };
      };
    };
  };
};
