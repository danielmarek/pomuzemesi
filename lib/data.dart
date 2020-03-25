import 'dart:math';
import 'model.dart';
import 'testdata.dart';

// NOTE: This fakes a layer that will in the future communicate with the backend.

class Data {
  static List<Organization> organizations;
  static List<Volunteer> volunteers;
  static List<Task> tasks;
  static List<Skill> skills;
  static Volunteer me;

  // Overen organizaci
  static bool authorized = false;
  static bool getNotifications = true;

  static void assignTask(int id, bool assign) {
    tasks[id].isMine = assign;
    if (assign) {
      tasks[id].volunteersBooked++;
    } else {
      tasks[id].volunteersBooked--;
    }
  }

  static void saveMyProfile(Volunteer newMe) {
    me = newMe;
  }

  static List<Task> myTasks() {
    return tasks.where((t) => t.isMine).toList();
  }

  static List<Task> mySpecTasks() {
    return tasks.where((t) => Data.iCanDoTask(t)).toList();
  }

  static List<Task> allTasks() {
    return tasks;
  }

  static bool iHaveSkill(Skill skill) {
    return me.skillIDs.contains(skill.id);
  }

  static bool iCanDoTask(Task task) {
    return iHaveSkill(task.skillRequired);
  }

  static void toggleSkill(int skillID) {
    if (me.skillIDs.contains(skillID)) {
      me.skillIDs.remove(skillID);
    } else {
      me.skillIDs.add(skillID);
    }
  }

  static void toggleNotifications() {
    getNotifications = !getNotifications;
  }

  static void initWithRandomData() {
    organizations = ORGANIZATIONS;
    skills = SKILLS;
    Random r = Random();
    int seed = r.nextInt(1000);
    me = getRandomVolunteer(seed: seed);
    tasks = List<Task>();
    volunteers = List<Volunteer>();
    int taskCount = 20 + r.nextInt(10);
    for (int i = 0; i < taskCount; i++) {
      tasks.add(getRandomTask(seed: seed + i, isMine: i == 0, id: i));
    }
    for (int i = 0; i < 10; i++) {
      volunteers.add(getRandomVolunteer(seed: seed + i + 1));
    }
  }
}
