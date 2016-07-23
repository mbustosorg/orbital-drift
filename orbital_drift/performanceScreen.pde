class PerformanceScreen extends Screen {
  
  private ArrayList<Path> paths = new ArrayList<Path>();
  
  private float AngleBoundary = 2.2;
  private float AngularRotationBoundary = 0.05;
  private Path follow = null;
  private float PivotSpeed = -0.01;
  private PVector MarketCenter = new PVector(0, 0, 0);
  private int ZeroMarketSize = 200;
  
  private float pivot = 0.0;
  
  public PerformanceScreen() {
    super("Performance", 15.0);
      // Duration = Sum of state_times
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
      camera(sin(pivot) * 1000, 0, cos(pivot) * 1000, // Eye
             0, 0, 0,                                 // Center
             0, 1, 0);                                // Up 
    }
    
    for (int i = 0; i < this.entities.size(); i++) {
      Entity e = this.entities.get(i);
      e.draw();
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
class Path {

  private int TrailCount = 30;
  private float TransitioningStep = 0.001;
  private int MaxTransitionStep = int(1 / TransitioningStep);
  private float[] TransitionSteps = new float[MaxTransitionStep];

  Path(Entity entity) {
    for (int i = 0; i < TrailCount; i++) {
      trails[i] = new Entity(entity.symbol, entity.name, entity.sector, entity.sectorIndex, entity.industry, entity.longitude, entity.latitude, 
                             entity.x, entity.y, entity.z, entity.rotation, entity.rotationIncrement);
    }
  }

  void display() {
    int trailCursor = trailIndex;
    for (int i = 0; i < TrailCount; i++) {
      if (transitionDelay > 0) transitionDelay--;
      else {
        if (transitioning && transitioningStep < MaxTransitionStep - 1) transitioningStep += 1;
        else if (!transitioning && transitioningStep > 0) transitioningStep -= 1;
      }
      trails[trailCursor].draw();
      trailCursor--;
      if (trailCursor < 0) trailCursor = TrailCount - 1;
    }
  }

  void advance() {
    trailIndex++;
    if (trailIndex == TrailCount) trailIndex = 0;
    int nextIndex = trailIndex + 1;
    if (nextIndex == TrailCount) nextIndex = 0;
    Entity entity = trails[trailIndex];
    trails[nextIndex] = new Entity(entity.symbol, entity.name, entity.sector, entity.sectorIndex, entity.industry, entity.longitude, entity.latitude, 
                             entity.x, entity.y, entity.z, entity.rotation, entity.rotationIncrement);
    trails[nextIndex].rotation.increment(trails[nextIndex].rotationIncrement);

  }

  Entity[] trails = new Entity[TrailCount];
  int trailIndex = 0;

  boolean transitioning = false;
  int transitionDelay = 0;
  int transitioningStep = 0;
}