class Sector2d extends Screen {
  private int state_index = 0;
    // transition stage between scenes
  private float[] state_times = new float[] {12.5, 2.5};
    // Linear transition, wait, grow radius, wait
  private float state_time = 0.0;
    // Current time on this state
    
  private float[] entity_transition_times;
    // How long should each item spend moving

  private color[] Colors = {#a6cee3, #1f78b4, #b2df8a, #33a02c, #fb9a99, #e31a1c, #fdbf6f, #ff7f00, #cab2d6, #6a3d9a};
  private IntDict sector_to_index;
  private ArrayList<ArrayList<Entity>> entities_by_sector;

  private ArrayList<entityTransition> transitions = new ArrayList<entityTransition>();

  public Sector2d() {
    super("Sector 2d", 15.0);
      // Duration = Sum of state_times
    this.sector_to_index = new IntDict();
    this.entities_by_sector = new ArrayList<ArrayList<Entity>>();
  }

  void setup(ArrayList<Entity> entities) {
    super.setup(entities);
    for (int i = 0; i < 10; i++) {
      this.entities_by_sector.add(new ArrayList<Entity>());
    }
    
    int industry_index = 0;
    this.screens_next = new Screen[] {new Geography()};
    this.screens_chance = new int[] {100};
    this.entity_transition_times = new float[this.entities.size()];
    for (int i = 0; i < this.entity_transition_times.length; i++) {
      this.entity_transition_times[i] = random(this.state_times[0]);
      String sector = this.entities.get(i).sector;
      if (!this.sector_to_index.hasKey(sector)) {
        this.sector_to_index.set(sector, industry_index);
        industry_index++;
      }
      
      int sector_value = this.sector_to_index.get(sector);
      this.entities_by_sector.get(sector_value).add(this.entities.get(i));
    }

    float delay = 0.0;
    for (int i = 0; i < this.entities_by_sector.size(); i++) {
      transitions.add(new entityTransition(this.entities_by_sector.get(i), delay, 1.05, this.Colors[i]));
      delay += 0.75;
    }
  }

  void update_and_draw(float delta) {
    // Per Industry, color all companies on a delay
    // After an industry is colored, start moving
    super.update(delta);
    ArrayList<entityTransition> toberemoved = new ArrayList<entityTransition>();
    for (entityTransition et : this.transitions) {
      et.update(delta);
      if (et.elapsed / 1000 > et.delay + et.transition + 0.005 * et.entities.size()) {
        toberemoved.add(et);
      }
    }
    
    this.transitions.removeAll(toberemoved);
    // If you are being removed, queue up for next transition
    
    for (int i = 0; i < this.entities.size(); i++) {
      Entity e = this.entities.get(i);
      e.draw();
    }

    this.state_time += delta;
    if (this.state_time / 1000 > this.state_times[this.state_index]) {
      this.state_index++;
      this.state_time = 0.0;
    }
  }

  void teardown() {
      // Sloppy reset for looping demo
    for (Entity e : this.entities) {
      e.radius = 5.0;
      e.x = 0;
      e.y = 0;
    }
  }
}

class entityTransition {
  ArrayList<Entity> entities;
  float delay, elapsed, transition;
  color fillColor;
  
  entityTransition (ArrayList<Entity> entities, float delay, float transition, color fillColor) {
    this.entities = entities;
    this.delay = delay;
    this.elapsed = 0;
    this.transition = transition;
    this.fillColor = fillColor;
  }
  
  void update(float delta) {
    this.elapsed += delta;
    if (this.elapsed / 1000 >= this.delay) {
      for (int i = 0; i < this.entities.size(); i++) {
        Entity e = this.entities.get(i);
        if (this.elapsed / 1000 >= this.delay + 0.005 * i) {
          float t = (this.elapsed / 1000 - this.delay) / (this.transition);
          e.fillColor = lerpColor(#000000, this.fillColor, t);
          //e.strokeColor = lerpColor(#00C8C8, #000000, t);
        }
      }
    }    
  }
}