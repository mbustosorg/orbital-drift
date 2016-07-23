class PerformanceScreen extends Screen {
  
  private ArrayList<Path> paths = new ArrayList<Path>();
  
  private Path follow = null;
  private float PivotSpeed = -0.01;
  private PVector MarketCenter = new PVector(0, 0, 0);
  private int ZeroMarketSize = 200;
  
  private float pivot = 0.0;
  
  public PerformanceScreen() {
    super("Performance", 15.0);
      // Duration = Sum of state_times
  }

  void keyPressed() {
    println("key");
    if (key == ' ') {
      for (Path path : paths) {
        path.transitioning = !path.transitioning;
        path.transitionDelay = int(random(0, 1000));
      }
    } else if (key == 'f') {
      if (follow == null) {
        follow = paths.get(int(random(0, entities.size() - 1)));
      } else follow = null;
    }
  }
  
  void setup(ArrayList<Entity> entities) {
    super.setup(entities);
    
    this.screens_next = new Screen[] {new Geography()};
    this.screens_chance = new int[] {100};
    
    for (int i = 0; i < this.entities.size(); i++) {
      paths.add(new Path(this.entities.get(i)));
      Entity e = this.entities.get(i);
      e.draw();
    }
  }

  void update_and_draw(float delta) {
    super.update(delta);

    background(0);
    lights();
    pivot += PivotSpeed;
    noFill();
    stroke(55, 55, 55);
    strokeWeight(5);
    ellipse(MarketCenter.x, MarketCenter.y, ZeroMarketSize * 2, ZeroMarketSize * 2);
    noStroke();
    for (Path path : paths) {
      path.advance();
      path.display();
    }
    if (follow != null) {
      PVector first = follow.trails[paths.get(0).trailIndex].model;
      translate(first.x, first.y, first.z);
      lights();
      fill(follow.trails[paths.get(0).trailIndex].fillColor, 255.0);
      sphere(3);
      camera(first.x * 1.5, first.y * 1.5, first.z * 1.5, // Eye
             0, 0, 0,                                 // Center
             0, 1, 0);                                // Up 
    } else {
      //camera(sin(pivot) * 1000, 0, cos(pivot) * 1000, // Eye
      camera(sin(pivot) * 750, -400, cos(pivot) * 750,
             0, 0, 0,                                 // Center
             0, 1, 0);                                // Up 
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