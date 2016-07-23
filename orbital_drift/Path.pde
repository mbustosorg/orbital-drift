class Path {

  private int TrailCount = 30;
  private float TransitioningStep = 0.001;
  private int MaxTransitionStep = int(1 / TransitioningStep);
  private float[] TransitionSteps = new float[MaxTransitionStep];

  Path(Entity entity) {
    for (int i = 0; i < TrailCount; i++) {
      trails[i] = new Entity(entity.symbol, entity.name, entity.sector, entity.sectorIndex, entity.industry, entity.longitude, entity.latitude, 
                             entity.position.x, entity.position.y, entity.position.z, entity.rotation, entity.rotationIncrement);
    }
  }

  void advance() {
    trailIndex++;
    if (trailIndex == TrailCount) trailIndex = 0;
    int nextIndex = trailIndex + 1;
    if (nextIndex == TrailCount) nextIndex = 0;
    Entity entity = trails[trailIndex];
    trails[nextIndex] = new Entity(entity.symbol, entity.name, entity.sector, entity.sectorIndex, entity.industry, entity.longitude, entity.latitude, 
                                   entity.position.x, entity.position.y, entity.position.z, entity.rotation, entity.rotationIncrement);
    trails[nextIndex].rotation.increment(trails[nextIndex].rotationIncrement);
  }

  void display() {
    int trailCursor = trailIndex;
    for (int i = 0; i < TrailCount; i++) {
      if (transitionDelay > 0) transitionDelay--;
      else {
        if (transitioning && transitioningStep < MaxTransitionStep - 1) transitioningStep += 1;
        else if (!transitioning && transitioningStep > 0) transitioningStep -= 1;
      }
      trails[trailCursor].rotation.increment(trails[trailCursor].rotationIncrement);
      trails[trailCursor].draw();
      trailCursor--;
      if (trailCursor < 0) trailCursor = TrailCount - 1;
    }
  }

  Entity[] trails = new Entity[TrailCount];
  int trailIndex = 0;

  boolean transitioning = false;
  int transitionDelay = 0;
  int transitioningStep = 0;
}