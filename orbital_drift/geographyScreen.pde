class Geography extends Screen {
  private int state_index = 0;
    // transition stage between scenes
  private float[] state_times = new float[] {10.5, 0.75, 3.0, 2.0};
    // Linear transition, wait, grow radius, wait
  private float state_time = 0.0;
    // Current time on this state
  private float WorldRadius = 400.0;
  private float pivot = 0.0;
  private float PivotStep = -0.00001;
    
  private float[] entity_transition_times;
    // How long should each item spend moving
    
  public Geography() {
    super("Geography", 16.25);
      // Duration = Sum of state_times
  }

  void setup(ArrayList<Entity> entities) {
    super.setup(entities);
    this.screens_next = new Screen[] {new Sector2d()};
    this.screens_chance = new int[] {100};
    this.entity_transition_times = new float[this.entities.size()];
    for (int i = 0; i < this.entity_transition_times.length; i++) {
      this.entity_transition_times[i] = random(3.0);
    }
  }

  void update_and_draw(float delta) {
    super.update(delta);
    for (int i = 0; i < this.entities.size(); i++) {
      Entity e = this.entities.get(i);
      if (this.state_index == 0) {
        // MOVE
        float latitude = e.latitude * PI / 180.0;
        float longitude = e.longitude * PI / 180.0;
        float x = -WorldRadius * cos(latitude) * cos(longitude);
        float y = -WorldRadius * sin(latitude);
        float z = WorldRadius * cos(latitude) * sin(longitude);
        
        //if (e.longitude < -60) {
        //  x = map(e.longitude, -124, -60, 0, width * 0.65);
        //} else {
        //  x = map(e.longitude, -20, 9, width * 0.75, width);
        //}
        // leave 10% x for the ocean, remove the rest
        //float y = map(e.latitude, 54, 12, 0, height);
        //float z = 0.0;
        //EntityTransitions.linear_interpolation(e, x, y, z, this.entity_transition_times[i], this.state_time, this.state_times[this.state_index]);
        EntityTransitions.transformCubicInOut(e, x, y, z, this.entity_transition_times[i], this.state_time, this.state_times[this.state_index] - this.entity_transition_times[i] * 2.0);
      } else if (this.state_index == 2) {
        // Grow
        e.radius = sqrt(e.capitalization) * EntityTransitions.cubicInOut(this.entity_transition_times[i], this.state_time, this.state_times[this.state_index] - this.entity_transition_times[i]);
        //e.radius = 5.0 + (e.capitalization - 5.0) * this.state_time / 1000 / this.state_times[this.state_index];
      } else if (this.state_index == 3) {
        // Fade out
        stroke(0, 200, 200, 255 - 255 * this.state_time / 1000 / this.state_times[this.state_index]);
      }

      e.draw();
      
      if (pivot > -PI) {
        pivot += PivotStep;
        camera(sin(pivot) * 750, -WorldRadius, cos(pivot) * 750, 
               0, 0, 0,                                 
               0, 1, 0);
      }
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