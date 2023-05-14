import Result "mo:base/Result";
import Bool "mo:base/Bool";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Blob "mo:base/Blob";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
actor Verifier {
    public type StudentProfile = {
        name : Text;
        team : Text;
        graduate : Bool;
    };
    let studentProfileStore = HashMap.HashMap<Principal, StudentProfile>(0, Principal.equal, Principal.hash);

    public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
        if (Principal.isAnonymous(caller)) {
            return #err "You must be Logged In";
        };

        let student = studentProfileStore.get(caller);
        switch (student) {
            case (null) {
                studentProfileStore.put(caller, profile);
                #ok();
            };
            case (?value) {
                #err("Student found");
            };
        };
    };

    public query ({ caller }) func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
        if (Principal.isAnonymous(caller)) {
            return #err "You must be Logged In";
        };
        
        let student = studentProfileStore.get(p);
        switch (student) {
            case (?value) {
                #ok(value);
            };
            case (null) {
                #err("Student not found");
            };
        };
    };

    public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
        if (Principal.isAnonymous(caller)) {
            return #err "You must be Logged In";
        };

        let student = studentProfileStore.get(caller);
        switch (student) {
            case (?value) {
                ignore studentProfileStore.replace(caller, profile);
                #ok();
            };
            case (null) {
                #err("Student not found");
            };
        };
    };

    public shared ({ caller }) func deleteMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
        if (Principal.isAnonymous(caller)) {
            return #err "You must be Logged In";
        };

        let student = studentProfileStore.get(caller);
        switch (student) {
            case (?value) {
                studentProfileStore.delete(caller);
                #ok();
            };
            case (null) {
                #err("Student not found");
            };
        };
    };

    //Parte 2
    public type TestResult = Result.Result<(), TestError>;
    public type TestError = {
        #UnexpectedValue : Text;
        #UnexpectedError : Text;
    };
    public shared func test(canisterId : Principal) : async TestResult {
        try {
            let invoiceCalculator : actor {
                add : shared (x : Nat) -> async Int;
                sub : shared (x : Nat) -> async Int;
                reset : shared () -> async Int;
            } = actor (Principal.toText(canisterId));
            let x1 : Int = await invoiceCalculator.reset();
            if (x1 != 0) {
                return #err(#UnexpectedValue("After a reset, counter should be 0!"));
            };

            let x2 : Int = await invoiceCalculator.add(2);
            if (x2 != 2) {
                return #err(#UnexpectedValue("After 0 + 2, counter should be 2!"));
            };

            let x3 : Int = await invoiceCalculator.sub(2);
            if (x3 != 0) {
                return #err(#UnexpectedValue("After 2 - 2, counter should be 0!"));
            };

            return #ok();

        } catch (e) {
            #err(#UnexpectedError "not implemented");
        };
    };

    //Parte 3
    public type CanisterId = Principal;
    public type CanisterSettings = {
        controllers : [Principal];
        compute_allocation : Nat;
        memory_allocation : Nat;
        freezing_threshold : Nat;
    };
    let invoiceManagementCanister : actor {
        canister_status : { canister_id : Principal } -> async {
            controllers : [Principal];
        };
    } = actor ("aaaaa-aa");

    public func getCanisterControllers(canisterId : Principal) : async [Principal] {
        try {
            let status = await invoiceManagementCanister.canister_status({
                canister_id = canisterId;
            });
            return status.controllers;
        } catch (e) {
            return parseControllersFromCanisterStatusErrorIfCallerNotController(Error.message(e));
        };
    };

    private func parseControllersFromCanisterStatusErrorIfCallerNotController(errorMessage : Text) : [Principal] {
        let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
        let words = Iter.toArray(Text.split(lines[1], #text(" ")));
        var i = 2;
        let controllers = Buffer.Buffer<Principal>(0);
        while (i < words.size()) {
            controllers.add(Principal.fromText(words[i]));
            i += 1;
        };
        return Buffer.toArray<Principal>(controllers);
    };

    public shared func verifyOwnership(canisterId : Principal, principalId : Principal) : async Bool {
        try {
            let canister = await getCanisterControllers(canisterId);
            let principal = Array.find<Principal>(canister, func x = Principal.equal(x, principalId));
            switch (principal) {
                case (?value) {
                    return true;
                };
                case (null) {
                    return false;
                };
            };
        } catch (e) {
            return false;
        };
    };

    //Parte 4
    public shared func verifyWork(canisterId : Principal, principalId : Principal) : async Result.Result<(), Text> {
        try {
            let isApproved = await test(canisterId);
            if (isApproved != #ok) {
                return #err("The current work has no passed the tests");
            };
            let isOwner = await verifyOwnership(canisterId, principalId);
            if (not isOwner) {
                return #err("The received work owner does not match with the received principal");
            };
            var xProfile : ?StudentProfile = studentProfileStore.get(principalId);
            switch (xProfile) {
                case null {
                    return #err("The received principal does not belongs to a registered student");
                };
                case (?profile) {
                    var updatedStudent = {
                        name = profile.name;
                        graduate = true;
                        team = profile.team;
                    };
                    ignore studentProfileStore.replace(principalId, updatedStudent);
                    return #ok();
                };
            };
        } catch (e) {
            return #err("Cannot verify the project");
        };
    };
};
