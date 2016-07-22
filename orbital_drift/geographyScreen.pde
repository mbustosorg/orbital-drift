class Geography extends Screen {
  private int state_index = 0;
    // transition stage between scenes
  private float[] state_times = new float[] {7.5, 0.75, 3.0, 2.0};
    // Linear transition, wait, grow radius, wait
  private float state_time = 0.0;
    // Current time on this state
    
  private float[] entity_transition_times;
    // How long should each item spend moving
    
  public Geography() {
    super("Geography", 13.25);
      // Duration = Sum of state_times
  }

  void setup(ArrayList<Entity> entities) {
    super.setup(entities);
    this.screens_next = new Screen[] {new Sector2d()};
    this.screens_chance = new int[] {100};
    this.entity_transition_times = new float[this.entities.size()];
    for (int i = 0; i < this.entity_transition_times.length; i++) {
      this.entity_transition_times[i] = random(this.state_times[0] * 0.45);
    }
  }

  void update_and_draw(float delta) {
    super.update(delta);
    for (int i = 0; i < this.entities.size(); i++) {
      Entity e = this.entities.get(i);
      if (this.state_index == 0) {
        // MOVE
        float x = 0;
        if (e.longitude < -60) {
          x = map(e.longitude, -124, -60, 0, width * 0.65);
        } else {
          x = map(e.longitude, -20, 9, width * 0.75, width);
        }
    
        // leave 10% x for the ocean, remove the rest
        float y = map(e.latitude, 54, 12, 0, height);
        EntityTransitions.linear_interpolation_2d(e, x, y, this.entity_transition_times[i], this.state_time, this.state_times[this.state_index]);
      } else if (this.state_index == 2) {
        // Grow
        e.radius = 5.0 + (e.capitalization - 5.0) * this.state_time / 1000 / this.state_times[this.state_index];
      } else if (this.state_index == 3) {
        // Fade out
        stroke(0, 200, 200, 255 - 255 * this.state_time / 1000 / this.state_times[this.state_index]);
      }

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