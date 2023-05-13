import Text "mo:base/Text";
import Bool "mo:base/Bool";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";

actor HomeworkDiary {
    public type Homework = {
        title : Text;
        description : Text;
        dueDate : Time.Time;
        completed : Bool;
    };

    var homeworkId = 0;
    let homeworkDiary = HashMap.HashMap<Nat, Homework>(1, Nat.equal, Hash.hash);

    // Agregar nueva tarea.
    public shared func addHomework(homework : Homework) : async Nat {
        homeworkId := homeworkId +1;
        homeworkDiary.put(homeworkId, homework);
        return homeworkDiary.size() - 1;
    };

    // Obtener una tarea específica por id.
    public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
        let hm = homeworkDiary.get(id);
        switch (hm) {
            case (null) {
                #err "No get homework!";
            };
            case (?homework) {
                #ok homework;
            };
        };
    };

    // Actualizar el título, descripción y/o fecha de vencimiento de una tarea.
    public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
        let hm = homeworkDiary.get(id);
        switch (hm) {
            case (null) {
                #err "No put homework!";
            };
            case (?home) {
                homeworkDiary.put(id, homework);
                #ok();
            };
        };
    };

    // Marcar tarea como completada.
    public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
        let hm = homeworkDiary.get(id);
        switch (hm) {
            case (null) {
                #err "No put mark as completed in homework!";
            };
            case (?home) {
                let new : Homework = {
                    title = home.title;
                    description = home.description;
                    dueDate = home.dueDate;
                    completed = true;
                };
                homeworkDiary.put(id, new);
                #ok();
            };
        };
    };

    // Eliminar tarea por id.
    public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
        let hm = homeworkDiary.get(id);
        switch (hm) {
            case (null) {
                #err "No delete homework!";
            };
            case (_) {
                homeworkDiary.delete(id);
                #ok ();
            };
        };
    };

    // Obtener lista de todas las tareas.
    public shared query func getAllHomework() : async [Homework] {
        return Iter.toArray(homeworkDiary.vals());
    };

    // Obtener lista de tarea listas (No completadas).
    public shared query func getPendingHomework() : async [Homework] {
        func checkCompletado(value : Homework) : Bool {
            return value.completed;
        };
        let filterData = Iter.filter(homeworkDiary.vals(), checkCompletado);
        return Iter.toArray(filterData);
    };

    // Buscar tareas en base a términos de búsqueda.
    public shared query func searchHomework(searchTerm : Text) : async [Homework] {
        func checkSearch(value : Homework) : Bool {
            let texto : Text.Pattern = #text searchTerm;
            return Text.contains(value.title, texto) or Text.contains(value.description, texto);
        };
        let filterData = Iter.filter(homeworkDiary.vals(), checkSearch);
        return Iter.toArray(filterData);
    };
};