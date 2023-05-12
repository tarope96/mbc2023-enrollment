import Text "mo:base/Text";
import Bool "mo:base/Bool";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";

actor HomeworkDiary {
    type Homework = {
        titulo : Text;
        descripcion : Text;
        fechaVencimiento : Time.Time;
        completado : Bool;
    };
    let homeworkDiary = Buffer.Buffer<Homework>(1);

    // Agregar nueva tarea.
    public shared func addHomework(homework : Homework) : async Nat {
        homeworkDiary.add(homework);
        return homeworkDiary.size() - 1;
    };

    // Obtener una tarea específica por id.
    public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
        let hm = homeworkDiary.getOpt(id);
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
        let hm = homeworkDiary.getOpt(id);
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
        let hm = homeworkDiary.getOpt(id);
        switch (hm) {
            case (null) {
                #err "No put mark as completed in homework!";
            };
            case (?home) {
                let new : Homework = {
                    titulo = home.titulo;
                    descripcion = home.descripcion;
                    fechaVencimiento = home.fechaVencimiento;
                    completado = true;
                };
                homeworkDiary.put(id, new);
                #ok();
            };
        };
    };

    // Eliminar tarea por id.
    public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
        let hm = homeworkDiary.getOpt(id);
        switch (hm) {
            case (null) {
                #err "No delete homework!";
            };
            case (_) {
                homeworkDiary.remove(id);
                #ok();
            };
        };
    };

    // Obtener lista de todas las tareas.
    public shared query func getAllHomework() : async [Homework] {
        return Buffer.toArray(homeworkDiary);
    };

    // Obtener lista de tarea listas (No completadas).
    public shared query func getPendingHomework() : async [Homework] {
        func checkCompletado(index : Nat, value : Homework) : Bool {
            return value.completado;
        };
        let clone = Buffer.clone(homeworkDiary);
        clone.filterEntries(checkCompletado);
        return Buffer.toArray(clone);
    };

    // Buscar tareas en base a términos de búsqueda.
    public shared query func searchHomework(searchTerm : Text) : async [Homework] {
        func checkSearch(index : Nat, value : Homework) : Bool {
            let letter : Text.Pattern = #text searchTerm;
            return Text.contains(value.titulo, letter) or Text.contains(value.descripcion, letter);
        };
        let clone = Buffer.clone(homeworkDiary);
        clone.filterEntries(checkSearch);
        return Buffer.toArray(clone);
    };
};
