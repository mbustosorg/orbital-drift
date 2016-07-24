/*

 Copyright (C) 2016 Mauricio Bustos (m@bustos.org), Matthew Yeager
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

static class EntityTransitions {
  static color[] Colors = {#a6cee3, #1f78b4, #b2df8a, #33a02c, #fb9a99, #e31a1c, #fdbf6f, #ff7f00, #cab2d6, #6a3d9a};
  static float linear_interpolation(float delay_time, float elapsed, float transition_time) {
    if (delay_time > elapsed) {
      return 0.0;
    } else if (elapsed / 1000 >= transition_time) {
      return 1.0;
    } else {
      return (elapsed - delay_time) / (transition_time - delay_time);
    }
  }
  
  static float cubicInOut(float delay_time, float elapsed, float transition_time) {
    if (delay_time > elapsed) {
      return 0.0;
    } else if (elapsed >= delay_time + transition_time) {
      return 1.0;
    } else {
      float step = (elapsed - delay_time) / (transition_time - delay_time) * 2.0;
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
    e.position.x = (1.0 - factor) * e.initPosition.x + factor * x_end;
    e.position.y = (1.0 - factor) * e.initPosition.y + factor * y_end;
    e.position.z = (1.0 - factor) * e.initPosition.z + factor * z_end;
  }
  
  static float AngleBoundary = 2.2;
  static float AngularRotationBoundary = 0.01;
  static int TrailCount = 30;
  static float TransitioningStep = 0.001;
  static int MaxTransitionStep = int(1 / TransitioningStep);
  static float[] TransitionSteps = new float[MaxTransitionStep];
  
}