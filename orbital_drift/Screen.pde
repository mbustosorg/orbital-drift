
abstract class Screen {
  String name;
    // Title
  float duration;
    // Total seconds screen will be displayed

  protected ArrayList<Entity> entities;
    // Our main items to transition between Screens
  float elapsed = 0;
    // Seconds screen has been displayed
  protected Screen[] screens_next;
    // Screens that are next
  protected int[] screens_chance;
    // Chance for transition to be selected, sum to 100

  Screen(String name, float duration) {
    this.name = name;
    this.duration = duration;
  }

  boolean is_time_elapsed() {
    return this.elapsed / 1000 >= this.duration;
  }

  void setup(ArrayList<Entity> entities) {
    this.entities = entities; 
  }

  abstract void update_and_draw(float delta);
  
  void update(float delta){
    elapsed += delta;
  }
  
  void draw() {
    for (Entity e : this.entities) {
      e.draw();
    }
  }

  void teardown() {
  }

  void keyPressed() {
  }
  
  Screen screen_next() {
     float chance = random(100);
     int chance_total = 0;
     for (int i = 0; i < screens_chance.length; i++) {
       int c = screens_chance[i];
       if (chance > chance_total && chance < chance_total + c) {
         return screens_next[i];
       }

       chance_total += c;
     }

     return null;
  }
}