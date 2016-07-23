static class EntityTransitions {
  static void linear_interpolation(Entity e, float x_end, float y_end, float z_end, float delay_time, float elapsed, float transition_time) {
    if (delay_time > elapsed / 1000) {
      // Wait
    } else if (elapsed / 1000 >= transition_time) {
      e.x = x_end;
      e.y = y_end;
      e.z = z_end;
            println("finish");

    } else {
      float t = (elapsed / 1000 - delay_time) / (transition_time - delay_time);
      e.x = (1.0 - t) * e.initPosition.x + t * x_end;
      e.y = (1.0 - t) * e.initPosition.y + t * y_end;
      e.z = (1.0 - t) * e.initPosition.z + t * z_end;
    }
  }
  
  static float cubicInOut(float delay_time, float elapsed, float transition_time) {
    if (delay_time > elapsed / 1000) {
      return 0.0;
    } else if (elapsed / 1000 >= transition_time) {
      return 1.0;
    } else {
      float step = (elapsed - delay_time * 1000) / (transition_time * 1000 - delay_time * 1000) * 2.0;
      float t = 1.0;
      if (step < 1) {
        t = step * step * step / 2.0;
      } else {
        step -= 2;
        t = (step * step * step + 2) / 2.0;      
      }
      return t;
    }
  }

  static void transformCubicInOut(Entity e, float x_end, float y_end, float z_end, float delay_time, float elapsed, float transition_time) {
    float factor = cubicInOut(delay_time, elapsed, transition_time);
    e.x = (1.0 - factor) * e.initPosition.x + factor * x_end;
    e.y = (1.0 - factor) * e.initPosition.y + factor * y_end;
    e.z = (1.0 - factor) * e.initPosition.z + factor * z_end;
  }
} //<>//