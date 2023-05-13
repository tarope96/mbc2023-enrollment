import Text "mo:base/Text";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Order "mo:base/Order";
import Bool "mo:base/Bool";
import Hash "mo:base/Hash";

actor StudentWall {
    public type Content = {
        #Text : Text;
        #Image : Blob;
        #Video : Blob;
    };
    var messageId = 0;
    let wall = HashMap.HashMap<Nat, Message>(1, Nat.equal, Hash.hash);
    public type Message = {
        vote : Int;
        content : Content;
        creator : Principal;
    };

    // Add a new message to the wall
    public shared ({ caller }) func writeMessage(c : Content) : async Nat {
        let message : Message = {
            vote = 0;
            content = c;
            creator = caller;
        };
        messageId := messageId +1;
        wall.put(messageId, message);
        return messageId;
    };

    //Get a specific message by ID
    public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
        var message = wall.get(messageId);
        switch (message) {
            case (?m) {
                #ok(m);
            };
            case (null) {
                #err("MessageId Invalid");
            };
        };
    };

    // Update the content for a specific message by ID
    public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
        var message = wall.get(messageId);
        switch (message) {
            case (?m) {
                if (Principal.equal(m.creator, caller)) {
                    let ms : Message = {
                        vote = m.vote;
                        content = c;
                        creator = m.creator;
                    };
                    wall.put(messageId, ms);
                    #ok();
                } else {
                    #err("MessageId Invalid");
                };

            };
            case (null) {
                #err("MessageId Invalid");
            };
        };
    };

    //Delete a specific message by ID
    public shared func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
        var message = wall.remove(messageId);
        switch (message) {
            case (?m) {
                #ok();
            };
            case (null) {
                #err("MessageId Invalid");
            };
        };
    };

    // Voting
    public shared func upVote(messageId : Nat) : async Result.Result<(), Text> {
        var message = wall.get(messageId);
        switch (message) {
            case (?m) {
                let ms : Message = {
                    vote = m.vote +1;
                    content = m.content;
                    creator = m.creator;
                };
                wall.put(messageId, ms);
                #ok();

            };
            case (null) {
                #err("MessageId Invalid");
            };
        };
    };
    public shared func downVote(messageId : Nat) : async Result.Result<(), Text> {
        var message = wall.get(messageId);
        switch (message) {
            case (?m) {
                let ms : Message = {
                    vote = m.vote -1;
                    content = m.content;
                    creator = m.creator;
                };
                wall.put(messageId, ms);
                #ok()

            };
            case (null) {
                #err("MessageId Invalid");
            };
        };
    };

    //Get all messages
    public shared query func getAllMessages() : async [Message] {
        return Iter.toArray<(Message)>(wall.vals());
    };

    //Get all messages
    public shared query func getAllMessagesRanked() : async [Message] {
        func compareMessage(m1 : Message, m2 : Message) : Order.Order {
            return Int.compare(m1.vote, m2.vote);
        };
        let values = Iter.sort<(Message)>(wall.vals(), compareMessage);
        return Iter.toArray<(Message)>(values);
    };
};
