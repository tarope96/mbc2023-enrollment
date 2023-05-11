import Float "mo:base/Float";
actor Calculator {
    var counter : Float = 0;

    public shared func add(x : Float) : async Float {
        counter := (counter + x);
        return counter;
    };
    public shared func sub(x : Float) : async Float {
        counter := (counter - x);
        return counter;
    };
    public shared func mul(x : Float) : async Float {
        counter := (counter * x);
        return counter;
    };
    public shared func div(x : Float) : async Float {
        if (x == 0) {
            return 0;
        };
        counter := (counter / x);
        return counter;
    };
    public shared func reset() : async () {
        counter := 0;
    };
    public shared query func see() : async Float {
        return counter;
    };
    public shared func power(x : Float) : async Float {
        counter := (counter ** x);
        return counter;
    };
    public shared func sqrt() : async Float {
        return Float.sqrt(counter)
    };
    public shared func floor() : async Int {
        return Float.toInt(Float.floor(counter));
    };
};
