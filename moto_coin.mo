import TrieMap "mo:base/TrieMap";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import List "mo:base/List";
import AssocList "mo:base/AssocList";
import Option "mo:base/Option";
actor MotoCoin {

    type Subaccount = Blob;
    type Account = {
        owner : Principal;
        subaccount : ?Subaccount;
    };

    func accountEqual(x : Account, y : Account) : Bool {
        Principal.equal(x.owner, y.owner);
    };

    func accountHash(x : Account) : Hash.Hash { Principal.hash(x.owner) };

    let ledger = TrieMap.TrieMap<Account, Nat>(accountEqual, accountHash);
    let invoiceCanister : actor {
        getAllStudentsPrincipal : shared () -> async [Principal];
    } = actor ("rww3b-zqaaa-aaaam-abioa-cai");

    // Returns the name of the token
    public shared query func name() : async Text {
        return "MotoCoin";
    };

    // Returns the symbol of the token
    public shared query func symbol() : async Text {
        return "MOC";
    };

    // Returns the the total number of tokens on all accounts
    public shared query func totalSupply() : async Nat {
        return ledger.size();
    };

    // Returns the default transfer fee
    public shared query func balanceOf(account : Account) : async (Nat) {
        let lg = ledger.get(account);
        switch (lg) {
            case (null) {
                return 0;
            };
            case (?value) {
                return value;
            };
        };
    };

    // Transfer tokens to another account
    public shared func transfer(from : Account, to : Account, amount : Nat) : async Result.Result<(), Text> {
        let lg = ledger.get(from);
        switch (lg) {
            case (?fromValue) {
                if (fromValue < amount) {
                    #err("Amount insuficiente");
                } else {
                    ledger.put(from, fromValue - amount);
                    let toLg = ledger.get(to);
                    switch (toLg) {
                        case (?toValue) {
                            ledger.put(to, toValue + amount);
                            #ok();
                        };
                        case (null) {
                            #err("To account Invalid");
                        };
                    };
                };

            };
            case (null) {
                #err("From account Invalid");
            };
        };
    };

    // Airdrop 1000 MotoCoin to any student that is part of the Bootcamp.
    public shared ({ caller }) func airdrop() : async Result.Result<(), Text> {
        let fromAccount : Account = {
            owner = Principal.fromActor(actor ("rww3b-zqaaa-aaaam-abioa-cai"));
            subaccount = null;
        };
        ledger.put(fromAccount, 1000000000000);
        let invoice = await invoiceCanister.getAllStudentsPrincipal();
        if (invoice.size() > 0) {
            for (r in invoice.vals()) {
                let toAccount : Account = {
                    owner = r;
                    subaccount = null;
                };
                ledger.put(toAccount, 0);
                switch (await transfer(fromAccount, toAccount, 100)) {
                    case (#ok()) {};
                    case (#err(msg)) {};
                };
            };
            #ok();
        } else {
            #err("No found Student");
        };
    };

};
