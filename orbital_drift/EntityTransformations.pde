static class EntityTransitions {
  static void linear_interpolation_2d(Entity e, float x_end, float y_end, float delay_time, float elapsed, float transition_time) {
    
    if (delay_time > elapsed / 1000) {
      // Wait
    } else if (elapsed / 1000 >= transition_time) {
      e.x = x_end;
      e.y = y_end;
    } else {
      float t = (elapsed / 1000 - delay_time) / (transition_time - delay_time);
      e.x = (1.0 - t) * e.x_init + t * x_end;
      e.y = (1.0 - t) * e.y_init + t * y_end;
    }
  }
}