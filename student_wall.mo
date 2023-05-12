import Text "mo:base/Text";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
actor StudentWall {
    public type Content = {
        #Text : Text;
        #Image : Blob;
        #Video : Blob;
    };
    var messageId = 0;
    let wall = HashMap.HashMap<Nat, Message>(1, Nat.equal, Nat.hash);
    public type Message = {
        var vote : Int;
        var content : Content;
        creator : Principal;
    };

    // Add a new message to the wall
    public shared ({ caller }) func writeMessage(c : Content) : async Nat {
        var message : Message = {
            var vote = 0;
            var content = c;
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
                if (m.creator == caller) {
                    m.content := c;
                    wall.put(messageId, m);
                    #ok(m);
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
        var message = wall.delete(messageId);
        switch (message) {
            case (?m) {
                #ok()

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
                m.vote := m.vote +1;
                wall.put(messageId, m);
                #ok()

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
                m.vote := m.vote -1;
                wall.put(messageId, m);
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
        return Iter.toArray<(Message)>(wall.vals());
    };
};

