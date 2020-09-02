/// Unit testing for canisters
///
/// The `Tester` class in this module can be used to define unit tests for canisters.
import Buffer "mo:base/Buffer";
import List "mo:base/List";
import M "Matchers";

module {

public type Protocol = { #start : Nat; #cont : [Text]; #done : [Text] };
public type TestResult = { #success; #fail : Text };

type Test = (Text, () -> async TestResult);

/// Instantiate one of these on canister initialization. Then you can use it to
/// register your tests and it will take care of executing them in the right
/// batch sizes. The test runner will keep calling your `test` function over and
/// over, so make sure to not do any work outside the registered tests.
///
/// ```motoko
/// import Canister "canister:YourCanisterNameHere";
/// import C "mo:matchers/Canister";
/// import M "mo:matchers/Matchers";
/// import T "mo:matchers/Testable";
///
/// actor {
///     let it = C.Tester({ batchSize = 8 });
///     public shared func test() : async C.Protocol {
///
///         it.should("greet me", func () : async C.TestResult = async {
///           let greeting = await Canister.greet("Christoph");
///           M.attempt(greeting, M.equals(T.text("Hello, Christoph!")))
///         });
///
///         it.shouldFailTo("greet him-whose-name-shall-not-be-spoken", func () : async () = async {
///           let greeting = await Canister.greet("Voldemort");
///           ignore greeting
///         });
///
///         await it.run()
///     }
/// }
/// ```
public class Tester({ batchSize : Nat }) {
    var tests : List.List<Test> = List.nil();
    var running : Bool = false;

    /// Registers a test. You can use [`attempt`](Matchers.html/#value.attempt)
    /// to use a [`Matcher`](Matchers.html/#type.Matcher) to produce a
    /// [`TestResult`](#type.TestResult).
    public func should(name : Text, test : () -> async TestResult) {
        if(running) return;
        tests := List.push((name, test), tests);
    };

    /// Registers a test that should throw an exception.
    public func shouldFailTo(name : Text, test : () -> async ()) {
        if(running) return;
        tests := List.push((name, func () : async TestResult = async {
          try {
            let testResult = await test();
            #fail("Should've failed, but didn't")
          } catch _ {
              #success
          }
        }), tests)
    };

    /// You must call this as the last thing in your unit test.
    public func run() : async Protocol {
        if (not running) {
            running := true;
            tests := List.reverse(tests);
            return #start(List.size(tests))
        };
        let results : Buffer.Buffer<Text> = Buffer.Buffer(batchSize);
        var capacity = batchSize;
        while(capacity > 0) {
            capacity -= 1;
            switch tests {
                case null {
                    return #done(results.toArray())
                };
                case (?((name, test), tl)) {
                    tests := tl;
                    try {
                        let testResult = await test();
                        results.add(switch testResult {
                          case (#success) "\"" # name # "\"" # " succeeded.\n";
                          case (#fail(msg)) "\"" # name # "\"" # " failed: " # msg # "\n";
                        });
                    } catch _ {
                        results.add("\"" # name # "\"" # "failed with an unexpected trap." # "\n");
                    }
                }
            }
        };
        return if(List.isNil(tests)) {
            #done(results.toArray());
        } else {
            #cont(results.toArray());
        };
    }
}
}
